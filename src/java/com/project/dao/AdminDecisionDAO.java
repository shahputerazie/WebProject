package com.project.dao;

import com.project.model.BookingRequest.Status;
import com.project.model.HandoverRecord;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.UUID;

public class AdminDecisionDAO {

    // UPDATE: Change booking status (Approve, Reject, Complete, Cancel)
    public boolean updateBookingStatus(Long bookingId, Status newStatus) {
        String sql = "UPDATE bookings SET status = ?, updated_at = NOW() WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, newStatus.name());
            ps.setLong(2, bookingId);
            return ps.executeUpdate() > 0;
            
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // DELETE / REVERT: Revoke an approval (sets status to CANCELLED and optionally removes handover)
    public boolean revokeApproval(Long bookingId) {
        String updateSql = "UPDATE bookings SET status = 'CANCELLED', updated_at = NOW() WHERE id = ? AND status = 'APPROVED'";
        String deleteHandoverSql = "DELETE FROM handover_records WHERE booking_id = ?";
        
        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            try (PreparedStatement psUpdate = conn.prepareStatement(updateSql);
                 PreparedStatement psDelete = conn.prepareStatement(deleteHandoverSql)) {
                
                psUpdate.setLong(1, bookingId);
                int updated = psUpdate.executeUpdate();
                
                if (updated > 0) {
                    psDelete.setLong(1, bookingId);
                    psDelete.executeUpdate();
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
}