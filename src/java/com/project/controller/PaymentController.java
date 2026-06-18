package com.project.controller;

import com.project.dao.BookingDAO;
import com.project.dao.PaymentDAO;
import com.project.model.BookingRequest;
import com.project.model.Payment;
import java.io.IOException;
import java.math.BigDecimal;
import java.net.URLEncoder;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/PaymentController")
public class PaymentController extends HttpServlet {

    private final BookingDAO bookingDAO = new BookingDAO();
    private final PaymentDAO paymentDAO = new PaymentDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Long userId = getCurrentUserId(request);
        if (!isStudentOrLecturer(request) || userId == null) {
            response.sendRedirect(request.getContextPath() + "/pages/login/login.jsp?error=unauthorized");
            return;
        }

        Long bookingId = parseLong(request.getParameter("id"));
        if (bookingId == null) {
            response.sendRedirect(request.getContextPath() + "/BookingController");
            return;
        }

        if (bookingDAO.getBookingByIdAndUserId(bookingId, userId) == null) {
            response.sendRedirect(request.getContextPath() + "/BookingController");
            return;
        }

        response.sendRedirect(request.getContextPath() + "/pages/user/payment.jsp?id=" + bookingId);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Long userId = getCurrentUserId(request);
        if (!isStudentOrLecturer(request) || userId == null) {
            response.sendRedirect(request.getContextPath() + "/pages/login/login.jsp?error=unauthorized");
            return;
        }

        Long bookingId = parseLong(request.getParameter("id"));
        if (bookingId == null) {
            response.sendRedirect(request.getContextPath() + "/BookingController");
            return;
        }

        BookingRequest booking = bookingDAO.getBookingByIdAndUserId(bookingId, userId);
        if (booking == null) {
            response.sendRedirect(request.getContextPath() + "/BookingController");
            return;
        }

        if (booking.getStatus() == null || booking.getStatus() != BookingRequest.Status.APPROVED) {
            redirectBack(request, response, bookingId, "error", "Payment is only available after the request is approved.");
            return;
        }

        Payment existing = paymentDAO.getPaymentByBookingId(bookingId);
        if (existing != null && "PAID".equalsIgnoreCase(existing.getPaymentStatus())) {
            redirectBack(request, response, bookingId, "exists", "Payment has already been completed for this booking.");
            return;
        }

        String paymentMethod = trim(request.getParameter("paymentMethod"));
        String payerName = trim(request.getParameter("payerName"));
        String payerEmail = trim(request.getParameter("payerEmail"));
        String payerPhone = trim(request.getParameter("payerPhone"));
        String cardNumber = trim(request.getParameter("cardNumber"));
        String cardExpiry = trim(request.getParameter("cardExpiry"));
        String cardCvv = trim(request.getParameter("cardCvv"));
        String billingAddress = trim(request.getParameter("billingAddress"));

        if (isBlank(paymentMethod) || isBlank(payerName) || isBlank(payerEmail)
                || isBlank(payerPhone) || isBlank(cardNumber) || isBlank(cardExpiry) || isBlank(cardCvv)) {
            redirectBack(request, response, bookingId, "error", "Please complete all required payment fields.");
            return;
        }

        Payment payment = new Payment();
        payment.setBookingId(bookingId);
        payment.setPayerUserId(userId);
        payment.setPaymentMethod(paymentMethod);
        payment.setAmountPaid(booking.getEstimatedRentalFee() == null ? BigDecimal.ZERO : booking.getEstimatedRentalFee());
        payment.setPaymentStatus("PAID");
        payment.setTransactionReference(generateTransactionReference(bookingId));
        payment.setPayerName(payerName);
        payment.setPayerEmail(payerEmail);
        payment.setPayerPhone(payerPhone);
        payment.setBillingAddress(billingAddress);

        if (paymentDAO.createPayment(payment)) {
            HttpSession session = request.getSession();
            session.setAttribute("message", "Payment completed successfully. Receipt reference: " + payment.getTransactionReference() + ".");
            session.setAttribute("messageType", "success");
            response.sendRedirect(request.getContextPath() + "/BookingController");
        } else {
            redirectBack(request, response, bookingId, "error", "Unable to save payment. Please try again.");
        }
    }

    private void redirectBack(HttpServletRequest request, HttpServletResponse response, Long bookingId, String status, String message)
            throws IOException {
        String redirect = request.getContextPath() + "/pages/user/payment.jsp?id=" + bookingId
                + "&status=" + URLEncoder.encode(status, "UTF-8")
                + "&message=" + URLEncoder.encode(message, "UTF-8");
        response.sendRedirect(redirect);
    }

    private Long getCurrentUserId(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        Object uid = session == null ? null : session.getAttribute("userId");
        return parseLong(uid == null ? null : uid.toString());
    }

    private boolean isStudentOrLecturer(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        String role = (session != null && session.getAttribute("role") instanceof String)
                ? ((String) session.getAttribute("role")).trim().toUpperCase()
                : null;
        return "STUDENT".equals(role) || "LECTURER".equals(role);
    }

    private Long parseLong(String value) {
        if (value == null || value.trim().isEmpty()) {
            return null;
        }
        try {
            long parsed = Long.parseLong(value.trim());
            return parsed > 0 ? parsed : null;
        } catch (NumberFormatException ex) {
            return null;
        }
    }

    private boolean isBlank(String value) {
        return value == null || value.trim().isEmpty();
    }

    private String trim(String value) {
        return value == null ? null : value.trim();
    }

    private String generateTransactionReference(long bookingId) {
        return "PMT-" + bookingId + "-" + System.currentTimeMillis();
    }
}
