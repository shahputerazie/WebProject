package com.project.dao;

import com.project.model.BookingRequest;
import java.sql.Date;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class BookingDAO {

    public boolean addBooking(BookingRequest booking) {
        boolean isSuccess = false;
        if (booking == null || booking.getUserId() == null || booking.getUserId() <= 0) {
            return false;
        }

        String query = "INSERT INTO bookings (user_id, trip_date, return_date, destination, passenger_count, vehicle_type, purpose, status) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement pstmt = conn.prepareStatement(query)) {

            pstmt.setLong(1, booking.getUserId());
            pstmt.setDate(2, java.sql.Date.valueOf(booking.getTripDate()));
            pstmt.setDate(3, java.sql.Date.valueOf(booking.getReturnDate()));
            pstmt.setString(4, booking.getDestination());
            pstmt.setInt(5, booking.getPassengerCount());
            pstmt.setString(6, booking.getVehicleType().name());
            pstmt.setString(7, booking.getPurpose());
            pstmt.setString(8, booking.getStatus().name());

            isSuccess = pstmt.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }

        return isSuccess;
    }

    public List<BookingRequest> getAllBookings() {
        List<BookingRequest> bookings = new ArrayList<>();
        String query = "SELECT id, user_id, trip_date, return_date, destination, passenger_count, vehicle_type, purpose, status "
                + "FROM bookings ORDER BY created_at DESC, id DESC";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement pstmt = conn.prepareStatement(query);
                ResultSet rs = pstmt.executeQuery()) {

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
        String query = "SELECT id, user_id, trip_date, return_date, destination, passenger_count, vehicle_type, purpose, status "
                + "FROM bookings WHERE user_id = ? ORDER BY created_at DESC, id DESC";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement pstmt = conn.prepareStatement(query)) {
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

    public BookingRequest getBookingById(long id) {
        BookingRequest booking = null;
        String query = "SELECT id, user_id, trip_date, return_date, destination, passenger_count, vehicle_type, purpose, status "
                + "FROM bookings WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement pstmt = conn.prepareStatement(query)) {
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
        String query = "SELECT id, user_id, trip_date, return_date, destination, passenger_count, vehicle_type, purpose, status "
                + "FROM bookings WHERE id = ? AND user_id = ?";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement pstmt = conn.prepareStatement(query)) {
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

    public boolean updatePendingBooking(BookingRequest booking) {
        boolean isSuccess = false;
        String query = "UPDATE bookings SET trip_date = ?, return_date = ?, destination = ?, passenger_count = ?, "
                + "vehicle_type = ?, purpose = ? WHERE id = ? AND status = 'PENDING'";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement pstmt = conn.prepareStatement(query)) {
            pstmt.setDate(1, java.sql.Date.valueOf(booking.getTripDate()));
            pstmt.setDate(2, java.sql.Date.valueOf(booking.getReturnDate()));
            pstmt.setString(3, booking.getDestination());
            pstmt.setInt(4, booking.getPassengerCount());
            pstmt.setString(5, booking.getVehicleType().name());
            pstmt.setString(6, booking.getPurpose());
            pstmt.setLong(7, booking.getId());

            isSuccess = pstmt.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }

        return isSuccess;
    }

    public boolean updatePendingBookingForUser(BookingRequest booking, long userId) {
        boolean isSuccess = false;
        String query = "UPDATE bookings SET trip_date = ?, return_date = ?, destination = ?, passenger_count = ?, "
                + "vehicle_type = ?, purpose = ? WHERE id = ? AND user_id = ? AND status = 'PENDING'";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement pstmt = conn.prepareStatement(query)) {
            pstmt.setDate(1, java.sql.Date.valueOf(booking.getTripDate()));
            pstmt.setDate(2, java.sql.Date.valueOf(booking.getReturnDate()));
            pstmt.setString(3, booking.getDestination());
            pstmt.setInt(4, booking.getPassengerCount());
            pstmt.setString(5, booking.getVehicleType().name());
            pstmt.setString(6, booking.getPurpose());
            pstmt.setLong(7, booking.getId());
            pstmt.setLong(8, userId);

            isSuccess = pstmt.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }

        return isSuccess;
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

        booking.setDestination(rs.getString("destination"));
        booking.setPassengerCount(rs.getInt("passenger_count"));

        String vehicleType = rs.getString("vehicle_type");
        if (vehicleType != null && !vehicleType.trim().isEmpty()) {
            try {
                booking.setVehicleType(BookingRequest.VehicleType.valueOf(vehicleType.trim().toUpperCase()));
            } catch (IllegalArgumentException ignored) {
                booking.setVehicleType(null);
            }
        }

        booking.setPurpose(rs.getString("purpose"));

        String status = rs.getString("status");
        if (status != null && !status.trim().isEmpty()) {
            try {
                booking.setStatus(BookingRequest.Status.valueOf(status.trim().toUpperCase()));
            } catch (IllegalArgumentException ignored) {
                booking.setStatus(null);
            }
        }

        return booking;
    }
}
