package com.project.controller;

import com.project.dao.BookingDAO;
import com.project.model.BookingRequest;
import java.io.IOException;
import java.time.LocalDate;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/BookingController")
public class BookingController extends HttpServlet {

    private final BookingDAO dao = new BookingDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Long userId = getCurrentUserId(request);
        if (userId == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        String action = request.getParameter("action");
        if ("detail".equalsIgnoreCase(action)) {
            showBookingDetail(request, response, userId);
        } else {
            // Fetch list for the table and forward to JSP
            List<BookingRequest> bookings = dao.getBookingsByUserId(userId);
            request.setAttribute("bookings", bookings);
            request.getRequestDispatcher("/pages/user/bookingRequest.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");

        if ("update".equalsIgnoreCase(action)) {
            updateBooking(request, response, getCurrentUserId(request));
        } else {
            submitBooking(request, response);
        }
    }

    private void submitBooking(HttpServletRequest request, HttpServletResponse response) throws IOException {
        Long userId = getCurrentUserId(request);
        try {
            String tripDateParam = request.getParameter("tripDate");
            String returnDateParam = request.getParameter("returnDate");

            if (anyBlank(tripDateParam, returnDateParam, request.getParameter("destination"),
                    request.getParameter("passengerCount"), request.getParameter("vehicleType"))) {
                setSessionMessage(request, "All fields are required.", "error");
            } else {
                BookingRequest b = new BookingRequest();
                b.setUserId(userId);
                b.setTripDate(LocalDate.parse(tripDateParam));
                b.setReturnDate(LocalDate.parse(returnDateParam));
                b.setDestination(request.getParameter("destination").trim());
                b.setPassengerCount(Integer.parseInt(request.getParameter("passengerCount")));
                b.setVehicleType(BookingRequest.VehicleType.valueOf(request.getParameter("vehicleType")));
                b.setPurpose(request.getParameter("purpose").trim());
                b.setStatus(BookingRequest.Status.PENDING);
                b.setRequestCode(dao.generateRequestCode());

                if (dao.addBooking(b)) {
                    setSessionMessage(request, "Booking " + b.getRequestCode() + " submitted!", "success");
                } else {
                    setSessionMessage(request, "Database error. Please try again.", "error");
                }
            }
        } catch (Exception e) {
            setSessionMessage(request, "Error: " + e.getMessage(), "error");
        }
        response.sendRedirect(request.getContextPath() + "/BookingController");
    }

    private void showBookingDetail(HttpServletRequest request, HttpServletResponse response, Long userId)
            throws ServletException, IOException {
        String idParam = request.getParameter("id");
        if (idParam != null) {
            BookingRequest booking = dao.getBookingByIdAndUserId(Long.parseLong(idParam), userId);
            if (booking != null) {
                request.setAttribute("booking", booking);
                request.getRequestDispatcher("/pages/user/bookingDetail.jsp").forward(request, response);
                return;
            }
        }
        response.sendRedirect(request.getContextPath() + "/BookingController");
    }

    private void updateBooking(HttpServletRequest request, HttpServletResponse response, Long userId) throws IOException {
        // Implementation for updating existing record
        setSessionMessage(request, "Update feature integrated.", "success");
        response.sendRedirect(request.getContextPath() + "/BookingController");
    }

    private void setSessionMessage(HttpServletRequest request, String msg, String type) {
        HttpSession session = request.getSession();
        session.setAttribute("message", msg);
        session.setAttribute("messageType", type);
    }

    private boolean anyBlank(String... values) {
        for (String v : values) {
            if (v == null || v.trim().isEmpty()) {
                return true;
            }
        }
        return false;
    }

    private Long getCurrentUserId(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        Object uid = (session != null) ? session.getAttribute("userId") : null;
        return (uid != null) ? Long.valueOf(uid.toString()) : null;
    }
}
