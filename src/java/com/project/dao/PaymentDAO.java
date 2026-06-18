package com.project.dao;

import com.project.model.Payment;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

public class PaymentDAO {

    public Set<Long> getPaidBookingIds(List<Long> bookingIds) {
        Set<Long> paidIds = new HashSet<>();
        if (bookingIds == null || bookingIds.isEmpty()) {
            return paidIds;
        }

        StringBuilder placeholders = new StringBuilder();
        for (int i = 0; i < bookingIds.size(); i++) {
            placeholders.append(i == 0 ? "?" : ",?");
        }
        String query = "SELECT booking_id FROM payments WHERE payment_status = 'PAID' AND booking_id IN (" + placeholders + ")";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement pstmt = conn.prepareStatement(query)) {
            for (int i = 0; i < bookingIds.size(); i++) {
                pstmt.setLong(i + 1, bookingIds.get(i));
            }
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    paidIds.add(rs.getLong("booking_id"));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return paidIds;
    }

    public Payment getPaymentByBookingId(long bookingId) {
        String query = "SELECT id, booking_id, payer_user_id, payment_method, amount_paid, payment_status, transaction_reference, "
                + "payer_name, payer_email, payer_phone, billing_address, paid_at, created_at, updated_at "
                + "FROM payments WHERE booking_id = ?";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement pstmt = conn.prepareStatement(query)) {
            pstmt.setLong(1, bookingId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return mapPayment(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }

    public boolean createPayment(Payment payment) {
        if (payment == null || payment.getBookingId() == null || payment.getPayerUserId() == null) {
            return false;
        }

        String query = "INSERT INTO payments (booking_id, payer_user_id, payment_method, amount_paid, payment_status, "
                + "transaction_reference, payer_name, payer_email, payer_phone, billing_address, paid_at) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement pstmt = conn.prepareStatement(query)) {
            pstmt.setLong(1, payment.getBookingId());
            pstmt.setLong(2, payment.getPayerUserId());
            pstmt.setString(3, payment.getPaymentMethod());
            pstmt.setBigDecimal(4, normalizeMoney(payment.getAmountPaid()));
            pstmt.setString(5, payment.getPaymentStatus());
            pstmt.setString(6, payment.getTransactionReference());
            pstmt.setString(7, payment.getPayerName());
            pstmt.setString(8, payment.getPayerEmail());
            pstmt.setString(9, payment.getPayerPhone());
            if (payment.getBillingAddress() == null || payment.getBillingAddress().trim().isEmpty()) {
                pstmt.setNull(10, java.sql.Types.LONGVARCHAR);
            } else {
                pstmt.setString(10, payment.getBillingAddress().trim());
            }
            return pstmt.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    private Payment mapPayment(ResultSet rs) throws Exception {
        Payment payment = new Payment();
        payment.setId(rs.getLong("id"));
        payment.setBookingId(rs.getLong("booking_id"));
        payment.setPayerUserId(rs.getLong("payer_user_id"));
        payment.setPaymentMethod(rs.getString("payment_method"));
        payment.setAmountPaid(rs.getBigDecimal("amount_paid"));
        payment.setPaymentStatus(rs.getString("payment_status"));
        payment.setTransactionReference(rs.getString("transaction_reference"));
        payment.setPayerName(rs.getString("payer_name"));
        payment.setPayerEmail(rs.getString("payer_email"));
        payment.setPayerPhone(rs.getString("payer_phone"));
        payment.setBillingAddress(rs.getString("billing_address"));

        Timestamp paidAt = rs.getTimestamp("paid_at");
        if (paidAt != null) {
            payment.setPaidAt(paidAt.toLocalDateTime());
        }
        Timestamp createdAt = rs.getTimestamp("created_at");
        if (createdAt != null) {
            payment.setCreatedAt(createdAt.toLocalDateTime());
        }
        Timestamp updatedAt = rs.getTimestamp("updated_at");
        if (updatedAt != null) {
            payment.setUpdatedAt(updatedAt.toLocalDateTime());
        }

        return payment;
    }

    private BigDecimal normalizeMoney(BigDecimal value) {
        return value == null ? BigDecimal.ZERO.setScale(2, java.math.RoundingMode.HALF_UP)
                : value.setScale(2, java.math.RoundingMode.HALF_UP);
    }
}
