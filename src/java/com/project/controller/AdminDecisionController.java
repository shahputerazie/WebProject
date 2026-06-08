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
        // Fetch all bookings for the admin dashboard
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
        Long vehicleId = null;
        String vehicleIdParam = request.getParameter("vehicleId");
        if (vehicleIdParam != null && !vehicleIdParam.trim().isEmpty()) {
            try {
                vehicleId = Long.valueOf(vehicleIdParam.trim());
            } catch (NumberFormatException ignored) {
                vehicleId = null;
            }
        }
        
        boolean success = false;
        String message = "";

        switch (action) {
            case "APPROVE":
                if (vehicleId == null) {
                    message = "Please select an available vehicle before approving.";
                    break;
                }
                success = adminDAO.approveBookingWithVehicle(bookingId, vehicleId);
                message = success ? "Booking approved and vehicle assigned." : "Failed to approve booking. Check vehicle availability and type.";
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
}
