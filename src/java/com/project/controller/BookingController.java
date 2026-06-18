package com.project.controller;

import com.project.dao.BookingDAO;
import com.project.dao.BookingDAO.BookingDashboardData;
import com.project.dao.BookingDAO.BookingStats;
import com.project.dao.PaymentDAO;
import com.project.dao.VehicleDAO;
import com.project.model.BookingRequest;
import java.io.IOException;
import java.io.InputStream;
import java.math.BigDecimal;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;

@WebServlet("/BookingController")
@MultipartConfig(maxFileSize = 5 * 1024 * 1024, maxRequestSize = 10 * 1024 * 1024)
public class BookingController extends HttpServlet {

    private final BookingDAO dao = new BookingDAO();
    private final VehicleDAO vehicleDAO = new VehicleDAO();
    private final PaymentDAO paymentDAO = new PaymentDAO();
    private static final LocalTime RETURN_WINDOW_END = LocalTime.of(22, 0);
    private static final BigDecimal LATE_FEE_PER_HOUR = new BigDecimal("25.00");

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!isStudentOrLecturer(request)) {
            response.sendRedirect(request.getContextPath() + "/pages/login/login.jsp?error=unauthorized");
            return;
        }
        Long userId = getCurrentUserId(request);
        if (userId == null) {
            response.sendRedirect(request.getContextPath() + "/pages/login/login.jsp");
            return;
        }

        String action = request.getParameter("action");
        if ("detail".equalsIgnoreCase(action)) {
            showBookingDetail(request, response, userId);
        } else {
            BookingDashboardData dashboardData = dao.getBookingDashboardDataByUserId(userId, 8);
            BookingStats stats = dashboardData.getStats();
            int availableSedanCount = vehicleDAO.countAvailableVehiclesByType("SEDAN");
            int availableSuvCount = vehicleDAO.countAvailableVehiclesByType("SUV");
            String defaultVehicleType = availableSedanCount > 0 ? "SEDAN" : (availableSuvCount > 0 ? "SUV" : null);
            List<BookingRequest> recentBookings = dashboardData.getRecentBookings();
            List<Long> bookingIds = new ArrayList<>();
            for (BookingRequest booking : recentBookings) {
                bookingIds.add(booking.getId());
            }
            request.setAttribute("bookings", recentBookings);
            request.setAttribute("paidBookingIds", paymentDAO.getPaidBookingIds(bookingIds));
            request.setAttribute("bookingTotalCount", stats.getTotalRequests());
            request.setAttribute("bookingPendingCount", stats.getPendingRequests());
            request.setAttribute("bookingApprovedCount", stats.getApprovedRequests());
            request.setAttribute("bookingCompletedCount", stats.getCompletedRequests());
            request.setAttribute("bookingRejectedCount", stats.getRejectedRequests());
            request.setAttribute("bookingCancelledCount", stats.getCancelledRequests());
            request.setAttribute("bookingRecentLimit", 8);
            request.setAttribute("availableSedanCount", availableSedanCount);
            request.setAttribute("availableSuvCount", availableSuvCount);
            request.setAttribute("hasAvailableVehicle", availableSedanCount > 0 || availableSuvCount > 0);
            request.setAttribute("defaultVehicleType", defaultVehicleType);
            request.getRequestDispatcher("/pages/user/bookingRequest.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!isStudentOrLecturer(request)) {
            response.sendRedirect(request.getContextPath() + "/pages/login/login.jsp?error=unauthorized");
            return;
        }
        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");

        if ("update".equalsIgnoreCase(action)) {
            updateBooking(request, response, getCurrentUserId(request));
        } else if ("cancel".equalsIgnoreCase(action)) {
            cancelBooking(request, response, getCurrentUserId(request));
        } else {
            submitBooking(request, response);
        }
    }

    private void submitBooking(HttpServletRequest request, HttpServletResponse response) throws IOException {
        Long userId = getCurrentUserId(request);
        try {
            String tripDateParam = request.getParameter("tripDate");
            String returnDateParam = request.getParameter("returnDate");
            String bookingPhoneParam = request.getParameter("bookingPhone");
            String vehicleTypeParam = request.getParameter("vehicleType");
            Part licensePart = request.getPart("licenseImage");

            if (anyBlank(tripDateParam, returnDateParam, request.getParameter("destination"),
                    bookingPhoneParam, request.getParameter("passengerCount"), vehicleTypeParam, request.getParameter("purpose"))) {
                setSessionMessage(request, "All fields are required, including the license photo.", "error");
            } else if (licensePart == null || licensePart.getSize() == 0) {
                setSessionMessage(request, "Please upload a clear picture of the student license card.", "error");
            } else {
                LocalDate tripDate = LocalDate.parse(tripDateParam);
                LocalDate returnDate = LocalDate.parse(returnDateParam);
                LocalTime returnTime = RETURN_WINDOW_END;

                LocalDate today = LocalDate.now();
                if (tripDate.isBefore(today)) {
                    setSessionMessage(request, "Trip date cannot be before today.", "error");
                } else if (returnDate.isBefore(tripDate)) {
                    setSessionMessage(request, "Return date must be on or after the trip date.", "error");
                } else {
                    BookingRequest.VehicleType vehicleType = BookingRequest.VehicleType.valueOf(vehicleTypeParam);
                    int passengerCount = getPassengerPreset(vehicleType);
                    BigDecimal dailyRate = getDailyRate(vehicleType);
                    long rentalDays = calculateRentalDays(tripDate, returnDate);
                    BigDecimal estimatedFee = dailyRate.multiply(BigDecimal.valueOf(rentalDays)).setScale(2, java.math.RoundingMode.HALF_UP);
                    String licenseImagePath = saveLicenseImage(request, licensePart, userId);

                    if (licenseImagePath == null) {
                        setSessionMessage(request, "Unable to save the license card image. Please try again.", "error");
                    } else {
                        BookingRequest b = new BookingRequest();
                        b.setUserId(userId);
                        b.setTripDate(tripDate);
                        b.setReturnDate(returnDate);
                        b.setReturnTime(returnTime);
                        b.setDestination(request.getParameter("destination").trim());
                        b.setBookerPhone(bookingPhoneParam.trim());
                        b.setPassengerCount(passengerCount);
                        b.setVehicleType(vehicleType);
                        b.setPurpose(request.getParameter("purpose").trim());
                        b.setLicenseImagePath(licenseImagePath);
                        b.setDailyRentalFee(dailyRate);
                        b.setLateFeePerHour(LATE_FEE_PER_HOUR);
                        b.setEstimatedRentalFee(estimatedFee);
                        b.setStatus(BookingRequest.Status.PENDING);
                        b.setRequestCode(dao.generateRequestCode());

                        Long bookingId = dao.addBookingWithAutoAssignment(b);
                        if (bookingId != null) {
                            setSessionMessage(request,
                                    "Booking request submitted successfully. You can pay after staff approves it.",
                                    "success");
                            response.sendRedirect(request.getContextPath() + "/BookingController");
                            return;
                        } else {
                            setSessionMessage(request, "No available vehicle matches the selected type right now. Please try again later.", "error");
                        }
                    }
                }
            }
        } catch (IllegalArgumentException ex) {
            setSessionMessage(request, "Invalid vehicle type.", "error");
        } catch (Exception e) {
            setSessionMessage(request, "Error: " + e.getMessage(), "error");
        }
        response.sendRedirect(request.getContextPath() + "/BookingController");
    }

    private void showBookingDetail(HttpServletRequest request, HttpServletResponse response, Long userId)
            throws ServletException, IOException {
        String idParam = request.getParameter("id");
        if (idParam == null || idParam.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/BookingController");
            return;
        }

        long bookingId;
        try {
            bookingId = Long.parseLong(idParam);
        } catch (NumberFormatException ex) {
            response.sendRedirect(request.getContextPath() + "/BookingController");
            return;
        }

        BookingRequest booking = dao.getBookingByIdAndUserId(bookingId, userId);
        if (booking != null) {
            request.setAttribute("booking", booking);
            request.setAttribute("canModify", booking.getStatus() == BookingRequest.Status.PENDING);
            request.getRequestDispatcher("/pages/user/bookingDetail.jsp").forward(request, response);
            return;
        }
        response.sendRedirect(request.getContextPath() + "/BookingController");
    }

    private void updateBooking(HttpServletRequest request, HttpServletResponse response, Long userId) throws IOException {
        try {
            long bookingId = Long.parseLong(request.getParameter("id"));
            BookingRequest existing = dao.getBookingByIdAndUserId(bookingId, userId);
            if (existing == null || existing.getStatus() != BookingRequest.Status.PENDING) {
                setSessionMessage(request, "Only pending bookings can be updated.", "error");
                response.sendRedirect(request.getContextPath() + "/BookingController");
                return;
            }

            String tripDateParam = request.getParameter("tripDate");
            String returnDateParam = request.getParameter("returnDate");
            String vehicleTypeParam = request.getParameter("vehicleType");

            if (anyBlank(tripDateParam, returnDateParam, request.getParameter("destination"),
                    request.getParameter("passengerCount"), vehicleTypeParam, request.getParameter("purpose"))) {
                setSessionMessage(request, "Please fill in all required fields.", "error");
            } else {
                LocalDate tripDate = LocalDate.parse(tripDateParam);
                LocalDate returnDate = LocalDate.parse(returnDateParam);
                LocalTime returnTime = RETURN_WINDOW_END;

                LocalDate today = LocalDate.now();
                if (tripDate.isBefore(today)) {
                    setSessionMessage(request, "Trip date cannot be before today.", "error");
                } else if (returnDate.isBefore(tripDate)) {
                    setSessionMessage(request, "Return date must be on or after the trip date.", "error");
                } else {
                    BookingRequest.VehicleType vehicleType = BookingRequest.VehicleType.valueOf(vehicleTypeParam);
                    int passengerCount = getPassengerPreset(vehicleType);
                    BigDecimal dailyRate = getDailyRate(vehicleType);
                    long rentalDays = calculateRentalDays(tripDate, returnDate);
                    BigDecimal estimatedFee = dailyRate.multiply(BigDecimal.valueOf(rentalDays)).setScale(2, java.math.RoundingMode.HALF_UP);

                    BookingRequest b = new BookingRequest();
                    b.setId(bookingId);
                    b.setTripDate(tripDate);
                    b.setReturnDate(returnDate);
                    b.setReturnTime(returnTime);
                    b.setDestination(request.getParameter("destination").trim());
                    b.setPassengerCount(passengerCount);
                    b.setVehicleType(vehicleType);
                    b.setPurpose(request.getParameter("purpose").trim());
                    b.setDailyRentalFee(dailyRate);
                    b.setLateFeePerHour(LATE_FEE_PER_HOUR);
                    b.setEstimatedRentalFee(estimatedFee);

                    boolean ok = dao.updatePendingBookingForUser(b, userId);
                    setSessionMessage(request, ok ? "Booking updated successfully." : "Only pending bookings can be updated.",
                            ok ? "success" : "error");
                }
            }
        } catch (Exception e) {
            setSessionMessage(request, "Invalid booking update request.", "error");
        }
        response.sendRedirect(request.getContextPath() + "/BookingController");
    }

    private void cancelBooking(HttpServletRequest request, HttpServletResponse response, Long userId) throws IOException {
        try {
            long bookingId = Long.parseLong(request.getParameter("id"));
            boolean ok = dao.cancelPendingBookingForUser(bookingId, userId);
            setSessionMessage(request, ok ? "Booking cancelled successfully." : "Only pending bookings can be cancelled.",
                    ok ? "success" : "error");
        } catch (Exception e) {
            setSessionMessage(request, "Invalid cancel request.", "error");
        }
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

    private boolean isStudentOrLecturer(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        String role = (session != null && session.getAttribute("role") instanceof String)
                ? ((String) session.getAttribute("role")).trim().toUpperCase()
                : null;
        return "STUDENT".equals(role) || "LECTURER".equals(role);
    }

    private String saveLicenseImage(HttpServletRequest request, Part part, Long userId) {
        try {
            String submittedFileName = part.getSubmittedFileName();
            if (submittedFileName == null || submittedFileName.trim().isEmpty()) {
                return null;
            }

            String lower = submittedFileName.toLowerCase();
            if (!(lower.endsWith(".jpg") || lower.endsWith(".jpeg") || lower.endsWith(".png") || lower.endsWith(".webp"))) {
                return null;
            }

            String fileName = "license-" + userId + "-" + System.currentTimeMillis() + getFileExtension(submittedFileName);
            String relativePath = "/assets/uploads/licenses/" + fileName;

            String realDir = request.getServletContext().getRealPath("/assets/uploads/licenses");
            if (realDir == null) {
                return null;
            }

            Path dir = Paths.get(realDir);
            Files.createDirectories(dir);
            Path target = dir.resolve(fileName);
            try (InputStream input = part.getInputStream()) {
                Files.copy(input, target, StandardCopyOption.REPLACE_EXISTING);
            }

            return relativePath;
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    private String getFileExtension(String fileName) {
        int idx = fileName.lastIndexOf('.');
        return (idx >= 0) ? fileName.substring(idx).toLowerCase() : "";
    }

    private boolean hasAvailableVehicle(BookingRequest.VehicleType vehicleType) {
        return vehicleType != null && vehicleDAO.countAvailableVehiclesByType(vehicleType.name()) > 0;
    }

    private long calculateRentalDays(LocalDate tripDate, LocalDate returnDate) {
        long days = ChronoUnit.DAYS.between(tripDate, returnDate) + 1;
        return Math.max(days, 1);
    }

    private BigDecimal getDailyRate(BookingRequest.VehicleType vehicleType) {
        if (vehicleType == null) {
            return new BigDecimal("0.00");
        }
        switch (vehicleType) {
            case SEDAN:
                return new BigDecimal("80.00");
            case SUV:
                return new BigDecimal("130.00");
            default:
                return new BigDecimal("0.00");
        }
    }

    private int getPassengerLimit(BookingRequest.VehicleType vehicleType) {
        if (vehicleType == null) {
            return 1;
        }
        switch (vehicleType) {
            case SEDAN:
                return 4;
            case SUV:
                return 7;
            default:
                return 1;
        }
    }

    private int getPassengerPreset(BookingRequest.VehicleType vehicleType) {
        if (vehicleType == null) {
            return 1;
        }
        switch (vehicleType) {
            case SEDAN:
                return 4;
            case SUV:
                return 7;
            default:
                return 1;
        }
    }

    private String getVehicleLabel(BookingRequest.VehicleType vehicleType) {
        if (vehicleType == null) {
            return "vehicle";
        }
        switch (vehicleType) {
            case SEDAN:
                return "Sedan";
            case SUV:
                return "SUV";
            default:
                return "vehicle";
        }
    }
}
