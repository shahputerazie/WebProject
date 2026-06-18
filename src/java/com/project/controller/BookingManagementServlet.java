package com.project.controller;

import com.project.dao.BookingDAO;
import com.project.dao.AdminDecisionDAO;
import com.project.model.BookingRequest;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet("/staff/manage-bookings")
public class BookingManagementServlet extends HttpServlet {

    private BookingDAO bookingDAO = new BookingDAO();
    private AdminDecisionDAO adminDecisionDAO = new AdminDecisionDAO();

    // GET: Display all bookings for the Staff to review
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        List<BookingRequest> allBookings = bookingDAO.getAllBookings();
        request.setAttribute("bookings", allBookings);
        request.getRequestDispatcher("/pages/staff/fleetList.jsp").forward(request, response);
    }

    // POST: Handle Approval or Rejection
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action"); // "APPROVE" or "REJECT"
        long bookingId = Long.parseLong(request.getParameter("bookingId"));

        boolean success = false;
        if ("APPROVE".equals(action)) {
            success = adminDecisionDAO.approveBookingWithVehicle(bookingId, null);
        } else if ("REJECT".equals(action)) {
            String rejectionReason = request.getParameter("rejectionReason");
            if (rejectionReason == null || rejectionReason.trim().isEmpty()) {
                request.getSession().setAttribute("error", "Rejection reason is required.");
                response.sendRedirect(request.getContextPath() + "/staff/manage-bookings");
                return;
            }
            success = bookingDAO.updateBookingStatus(bookingId, "REJECTED", rejectionReason);
        }

        if (success) {
            request.getSession().setAttribute("message", "Booking status updated successfully!");
        } else {
            request.getSession().setAttribute("error", "Failed to update status.");
        }

        response.sendRedirect(request.getContextPath() + "/staff/manage-bookings");
    }
}
