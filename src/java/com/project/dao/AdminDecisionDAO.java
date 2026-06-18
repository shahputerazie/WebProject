package com.project.dao;

import com.project.model.BookingRequest.Status;
import com.project.model.HandoverRecord;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Types;
import java.util.UUID;

public class AdminDecisionDAO {

    // UPDATE: Change booking status (Approve, Reject, Complete, Cancel)
    public boolean updateBookingStatus(Long bookingId, Status newStatus) {
        return updateBookingStatus(bookingId, newStatus, null);
    }

    public boolean updateBookingStatus(Long bookingId, Status newStatus, String rejectionReason) {
        String selectSql = "SELECT assigned_vehicle_id FROM bookings WHERE id = ? FOR UPDATE";
        String updateSql = "UPDATE bookings SET status = ?, rejection_reason = ?, updated_at = NOW() WHERE id = ?";
        String releaseSql = "UPDATE vehicles SET status = 'AVAILABLE', updated_at = NOW() WHERE id = ?";
        String normalizedReason = (rejectionReason == null || rejectionReason.trim().isEmpty()) ? null : rejectionReason.trim();

        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);
            Long assignedVehicleId = null;

            try (PreparedStatement ps = conn.prepareStatement(selectSql)) {
                ps.setLong(1, bookingId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        long vehicleId = rs.getLong("assigned_vehicle_id");
                        assignedVehicleId = rs.wasNull() ? null : vehicleId;
                    } else {
                        conn.rollback();
                        return false;
                    }
                }
            }

            try (PreparedStatement ps = conn.prepareStatement(updateSql)) {
                ps.setString(1, newStatus.name());
                if (Status.REJECTED.equals(newStatus)) {
                    ps.setString(2, normalizedReason);
                } else {
                    ps.setNull(2, java.sql.Types.LONGVARCHAR);
                }
                ps.setLong(3, bookingId);
                if (ps.executeUpdate() <= 0) {
                    conn.rollback();
                    return false;
                }
            }

            if (assignedVehicleId != null && (Status.COMPLETED.equals(newStatus)
                    || Status.REJECTED.equals(newStatus)
                    || Status.CANCELLED.equals(newStatus))) {
                try (PreparedStatement ps = conn.prepareStatement(releaseSql)) {
                    ps.setLong(1, assignedVehicleId);
                    ps.executeUpdate();
                }
            }

            conn.commit();
            return true;

        } catch (Exception e) {
            e.printStackTrace();
            rollbackQuietly(conn);
        }
        finally {
            closeQuietly(conn);
        }
        return false;
    }

    public boolean approveBookingWithVehicle(Long bookingId, Long vehicleId) {
        String bookingSql = "SELECT vehicle_type, status, assigned_vehicle_id FROM bookings WHERE id = ? FOR UPDATE";
        String vehicleSql = "SELECT type, status FROM vehicles WHERE id = ? FOR UPDATE";
        String updateBookingSql = "UPDATE bookings SET status = 'APPROVED', rejection_reason = NULL, updated_at = NOW() WHERE id = ? AND status = 'PENDING'";

        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            String bookingType = null;
            String bookingStatus = null;
            Long assignedVehicleId = null;
            String vehicleType = null;
            String vehicleStatus = null;

            try (PreparedStatement ps = conn.prepareStatement(bookingSql)) {
                ps.setLong(1, bookingId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        bookingType = rs.getString("vehicle_type");
                        bookingStatus = rs.getString("status");
                        long currentVehicleId = rs.getLong("assigned_vehicle_id");
                        assignedVehicleId = rs.wasNull() ? null : currentVehicleId;
                    } else {
                        conn.rollback();
                        return false;
                    }
                }
            }

            if (!"PENDING".equalsIgnoreCase(bookingStatus)) {
                conn.rollback();
                return false;
            }

            Long targetVehicleId = vehicleId != null ? vehicleId : assignedVehicleId;
            if (targetVehicleId == null) {
                conn.rollback();
                return false;
            }

            if (assignedVehicleId != null && !assignedVehicleId.equals(targetVehicleId)) {
                conn.rollback();
                return false;
            }

            try (PreparedStatement ps = conn.prepareStatement(vehicleSql)) {
                ps.setLong(1, targetVehicleId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        vehicleType = rs.getString("type");
                        vehicleStatus = rs.getString("status");
                    } else {
                        conn.rollback();
                        return false;
                    }
                }
            }

            String bookingCategory = normalizeVehicleCategory(bookingType);
            String vehicleCategory = normalizeVehicleCategory(vehicleType);

            if (bookingCategory == null
                    || vehicleCategory == null
                    || !vehicleCategory.equals(bookingCategory)
                    || (!"AVAILABLE".equalsIgnoreCase(vehicleStatus)
                        && !"UNAVAILABLE".equalsIgnoreCase(vehicleStatus))) {
                conn.rollback();
                return false;
            }

            try (PreparedStatement ps = conn.prepareStatement(updateBookingSql)) {
                ps.setLong(1, bookingId);
                if (ps.executeUpdate() <= 0) {
                    conn.rollback();
                    return false;
                }
            }

            conn.commit();
            return true;

        } catch (Exception e) {
            e.printStackTrace();
            rollbackQuietly(conn);
        } finally {
            closeQuietly(conn);
        }
        return false;
    }

    // DELETE / REVERT: Revoke an approval (sets status to CANCELLED and optionally removes handover)
    public boolean revokeApproval(Long bookingId) {
        String selectSql = "SELECT assigned_vehicle_id FROM bookings WHERE id = ? FOR UPDATE";
        String updateSql = "UPDATE bookings SET status = 'CANCELLED', rejection_reason = NULL, updated_at = NOW() WHERE id = ? AND status = 'APPROVED'";
        String deleteHandoverSql = "DELETE FROM handover_records WHERE booking_id = ?";
        String releaseSql = "UPDATE vehicles SET status = 'AVAILABLE', updated_at = NOW() WHERE id = ?";
        
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);
            Long assignedVehicleId = null;

            try (PreparedStatement psSelect = conn.prepareStatement(selectSql)) {
                psSelect.setLong(1, bookingId);
                try (ResultSet rs = psSelect.executeQuery()) {
                    if (rs.next()) {
                        long vehicleId = rs.getLong("assigned_vehicle_id");
                        assignedVehicleId = rs.wasNull() ? null : vehicleId;
                    }
                }
            }

            try (PreparedStatement psUpdate = conn.prepareStatement(updateSql);
                 PreparedStatement psDelete = conn.prepareStatement(deleteHandoverSql)) {
                
                psUpdate.setLong(1, bookingId);
                int updated = psUpdate.executeUpdate();
                
                if (updated > 0) {
                    psDelete.setLong(1, bookingId);
                    psDelete.executeUpdate();
                    if (assignedVehicleId != null) {
                        try (PreparedStatement psRelease = conn.prepareStatement(releaseSql)) {
                            psRelease.setLong(1, assignedVehicleId);
                            psRelease.executeUpdate();
                        }
                    }
                    conn.commit();
                    return true;
                } else {
                    conn.rollback();
                }
            } catch (Exception ex) {
                conn.rollback();
                ex.printStackTrace();
            }
        } catch (Exception e) {
            e.printStackTrace();
            rollbackQuietly(conn);
        } finally {
            closeQuietly(conn);
        }
        return false;
    }

    // CREATE: Generate Handover Record
    public HandoverRecord generateHandoverPass(Long bookingId, String adminId) {
        // Ensure table exists: CREATE TABLE handover_records (id BIGINT AUTO_INCREMENT PRIMARY KEY, booking_id BIGINT, admin_id VARCHAR(50), pass_code VARCHAR(20), generated_at DATETIME DEFAULT CURRENT_TIMESTAMP);
        String sql = "INSERT INTO handover_records (booking_id, admin_id, pass_code) VALUES (?, ?, ?)";
        String passCode = "PASS-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, PreparedStatement.RETURN_GENERATED_KEYS)) {
            
            ps.setLong(1, bookingId);
            ps.setString(2, adminId);
            ps.setString(3, passCode);
            
            if (ps.executeUpdate() > 0) {
                ResultSet rs = ps.getGeneratedKeys();
                if (rs.next()) {
                    HandoverRecord record = new HandoverRecord(bookingId, adminId, passCode);
                    record.setId(rs.getLong(1));
                    return record;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
    
    // READ: Get Handover code if exists
    public String getHandoverPassCode(Long bookingId) {
        String sql = "SELECT pass_code FROM handover_records WHERE booking_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, bookingId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return rs.getString("pass_code");
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    private String normalizeVehicleCategory(String value) {
        if (value == null) {
            return null;
        }

        String normalized = value.trim().toUpperCase();
        if ("SEDAN".equals(normalized) || "COMPACT_CAR".equals(normalized) || "NORMAL_CAR".equals(normalized)
                || "VAN".equals(normalized)) {
            return "SEDAN";
        }
        if ("SUV".equals(normalized) || "MPV".equals(normalized) || "LARGE_CAR".equals(normalized)
                || "BUS".equals(normalized) || "FOUR_BY_FOUR".equals(normalized)) {
            return "SUV";
        }
        return null;
    }

    private void rollbackQuietly(Connection conn) {
        if (conn == null) {
            return;
        }
        try {
            conn.rollback();
        } catch (Exception ignored) {
        }
    }

    private void closeQuietly(Connection conn) {
        if (conn == null) {
            return;
        }
        try {
            conn.close();
        } catch (Exception ignored) {
        }
    }
}
