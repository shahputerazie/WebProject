package com.project.dao;

import com.project.model.BookingRequest;
import java.math.BigDecimal;
import java.sql.Date;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Time;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.ThreadLocalRandom;

public class BookingDAO {

    public boolean addBooking(BookingRequest booking) {
        boolean isSuccess = false;
        if (booking == null || booking.getUserId() == null || booking.getUserId() <= 0) {
            return false;
        }

        String query = "INSERT INTO bookings (request_code, user_id, trip_date, return_date, return_time, destination, passenger_count, vehicle_type, purpose, license_image_path, daily_rental_fee, late_fee_per_hour, estimated_rental_fee, assigned_vehicle_id, status, rejection_reason) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement pstmt = conn.prepareStatement(query)) {

            pstmt.setString(1, booking.getRequestCode());
            pstmt.setLong(2, booking.getUserId());
            pstmt.setDate(3, java.sql.Date.valueOf(booking.getTripDate()));
            pstmt.setDate(4, java.sql.Date.valueOf(booking.getReturnDate()));
            pstmt.setTime(5, booking.getReturnTime() != null ? Time.valueOf(booking.getReturnTime()) : Time.valueOf("17:00:00"));
            pstmt.setString(6, booking.getDestination());
            pstmt.setInt(7, booking.getPassengerCount());
            pstmt.setString(8, booking.getVehicleType().name());
            pstmt.setString(9, booking.getPurpose());
            pstmt.setString(10, booking.getLicenseImagePath());
            pstmt.setBigDecimal(11, normalizeMoney(booking.getDailyRentalFee()));
            pstmt.setBigDecimal(12, normalizeMoney(booking.getLateFeePerHour()));
            pstmt.setBigDecimal(13, normalizeMoney(booking.getEstimatedRentalFee()));
            if (booking.getAssignedVehicleId() == null) {
                pstmt.setNull(14, java.sql.Types.BIGINT);
            } else {
                pstmt.setLong(14, booking.getAssignedVehicleId());
            }
            pstmt.setString(15, booking.getStatus().name());
            pstmt.setString(16, booking.getRejectionReason());

            isSuccess = pstmt.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }

        return isSuccess;
    }

    public List<BookingRequest> getAllBookings() {
        List<BookingRequest> bookings = new ArrayList<>();
        String query = "SELECT id, user_id, trip_date, return_date, return_time, destination, passenger_count, vehicle_type, purpose, license_image_path, daily_rental_fee, late_fee_per_hour, estimated_rental_fee, assigned_vehicle_id, status, rejection_reason "
                + "FROM bookings ORDER BY created_at DESC, id DESC";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement pstmt = conn.prepareStatement(query); ResultSet rs = pstmt.executeQuery()) {

            while (rs.next()) {
                bookings.add(mapBooking(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return bookings;
    }

    public List<BookingRequest> getBookingsByUserId(long userId) {
        List<BookingRequest> bookings = new ArrayList<>();
        String query = "SELECT id, user_id, trip_date, return_date, return_time, destination, passenger_count, vehicle_type, purpose, license_image_path, daily_rental_fee, late_fee_per_hour, estimated_rental_fee, assigned_vehicle_id, status, rejection_reason "
                + "FROM bookings WHERE user_id = ? ORDER BY created_at DESC, id DESC";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement pstmt = conn.prepareStatement(query)) {
            pstmt.setLong(1, userId);

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    bookings.add(mapBooking(rs));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return bookings;
    }

    public List<BookingRequest> getRecentBookingsByUserId(long userId, int limit) {
        try (Connection conn = DBConnection.getConnection()) {
            return collectRecentBookings(conn, userId, limit);
        } catch (Exception e) {
            e.printStackTrace();
        }

        return new ArrayList<>();
    }

    public BookingDashboardData getBookingDashboardDataByUserId(long userId, int limit) {
        try (Connection conn = DBConnection.getConnection()) {
            BookingStats stats = collectBookingStats(conn, userId);
            List<BookingRequest> bookings = collectRecentBookings(conn, userId, limit);
            return new BookingDashboardData(stats, bookings);
        } catch (Exception e) {
            e.printStackTrace();
        }

        return new BookingDashboardData(new BookingStats(0, 0, 0, 0, 0, 0), new ArrayList<>());
    }

    public BookingStats getBookingStatsByUserId(long userId) {
        try (Connection conn = DBConnection.getConnection()) {
            return collectBookingStats(conn, userId);
        } catch (Exception e) {
            e.printStackTrace();
        }

        return new BookingStats(0, 0, 0, 0, 0, 0);
    }

    private BookingStats collectBookingStats(Connection conn, long userId) throws Exception {
        String query = "SELECT COUNT(*) AS total_requests, "
                + "COALESCE(SUM(CASE WHEN status = 'PENDING' THEN 1 ELSE 0 END), 0) AS pending_requests, "
                + "COALESCE(SUM(CASE WHEN status = 'APPROVED' THEN 1 ELSE 0 END), 0) AS approved_requests, "
                + "COALESCE(SUM(CASE WHEN status = 'COMPLETED' THEN 1 ELSE 0 END), 0) AS completed_requests, "
                + "COALESCE(SUM(CASE WHEN status = 'REJECTED' THEN 1 ELSE 0 END), 0) AS rejected_requests, "
                + "COALESCE(SUM(CASE WHEN status = 'CANCELLED' THEN 1 ELSE 0 END), 0) AS cancelled_requests "
                + "FROM bookings WHERE user_id = ?";

        try (PreparedStatement pstmt = conn.prepareStatement(query)) {
            pstmt.setLong(1, userId);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return new BookingStats(
                            rs.getInt("total_requests"),
                            rs.getInt("pending_requests"),
                            rs.getInt("approved_requests"),
                            rs.getInt("completed_requests"),
                            rs.getInt("rejected_requests"),
                            rs.getInt("cancelled_requests")
                    );
                }
            }
        }

        return new BookingStats(0, 0, 0, 0, 0, 0);
    }

    public BookingRequest getBookingById(long id) {
        BookingRequest booking = null;
        String query = "SELECT id, user_id, trip_date, return_date, return_time, destination, passenger_count, vehicle_type, purpose, license_image_path, daily_rental_fee, late_fee_per_hour, estimated_rental_fee, assigned_vehicle_id, status, rejection_reason "
                + "FROM bookings WHERE id = ?";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement pstmt = conn.prepareStatement(query)) {
            pstmt.setLong(1, id);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    booking = mapBooking(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return booking;
    }

    public BookingRequest getBookingByIdAndUserId(long id, long userId) {
        BookingRequest booking = null;
        String query = "SELECT id, user_id, trip_date, return_date, return_time, destination, passenger_count, vehicle_type, purpose, license_image_path, daily_rental_fee, late_fee_per_hour, estimated_rental_fee, assigned_vehicle_id, status, rejection_reason "
                + "FROM bookings WHERE id = ? AND user_id = ?";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement pstmt = conn.prepareStatement(query)) {
            pstmt.setLong(1, id);
            pstmt.setLong(2, userId);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    booking = mapBooking(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return booking;
    }

    public boolean updateBookingStatus(long id, String status) {
        return updateBookingStatus(id, status, null);
    }

    public boolean updateBookingStatus(long id, String status, String rejectionReason) {
        String query = "UPDATE bookings SET status = ?, rejection_reason = ?, updated_at = NOW() WHERE id = ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement pstmt = conn.prepareStatement(query)) {
            pstmt.setString(1, status);
            if ("REJECTED".equalsIgnoreCase(status)) {
                pstmt.setString(2, rejectionReason == null || rejectionReason.trim().isEmpty() ? null : rejectionReason.trim());
            } else {
                pstmt.setNull(2, java.sql.Types.LONGVARCHAR);
            }
            pstmt.setLong(3, id);
            return pstmt.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public String generateRequestCode() {
        long suffix = ThreadLocalRandom.current().nextInt(100, 1000);
        java.time.format.DateTimeFormatter formatter = java.time.format.DateTimeFormatter.ofPattern("yyyyMMdd-HHmmss");
        return "BR-" + java.time.LocalDateTime.now().format(formatter) + "-" + suffix;
    }

    public boolean updatePendingBooking(BookingRequest booking) {
        boolean isSuccess = false;
        String query = "UPDATE bookings SET trip_date = ?, return_date = ?, return_time = ?, destination = ?, passenger_count = ?, "
                + "vehicle_type = ?, purpose = ?, daily_rental_fee = ?, late_fee_per_hour = ?, estimated_rental_fee = ?, rejection_reason = NULL, updated_at = NOW() "
                + "WHERE id = ? AND status = 'PENDING'";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement pstmt = conn.prepareStatement(query)) {
            pstmt.setDate(1, java.sql.Date.valueOf(booking.getTripDate()));
            pstmt.setDate(2, java.sql.Date.valueOf(booking.getReturnDate()));
            pstmt.setTime(3, booking.getReturnTime() != null ? Time.valueOf(booking.getReturnTime()) : Time.valueOf("17:00:00"));
            pstmt.setString(4, booking.getDestination());
            pstmt.setInt(5, booking.getPassengerCount());
            pstmt.setString(6, booking.getVehicleType().name());
            pstmt.setString(7, booking.getPurpose());
            pstmt.setBigDecimal(8, normalizeMoney(booking.getDailyRentalFee()));
            pstmt.setBigDecimal(9, normalizeMoney(booking.getLateFeePerHour()));
            pstmt.setBigDecimal(10, normalizeMoney(booking.getEstimatedRentalFee()));
            pstmt.setLong(11, booking.getId());

            isSuccess = pstmt.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }

        return isSuccess;
    }

    public boolean updatePendingBookingForUser(BookingRequest booking, long userId) {
        boolean isSuccess = false;
        String query = "UPDATE bookings SET trip_date = ?, return_date = ?, return_time = ?, destination = ?, passenger_count = ?, "
                + "vehicle_type = ?, purpose = ?, daily_rental_fee = ?, late_fee_per_hour = ?, estimated_rental_fee = ?, rejection_reason = NULL, updated_at = NOW() "
                + "WHERE id = ? AND user_id = ? AND status = 'PENDING'";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement pstmt = conn.prepareStatement(query)) {
            pstmt.setDate(1, java.sql.Date.valueOf(booking.getTripDate()));
            pstmt.setDate(2, java.sql.Date.valueOf(booking.getReturnDate()));
            pstmt.setTime(3, booking.getReturnTime() != null ? Time.valueOf(booking.getReturnTime()) : Time.valueOf("17:00:00"));
            pstmt.setString(4, booking.getDestination());
            pstmt.setInt(5, booking.getPassengerCount());
            pstmt.setString(6, booking.getVehicleType().name());
            pstmt.setString(7, booking.getPurpose());
            pstmt.setBigDecimal(8, normalizeMoney(booking.getDailyRentalFee()));
            pstmt.setBigDecimal(9, normalizeMoney(booking.getLateFeePerHour()));
            pstmt.setBigDecimal(10, normalizeMoney(booking.getEstimatedRentalFee()));
            pstmt.setLong(11, booking.getId());
            pstmt.setLong(12, userId);

            isSuccess = pstmt.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }

        return isSuccess;
    }

    public boolean cancelPendingBooking(long bookingId) {
        boolean isSuccess = false;
        String query = "UPDATE bookings SET status = 'CANCELLED' WHERE id = ? AND status = 'PENDING'";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement pstmt = conn.prepareStatement(query)) {
            pstmt.setLong(1, bookingId);
            isSuccess = pstmt.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }

        return isSuccess;
    }

    public boolean cancelPendingBookingForUser(long bookingId, long userId) {
        boolean isSuccess = false;
        String query = "UPDATE bookings SET status = 'CANCELLED' WHERE id = ? AND user_id = ? AND status = 'PENDING'";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement pstmt = conn.prepareStatement(query)) {
            pstmt.setLong(1, bookingId);
            pstmt.setLong(2, userId);
            isSuccess = pstmt.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }

        return isSuccess;
    }

    private List<BookingRequest> collectRecentBookings(Connection conn, long userId, int limit) throws Exception {
        List<BookingRequest> bookings = new ArrayList<>();
        String query = "SELECT id, user_id, trip_date, return_date, return_time, destination, passenger_count, vehicle_type, purpose, license_image_path, daily_rental_fee, late_fee_per_hour, estimated_rental_fee, assigned_vehicle_id, status, rejection_reason "
                + "FROM bookings WHERE user_id = ? ORDER BY created_at DESC, id DESC LIMIT ?";

        try (PreparedStatement pstmt = conn.prepareStatement(query)) {
            pstmt.setLong(1, userId);
            pstmt.setInt(2, Math.max(limit, 1));

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    bookings.add(mapBooking(rs));
                }
            }
        }

        return bookings;
    }

    private BookingRequest mapBooking(ResultSet rs) throws Exception {
        BookingRequest booking = new BookingRequest();
        booking.setId(rs.getLong("id"));
        booking.setUserId(rs.getLong("user_id"));

        Date tripDate = rs.getDate("trip_date");
        Date returnDate = rs.getDate("return_date");
        if (tripDate != null) {
            booking.setTripDate(tripDate.toLocalDate());
        }
        if (returnDate != null) {
            booking.setReturnDate(returnDate.toLocalDate());
        }
        Time returnTime = rs.getTime("return_time");
        if (returnTime != null) {
            booking.setReturnTime(returnTime.toLocalTime());
        }

        booking.setDestination(rs.getString("destination"));
        booking.setPassengerCount(rs.getInt("passenger_count"));

        String vehicleType = rs.getString("vehicle_type");
        if (vehicleType != null && !vehicleType.trim().isEmpty()) {
            booking.setVehicleType(normalizeVehicleType(vehicleType));
        }

        booking.setPurpose(rs.getString("purpose"));
        booking.setLicenseImagePath(rs.getString("license_image_path"));
        booking.setDailyRentalFee(rs.getBigDecimal("daily_rental_fee"));
        booking.setLateFeePerHour(rs.getBigDecimal("late_fee_per_hour"));
        booking.setEstimatedRentalFee(rs.getBigDecimal("estimated_rental_fee"));
        long assignedVehicleId = rs.getLong("assigned_vehicle_id");
        booking.setAssignedVehicleId(rs.wasNull() ? null : assignedVehicleId);

        String status = rs.getString("status");
        if (status != null && !status.trim().isEmpty()) {
            try {
                booking.setStatus(BookingRequest.Status.valueOf(status.trim().toUpperCase()));
            } catch (IllegalArgumentException ignored) {
                booking.setStatus(null);
            }
        }

        booking.setRejectionReason(rs.getString("rejection_reason"));

        return booking;
    }

    private BigDecimal normalizeMoney(BigDecimal value) {
        return value == null ? BigDecimal.ZERO.setScale(2, java.math.RoundingMode.HALF_UP) : value.setScale(2, java.math.RoundingMode.HALF_UP);
    }

    private BookingRequest.VehicleType normalizeVehicleType(String value) {
        if (value == null) {
            return null;
        }

        String normalized = value.trim().toUpperCase();
        if ("SEDAN".equals(normalized) || "COMPACT_CAR".equals(normalized) || "NORMAL_CAR".equals(normalized)
                || "VAN".equals(normalized)) {
            return BookingRequest.VehicleType.SEDAN;
        }
        if ("SUV".equals(normalized) || "MPV".equals(normalized) || "LARGE_CAR".equals(normalized)
                || "BUS".equals(normalized) || "FOUR_BY_FOUR".equals(normalized)) {
            return BookingRequest.VehicleType.SUV;
        }
        return null;
    }

    public static final class BookingDashboardData {
        private final BookingStats stats;
        private final List<BookingRequest> recentBookings;

        public BookingDashboardData(BookingStats stats, List<BookingRequest> recentBookings) {
            this.stats = stats;
            this.recentBookings = recentBookings;
        }

        public BookingStats getStats() {
            return stats;
        }

        public List<BookingRequest> getRecentBookings() {
            return recentBookings;
        }
    }

    public static final class BookingStats {
        private final int totalRequests;
        private final int pendingRequests;
        private final int approvedRequests;
        private final int completedRequests;
        private final int rejectedRequests;
        private final int cancelledRequests;

        public BookingStats(int totalRequests, int pendingRequests, int approvedRequests, int completedRequests,
                int rejectedRequests, int cancelledRequests) {
            this.totalRequests = totalRequests;
            this.pendingRequests = pendingRequests;
            this.approvedRequests = approvedRequests;
            this.completedRequests = completedRequests;
            this.rejectedRequests = rejectedRequests;
            this.cancelledRequests = cancelledRequests;
        }

        public int getTotalRequests() {
            return totalRequests;
        }

        public int getPendingRequests() {
            return pendingRequests;
        }

        public int getApprovedRequests() {
            return approvedRequests;
        }

        public int getCompletedRequests() {
            return completedRequests;
        }

        public int getRejectedRequests() {
            return rejectedRequests;
        }

        public int getCancelledRequests() {
            return cancelledRequests;
        }
    }
}
