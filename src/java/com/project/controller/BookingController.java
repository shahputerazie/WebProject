package com.project.controller;

import com.project.dao.BookingDAO;
import com.project.model.BookingRequest;

import java.io.IOException;
import java.time.LocalDate;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class BookingController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        if ("detail".equalsIgnoreCase(action)) {
            showBookingDetail(request, response);
            return;
        }
        response.sendRedirect(request.getContextPath() + "/pages/user/bookingRequest.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        String action = request.getParameter("action");
        if ("update".equalsIgnoreCase(action)) {
            updateBooking(request, response);
            return;
        }
        submitBooking(request, response);
    }

    private void submitBooking(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        Long userId = getCurrentUserId(request);
        if (userId == null) {
            response.sendRedirect(request.getContextPath() + "/pages/user/bookingRequest.jsp?error=auth_required");
            return;
        }

        String tripDateParam = request.getParameter("tripDate");
        String returnDateParam = request.getParameter("returnDate");
        String destination = request.getParameter("destination");
        String passengerCountParam = request.getParameter("passengerCount");
        String vehicleTypeParam = request.getParameter("vehicleType");
        String purpose = request.getParameter("purpose");

        if (isBlank(tripDateParam) || isBlank(returnDateParam) || isBlank(destination)
                || isBlank(passengerCountParam) || isBlank(vehicleTypeParam) || isBlank(purpose)) {
            response.sendRedirect(request.getContextPath() + "/pages/user/bookingRequest.jsp?error=missing_fields");
            return;
        }

        try {
            LocalDate tripDate = LocalDate.parse(tripDateParam);
            LocalDate returnDate = LocalDate.parse(returnDateParam);
            int passengerCount = Integer.parseInt(passengerCountParam);

            if (returnDate.isBefore(tripDate) || passengerCount <= 0) {
                response.sendRedirect(request.getContextPath() + "/pages/user/bookingRequest.jsp?error=invalid_input");
                return;
            }

            BookingRequest newBooking = new BookingRequest(
                    tripDate,
                    returnDate,
                    destination.trim(),
                    passengerCount,
                    BookingRequest.VehicleType.valueOf(vehicleTypeParam),
                    purpose.trim(),
                    BookingRequest.Status.PENDING
            );
            newBooking.setUserId(userId);

            BookingDAO dao = new BookingDAO();
            boolean isAdded = dao.addBooking(newBooking);

            if (isAdded) {
                response.sendRedirect(request.getContextPath() + "/pages/user/userDashboard.jsp?success=true");
            } else {
                response.sendRedirect(request.getContextPath() + "/pages/user/bookingRequest.jsp?error=db");
            }

        } catch (IllegalArgumentException ex) {
            response.sendRedirect(request.getContextPath() + "/pages/user/bookingRequest.jsp?error=invalid_input");
        }
    }

    private void showBookingDetail(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Long userId = getCurrentUserId(request);

        Long bookingId = parseBookingId(request.getParameter("id"));
        if (bookingId == null) {
            response.sendRedirect(request.getContextPath() + "/pages/user/bookingRequest.jsp?error=invalid_id");
            return;
        }

        BookingDAO dao = new BookingDAO();
        BookingRequest booking = userId == null
                ? dao.getBookingById(bookingId)
                : dao.getBookingByIdAndUserId(bookingId, userId);
        if (booking == null) {
            response.sendRedirect(request.getContextPath() + "/pages/user/bookingRequest.jsp?error=not_found");
            return;
        }

        boolean canModify = booking.getStatus() == BookingRequest.Status.PENDING;
        request.setAttribute("booking", booking);
        request.setAttribute("canModify", canModify);
        request.getRequestDispatcher("/pages/user/bookingDetail.jsp").forward(request, response);
    }

    private void updateBooking(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        Long userId = getCurrentUserId(request);

        Long bookingId = parseBookingId(request.getParameter("id"));
        if (bookingId == null) {
            response.sendRedirect(request.getContextPath() + "/pages/user/bookingRequest.jsp?error=invalid_id");
            return;
        }

        String tripDateParam = request.getParameter("tripDate");
        String returnDateParam = request.getParameter("returnDate");
        String destination = request.getParameter("destination");
        String passengerCountParam = request.getParameter("passengerCount");
        String vehicleTypeParam = request.getParameter("vehicleType");
        String purpose = request.getParameter("purpose");

        if (isBlank(tripDateParam) || isBlank(returnDateParam) || isBlank(destination)
                || isBlank(passengerCountParam) || isBlank(vehicleTypeParam) || isBlank(purpose)) {
            response.sendRedirect(request.getContextPath() + "/SubmitBooking?action=detail&id=" + bookingId + "&error=missing_fields");
            return;
        }

        BookingDAO dao = new BookingDAO();
        BookingRequest existingBooking = userId == null
                ? dao.getBookingById(bookingId)
                : dao.getBookingByIdAndUserId(bookingId, userId);
        if (existingBooking == null) {
            response.sendRedirect(request.getContextPath() + "/pages/user/bookingRequest.jsp?error=not_found");
            return;
        }
        if (existingBooking.getStatus() != BookingRequest.Status.PENDING) {
            response.sendRedirect(request.getContextPath() + "/SubmitBooking?action=detail&id=" + bookingId + "&error=readonly");
            return;
        }

        try {
            LocalDate tripDate = LocalDate.parse(tripDateParam);
            LocalDate returnDate = LocalDate.parse(returnDateParam);
            int passengerCount = Integer.parseInt(passengerCountParam);

            if (returnDate.isBefore(tripDate) || passengerCount <= 0) {
                response.sendRedirect(request.getContextPath() + "/SubmitBooking?action=detail&id=" + bookingId + "&error=invalid_input");
                return;
            }

            BookingRequest updatedBooking = new BookingRequest();
            updatedBooking.setId(bookingId);
            updatedBooking.setTripDate(tripDate);
            updatedBooking.setReturnDate(returnDate);
            updatedBooking.setDestination(destination.trim());
            updatedBooking.setPassengerCount(passengerCount);
            updatedBooking.setVehicleType(BookingRequest.VehicleType.valueOf(vehicleTypeParam));
            updatedBooking.setPurpose(purpose.trim());

            boolean isUpdated = userId == null
                    ? dao.updatePendingBooking(updatedBooking)
                    : dao.updatePendingBookingForUser(updatedBooking, userId);
            if (isUpdated) {
                response.sendRedirect(request.getContextPath() + "/SubmitBooking?action=detail&id=" + bookingId + "&success=updated");
            } else {
                response.sendRedirect(request.getContextPath() + "/SubmitBooking?action=detail&id=" + bookingId + "&error=update_failed");
            }
        } catch (IllegalArgumentException ex) {
            response.sendRedirect(request.getContextPath() + "/SubmitBooking?action=detail&id=" + bookingId + "&error=invalid_input");
        }
    }

    private boolean isBlank(String value) {
        return value == null || value.trim().isEmpty();
    }

    private Long parseBookingId(String idParam) {
        if (isBlank(idParam)) {
            return null;
        }
        try {
            long id = Long.parseLong(idParam.trim());
            return id > 0 ? id : null;
        } catch (NumberFormatException ex) {
            return null;
        }
    }

    private Long getCurrentUserId(HttpServletRequest request) {
        Object rawUserId = request.getSession(false) == null ? null : request.getSession(false).getAttribute("userId");
        if (rawUserId == null) {
            return null;
        }
        if (rawUserId instanceof Number) {
            long value = ((Number) rawUserId).longValue();
            return value > 0 ? value : null;
        }
        try {
            long value = Long.parseLong(rawUserId.toString().trim());
            return value > 0 ? value : null;
        } catch (NumberFormatException ex) {
            return null;
        }
    }
}
