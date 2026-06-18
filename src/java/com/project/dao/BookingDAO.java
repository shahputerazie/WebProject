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

        try (Connection conn = DBConnection.getConnection()) {
            isSuccess = insertBooking(conn, booking) != null;
        } catch (Exception e) {
            e.printStackTrace();
        }

        return isSuccess;
    }

    public Long addBookingWithAutoAssignment(BookingRequest booking) {
        if (booking == null || booking.getUserId() == null || booking.getUserId() <= 0 || booking.getVehicleType() == null) {
            return null;
        }

        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            Long vehicleId = reserveAvailableVehicle(conn, booking.getVehicleType().name());
            if (vehicleId == null) {
                conn.rollback();
                return null;
            }

            booking.setAssignedVehicleId(vehicleId);

            Long bookingId = insertBooking(conn, booking);
            if (bookingId == null) {
                releaseVehicle(conn, vehicleId);
                conn.rollback();
                return null;
            }

            conn.commit();
            return bookingId;
        } catch (Exception e) {
            e.printStackTrace();
            rollbackQuietly(conn);
            return null;
        } finally {
            closeQuietly(conn);
        }
    }

    public List<BookingRequest> getAllBookings() {
        List<BookingRequest> bookings = new ArrayList<>();
        String query = "SELECT b.id, b.user_id, b.trip_date, b.return_date, b.return_time, b.destination, b.booking_phone, b.passenger_count, b.vehicle_type, b.purpose, b.license_image_path, b.daily_rental_fee, b.late_fee_per_hour, b.estimated_rental_fee, b.assigned_vehicle_id, b.status, b.rejection_reason, "
                + "u.name AS booker_name, u.email AS booker_email, u.phone AS booker_phone, u.role AS booker_role "
                + "FROM bookings b INNER JOIN users u ON u.userId = b.user_id ORDER BY b.created_at DESC, b.id DESC";

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
        String query = "SELECT id, user_id, trip_date, return_date, return_time, destination, booking_phone, passenger_count, vehicle_type, purpose, license_image_path, daily_rental_fee, late_fee_per_hour, estimated_rental_fee, assigned_vehicle_id, status, rejection_reason "
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
        String query = "SELECT b.id, b.user_id, b.trip_date, b.return_date, b.return_time, b.destination, b.booking_phone, b.passenger_count, b.vehicle_type, b.purpose, b.license_image_path, b.daily_rental_fee, b.late_fee_per_hour, b.estimated_rental_fee, b.assigned_vehicle_id, b.status, b.rejection_reason, "
                + "u.name AS booker_name, u.email AS booker_email, u.phone AS booker_phone, u.role AS booker_role "
                + "FROM bookings b INNER JOIN users u ON u.userId = b.user_id WHERE b.id = ?";

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
        String query = "SELECT b.id, b.user_id, b.trip_date, b.return_date, b.return_time, b.destination, b.booking_phone, b.passenger_count, b.vehicle_type, b.purpose, b.license_image_path, b.daily_rental_fee, b.late_fee_per_hour, b.estimated_rental_fee, b.assigned_vehicle_id, b.status, b.rejection_reason, "
                + "u.name AS booker_name, u.email AS booker_email, u.phone AS booker_phone, u.role AS booker_role "
                + "FROM bookings b INNER JOIN users u ON u.userId = b.user_id WHERE b.id = ? AND b.user_id = ?";

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
        String selectSql = "SELECT assigned_vehicle_id, vehicle_type FROM bookings WHERE id = ? AND user_id = ? AND status = 'PENDING' FOR UPDATE";
        String updateSql = "UPDATE bookings SET trip_date = ?, return_date = ?, return_time = ?, destination = ?, passenger_count = ?, "
                + "vehicle_type = ?, purpose = ?, daily_rental_fee = ?, late_fee_per_hour = ?, estimated_rental_fee = ?, assigned_vehicle_id = ?, rejection_reason = NULL, updated_at = NOW() "
                + "WHERE id = ? AND user_id = ? AND status = 'PENDING'";

        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            Long currentVehicleId = null;
            BookingRequest.VehicleType currentVehicleType = null;

            try (PreparedStatement ps = conn.prepareStatement(selectSql)) {
                ps.setLong(1, booking.getId());
                ps.setLong(2, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        conn.rollback();
                        return false;
                    }
                    long assignedVehicleId = rs.getLong("assigned_vehicle_id");
                    currentVehicleId = rs.wasNull() ? null : assignedVehicleId;
                    currentVehicleType = normalizeVehicleType(rs.getString("vehicle_type"));
                }
            }

            Long nextVehicleId = currentVehicleId;
            boolean needsReassignment = currentVehicleId == null
                    || currentVehicleType == null
                    || !currentVehicleType.equals(booking.getVehicleType());

            if (needsReassignment) {
                nextVehicleId = reserveAvailableVehicle(conn, booking.getVehicleType().name());
                if (nextVehicleId == null) {
                    conn.rollback();
                    return false;
                }
            }

            try (PreparedStatement pstmt = conn.prepareStatement(updateSql)) {
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
                if (nextVehicleId == null) {
                    pstmt.setNull(11, java.sql.Types.BIGINT);
                } else {
                    pstmt.setLong(11, nextVehicleId);
                }
                pstmt.setLong(12, booking.getId());
                pstmt.setLong(13, userId);

                isSuccess = pstmt.executeUpdate() > 0;
            }

            if (!isSuccess) {
                if (needsReassignment && nextVehicleId != null) {
                    releaseVehicle(conn, nextVehicleId);
                }
                conn.rollback();
                return false;
            }

            if (needsReassignment && currentVehicleId != null) {
                releaseVehicle(conn, currentVehicleId);
            }

            conn.commit();
        } catch (Exception e) {
            e.printStackTrace();
            rollbackQuietly(conn);
        } finally {
            closeQuietly(conn);
        }

        return isSuccess;
    }

    public boolean cancelPendingBooking(long bookingId) {
        boolean isSuccess = false;
        String selectSql = "SELECT assigned_vehicle_id FROM bookings WHERE id = ? AND status = 'PENDING' FOR UPDATE";
        String updateSql = "UPDATE bookings SET status = 'CANCELLED', rejection_reason = NULL, updated_at = NOW() WHERE id = ? AND status = 'PENDING'";

        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);
            Long assignedVehicleId = null;

            try (PreparedStatement ps = conn.prepareStatement(selectSql)) {
                ps.setLong(1, bookingId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        conn.rollback();
                        return false;
                    }
                    long vehicleId = rs.getLong("assigned_vehicle_id");
                    assignedVehicleId = rs.wasNull() ? null : vehicleId;
                }
            }

            try (PreparedStatement pstmt = conn.prepareStatement(updateSql)) {
                pstmt.setLong(1, bookingId);
                isSuccess = pstmt.executeUpdate() > 0;
            }

            if (!isSuccess) {
                conn.rollback();
                return false;
            }

            if (assignedVehicleId != null) {
                releaseVehicle(conn, assignedVehicleId);
            }

            conn.commit();
        } catch (Exception e) {
            e.printStackTrace();
            rollbackQuietly(conn);
        } finally {
            closeQuietly(conn);
        }

        return isSuccess;
    }

    public boolean cancelPendingBookingForUser(long bookingId, long userId) {
        boolean isSuccess = false;
        String selectSql = "SELECT assigned_vehicle_id FROM bookings WHERE id = ? AND user_id = ? AND status = 'PENDING' FOR UPDATE";
        String updateSql = "UPDATE bookings SET status = 'CANCELLED', rejection_reason = NULL, updated_at = NOW() WHERE id = ? AND user_id = ? AND status = 'PENDING'";

        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);
            Long assignedVehicleId = null;

            try (PreparedStatement ps = conn.prepareStatement(selectSql)) {
                ps.setLong(1, bookingId);
                ps.setLong(2, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        conn.rollback();
                        return false;
                    }
                    long vehicleId = rs.getLong("assigned_vehicle_id");
                    assignedVehicleId = rs.wasNull() ? null : vehicleId;
                }
            }

            try (PreparedStatement pstmt = conn.prepareStatement(updateSql)) {
                pstmt.setLong(1, bookingId);
                pstmt.setLong(2, userId);
                isSuccess = pstmt.executeUpdate() > 0;
            }

            if (!isSuccess) {
                conn.rollback();
                return false;
            }

            if (assignedVehicleId != null) {
                releaseVehicle(conn, assignedVehicleId);
            }

            conn.commit();
        } catch (Exception e) {
            e.printStackTrace();
            rollbackQuietly(conn);
        } finally {
            closeQuietly(conn);
        }

        return isSuccess;
    }

    private Long insertBooking(Connection conn, BookingRequest booking) throws Exception {
        String query = "INSERT INTO bookings (request_code, user_id, trip_date, return_date, return_time, destination, booking_phone, passenger_count, vehicle_type, purpose, license_image_path, daily_rental_fee, late_fee_per_hour, estimated_rental_fee, assigned_vehicle_id, status, rejection_reason) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (PreparedStatement pstmt = conn.prepareStatement(query, PreparedStatement.RETURN_GENERATED_KEYS)) {

            pstmt.setString(1, booking.getRequestCode());
            pstmt.setLong(2, booking.getUserId());
            pstmt.setDate(3, java.sql.Date.valueOf(booking.getTripDate()));
            pstmt.setDate(4, java.sql.Date.valueOf(booking.getReturnDate()));
            pstmt.setTime(5, booking.getReturnTime() != null ? Time.valueOf(booking.getReturnTime()) : Time.valueOf("17:00:00"));
            pstmt.setString(6, booking.getDestination());
            pstmt.setString(7, booking.getBookerPhone());
            pstmt.setInt(8, booking.getPassengerCount());
            pstmt.setString(9, booking.getVehicleType().name());
            pstmt.setString(10, booking.getPurpose());
            pstmt.setString(11, booking.getLicenseImagePath());
            pstmt.setBigDecimal(12, normalizeMoney(booking.getDailyRentalFee()));
            pstmt.setBigDecimal(13, normalizeMoney(booking.getLateFeePerHour()));
            pstmt.setBigDecimal(14, normalizeMoney(booking.getEstimatedRentalFee()));
            if (booking.getAssignedVehicleId() == null) {
                pstmt.setNull(15, java.sql.Types.BIGINT);
            } else {
                pstmt.setLong(15, booking.getAssignedVehicleId());
            }
            pstmt.setString(16, booking.getStatus().name());
            pstmt.setString(17, booking.getRejectionReason());

            if (pstmt.executeUpdate() <= 0) {
                return null;
            }

            try (ResultSet keys = pstmt.getGeneratedKeys()) {
                if (keys.next()) {
                    return keys.getLong(1);
                }
            }
            return null;
        }
    }

    private Long reserveAvailableVehicle(Connection conn, String type) throws Exception {
        String selectSql = "SELECT id FROM vehicles WHERE status = 'AVAILABLE' AND type = ? ORDER BY id ASC LIMIT 1 FOR UPDATE";
        String updateSql = "UPDATE vehicles SET status = 'UNAVAILABLE', updated_at = NOW() WHERE id = ?";

        try (PreparedStatement select = conn.prepareStatement(selectSql)) {
            select.setString(1, type);
            try (ResultSet rs = select.executeQuery()) {
                if (!rs.next()) {
                    return null;
                }
                long vehicleId = rs.getLong("id");
                try (PreparedStatement update = conn.prepareStatement(updateSql)) {
                    update.setLong(1, vehicleId);
                    if (update.executeUpdate() <= 0) {
                        return null;
                    }
                }
                return vehicleId;
            }
        }
    }

    private void releaseVehicle(Connection conn, Long vehicleId) throws Exception {
        if (vehicleId == null) {
            return;
        }

        String releaseSql = "UPDATE vehicles SET status = 'AVAILABLE', updated_at = NOW() WHERE id = ?";
        try (PreparedStatement ps = conn.prepareStatement(releaseSql)) {
            ps.setLong(1, vehicleId);
            ps.executeUpdate();
        }
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

    private List<BookingRequest> collectRecentBookings(Connection conn, long userId, int limit) throws Exception {
        List<BookingRequest> bookings = new ArrayList<>();
        String query = "SELECT b.id, b.user_id, b.trip_date, b.return_date, b.return_time, b.destination, b.booking_phone, b.passenger_count, b.vehicle_type, b.purpose, b.license_image_path, b.daily_rental_fee, b.late_fee_per_hour, b.estimated_rental_fee, b.assigned_vehicle_id, b.status, b.rejection_reason, "
                + "u.name AS booker_name, u.email AS booker_email, u.phone AS booker_phone, u.role AS booker_role "
                + "FROM bookings b INNER JOIN users u ON u.userId = b.user_id WHERE b.user_id = ? ORDER BY b.created_at DESC, b.id DESC LIMIT ?";

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
        String bookingPhone = getStringIfPresent(rs, "booking_phone");
        if (bookingPhone == null || bookingPhone.trim().isEmpty()) {
            bookingPhone = getStringIfPresent(rs, "booker_phone");
        }
        booking.setBookerPhone(bookingPhone);
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
        booking.setBookerName(getStringIfPresent(rs, "booker_name"));
        booking.setBookerEmail(getStringIfPresent(rs, "booker_email"));
        booking.setBookerRole(getStringIfPresent(rs, "booker_role"));

        return booking;
    }

    private String getStringIfPresent(ResultSet rs, String column) {
        try {
            return rs.getString(column);
        } catch (Exception ignored) {
            return null;
        }
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
