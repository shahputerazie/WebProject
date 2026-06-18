package com.project.controller;

import com.project.dao.AdminDecisionDAO;
import com.project.dao.BookingDAO;
import com.project.dao.VehicleDAO;
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
        String action = request.getParameter("action");
        if ("detail".equalsIgnoreCase(action)) {
            showBookingDetail(request, response);
            return;
        }

        request.setAttribute("bookings", bookingDAO.getAllBookings());
        request.setAttribute("availableVehicles", new VehicleDAO().getVehiclesByStatus("AVAILABLE"));
        request.setAttribute("sidebarActive", "admin");
        request.getRequestDispatcher("/pages/admin/adminDashboard.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        Object rawAdminId = session.getAttribute("userId");
        String adminId = (rawAdminId == null) ? null : String.valueOf(rawAdminId);
        
        String action = request.getParameter("action");
        Long bookingId = Long.parseLong(request.getParameter("bookingId"));
        
        boolean success = false;
        String message = "";

        switch (action) {
            case "APPROVE":
                success = adminDAO.approveBookingWithVehicle(bookingId, null);
                message = success ? "Booking approved and reserved vehicle confirmed." : "Failed to approve booking. Check the reserved vehicle and booking status.";
                break;
            case "REJECT":
                String rejectionReason = request.getParameter("rejectionReason");
                if (rejectionReason == null || rejectionReason.trim().isEmpty()) {
                    message = "Please provide a rejection reason.";
                    break;
                }
                success = adminDAO.updateBookingStatus(bookingId, BookingRequest.Status.REJECTED, rejectionReason);
                message = success ? "Booking rejected with reason saved." : "Failed to reject booking.";
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
                if (adminId == null) {
                    message = "Unable to identify the admin account.";
                    break;
                }
                HandoverRecord record = adminDAO.generateHandoverPass(bookingId, adminId);
                success = (record != null);
                message = success ? "Handover Pass Generated: " + record.getPassCode() : "Failed to generate pass.";
                break;
        }

        session.setAttribute(success ? "successMsg" : "errorMsg", message);
        response.sendRedirect(request.getContextPath() + "/admin/decisions");
    }

    private void showBookingDetail(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        Long bookingId = parseLong(request.getParameter("bookingId"));
        if (bookingId == null) {
            response.sendRedirect(request.getContextPath() + "/admin/decisions");
            return;
        }

        BookingRequest booking = bookingDAO.getBookingById(bookingId);
        if (booking == null) {
            response.sendRedirect(request.getContextPath() + "/admin/decisions");
            return;
        }

        request.setAttribute("booking", booking);
        request.setAttribute("sidebarActive", "admin");
        request.getRequestDispatcher("/pages/admin/bookingReview.jsp").forward(request, response);
    }

    private Long parseLong(String value) {
        if (value == null || value.trim().isEmpty()) {
            return null;
        }
        try {
            return Long.parseLong(value.trim());
        } catch (NumberFormatException ex) {
            return null;
        }
    }
}
