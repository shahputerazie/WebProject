package com.project.controller;

import com.project.dao.AdminDecisionDAO;
import com.project.dao.BookingDAO;
import com.project.model.BookingRequest;
import com.project.model.HandoverRecord;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/admin/decisions")
public class AdminDecisionController extends HttpServlet {
    
    private final AdminDecisionDAO adminDAO = new AdminDecisionDAO();
    private final BookingDAO bookingDAO = new BookingDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Fetch all bookings for the admin dashboard
        request.setAttribute("bookings", bookingDAO.getAllBookings());
        request.getRequestDispatcher("/WEB-INF/views/admin-dashboard.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        String adminId = (String) session.getAttribute("userId"); // Assuming admin is logged in
        
        String action = request.getParameter("action");
        Long bookingId = Long.parseLong(request.getParameter("bookingId"));
        
        boolean success = false;
        String message = "";

        switch (action) {
            case "APPROVE":
                success = adminDAO.updateBookingStatus(bookingId, BookingRequest.Status.APPROVED);
                message = success ? "Booking approved successfully." : "Failed to approve booking.";
                break;
            case "REJECT":
                success = adminDAO.updateBookingStatus(bookingId, BookingRequest.Status.REJECTED);
                message = success ? "Booking rejected." : "Failed to reject booking.";
                break;
            case "COMPLETE":
                // Assuming you add COMPLETED to your Status enum
                success = adminDAO.updateBookingStatus(bookingId, BookingRequest.Status.valueOf("COMPLETED"));
                message = success ? "Booking marked as completed." : "Failed to complete booking.";
                break;
            case "REVOKE":
                success = adminDAO.revokeApproval(bookingId);
                message = success ? "Approval revoked and cancelled." : "Failed to revoke approval.";
                break;
            case "GENERATE_HANDOVER":
                HandoverRecord record = adminDAO.generateHandoverPass(bookingId, adminId);
                success = (record != null);
                message = success ? "Handover Pass Generated: " + record.getPassCode() : "Failed to generate pass.";
                break;
        }

        session.setAttribute(success ? "successMsg" : "errorMsg", message);
        response.sendRedirect(request.getContextPath() + "/admin/decisions");
    }
}