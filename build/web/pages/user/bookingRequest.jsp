<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.util.List,com.project.model.BookingRequest,com.project.model.User" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    List<BookingRequest> bookingList = (List<BookingRequest>) request.getAttribute("bookings");
    java.util.Set<Long> paidBookingIds = (java.util.Set<Long>) request.getAttribute("paidBookingIds");
    User currentUser = (User) session.getAttribute("user");
    if (paidBookingIds == null) {
        paidBookingIds = java.util.Collections.emptySet();
    }
    int pendingCount = request.getAttribute("bookingPendingCount") != null ? (Integer) request.getAttribute("bookingPendingCount") : 0;
    int approvedCount = request.getAttribute("bookingApprovedCount") != null ? (Integer) request.getAttribute("bookingApprovedCount") : 0;
    int completedCount = request.getAttribute("bookingCompletedCount") != null ? (Integer) request.getAttribute("bookingCompletedCount") : 0;
    int rejectedCount = request.getAttribute("bookingRejectedCount") != null ? (Integer) request.getAttribute("bookingRejectedCount") : 0;
    int cancelledCount = request.getAttribute("bookingCancelledCount") != null ? (Integer) request.getAttribute("bookingCancelledCount") : 0;
    int totalCount = request.getAttribute("bookingTotalCount") != null ? (Integer) request.getAttribute("bookingTotalCount") : 0;
    int availableSedanCount = request.getAttribute("availableSedanCount") != null ? (Integer) request.getAttribute("availableSedanCount") : 0;
    int availableSuvCount = request.getAttribute("availableSuvCount") != null ? (Integer) request.getAttribute("availableSuvCount") : 0;
    boolean hasAvailableVehicle = request.getAttribute("hasAvailableVehicle") != null ? (Boolean) request.getAttribute("hasAvailableVehicle") : (availableSedanCount > 0 || availableSuvCount > 0);
    String defaultVehicleType = (String) request.getAttribute("defaultVehicleType");
%>
<%!
    private String esc(String value) {
        if (value == null) {
            return "";
        }
        return value.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#x27;");
    }

    private String formatDate(BookingRequest booking, boolean isReturn) {
        if (booking == null) {
            return "-";
        }
        java.time.LocalDate date = isReturn ? booking.getReturnDate() : booking.getTripDate();
        return date == null ? "-" : date.format(java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy"));
    }

    private String safeRequestCode(BookingRequest booking) {
        return booking != null && booking.getRequestCode() != null && !booking.getRequestCode().trim().isEmpty()
                ? booking.getRequestCode()
                : "BK-" + (booking == null ? "" : booking.getId());
    }

    private String statusLabel(BookingRequest booking) {
        if (booking == null || booking.getStatus() == null) {
            return "UNKNOWN";
        }
        return booking.getStatus().name();
    }

    private String statusBadgeClass(String status) {
        if ("PENDING".equals(status)) {
            return "bg-amber-100 text-amber-800";
        }
        if ("APPROVED".equals(status)) {
            return "bg-primary-container text-primary-fixed-dim";
        }
        if ("COMPLETED".equals(status)) {
            return "bg-emerald-100 text-emerald-800";
        }
        if ("REJECTED".equals(status) || "CANCELLED".equals(status)) {
            return "bg-error-container text-on-error-container";
        }
        return "bg-surface-container-high text-on-surface";
    }

    private String money(java.math.BigDecimal value) {
        if (value == null) {
            return "0.00";
        }
        return value.setScale(2, java.math.RoundingMode.HALF_UP).toPlainString();
    }

    private String vehicleCountLabel(String vehicleType, int count) {
        if (count == 1) {
            return count + " " + vehicleType;
        }
        return count + " " + vehicleType + "s";
    }
%>
<%
    String flashMessage = (String) session.getAttribute("message");
    String flashType = (String) session.getAttribute("messageType");
%>
<!DOCTYPE html>
<html class="light" lang="en">
    <head>
        <meta charset="utf-8"/>
        <meta content="width=device-width, initial-scale=1.0" name="viewport"/>
        <title>Campus Vehicle Booking System | Booking Request Page</title>
        <script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
        <script src="${pageContext.request.contextPath}/assets/js/tailwind.config.js"></script>
        <link href="https://fonts.googleapis.com/css2?family=Manrope:wght@400;600;700;800&family=Inter:wght@400;500;600&display=swap" rel="stylesheet"/>
        <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap" rel="stylesheet"/>
        <link href="${pageContext.request.contextPath}/assets/css/fleet-management.css" rel="stylesheet"/>
    </head>
    <body class="bg-[radial-gradient(circle_at_top_left,_rgba(37,99,235,0.10),_transparent_30%),radial-gradient(circle_at_top_right,_rgba(16,185,129,0.12),_transparent_28%),linear-gradient(180deg,_#f8fbff_0%,_#f6f7fb_45%,_#fdfdfd_100%)] text-on-surface font-body selection:bg-secondary-container">
        <jsp:include page="/partials/sidebar.jsp">
            <jsp:param name="active" value="booking" />
        </jsp:include>

        <main class="relative pl-64 min-h-screen overflow-hidden">
            <div class="pointer-events-none absolute -top-28 right-10 h-72 w-72 rounded-full bg-cyan-300/20 blur-3xl"></div>
            <div class="pointer-events-none absolute top-64 -left-16 h-80 w-80 rounded-full bg-blue-400/15 blur-3xl"></div>
            <jsp:include page="/partials/navbar.jsp" />

            <div class="pt-24 px-8 pb-12 space-y-8">
                <section class="relative overflow-hidden rounded-[2rem] border border-white/60 bg-white/80 p-6 shadow-[0_18px_50px_-25px_rgba(15,23,42,0.28)] backdrop-blur-xl">
                    <div class="pointer-events-none absolute -right-8 -top-8 h-36 w-36 rounded-full bg-indigo-400/15 blur-2xl"></div>
                    <div class="pointer-events-none absolute -bottom-10 left-1/3 h-40 w-40 rounded-full bg-emerald-400/15 blur-2xl"></div>
                    <div class="relative flex flex-col xl:flex-row xl:items-end xl:justify-between gap-4">
                    <div class="max-w-3xl">
                        <p class="text-xs uppercase tracking-[0.24em] font-semibold text-primary">User module</p>
                        <h1 class="font-headline font-extrabold text-3xl tracking-tight text-on-surface mt-2">Booking Request page</h1>
                        <p class="text-on-surface-variant mt-2 max-w-2xl">
                            Submit a request, check pricing immediately, and review your latest bookings from the same page.
                        </p>
                    </div>
                    <div class="grid grid-cols-2 md:grid-cols-4 gap-3 w-full xl:w-auto">
                        <div class="rounded-2xl border border-sky-100 bg-gradient-to-br from-sky-50 to-white p-4 min-w-[140px] shadow-sm">
                            <p class="text-[11px] uppercase tracking-[0.18em] text-on-surface-variant mb-1">Total</p>
                            <p class="text-2xl font-headline font-bold text-primary"><%= totalCount %></p>
                        </div>
                        <div class="rounded-2xl border border-amber-100 bg-gradient-to-br from-amber-50 to-white p-4 min-w-[140px] shadow-sm">
                            <p class="text-[11px] uppercase tracking-[0.18em] text-on-surface-variant mb-1">Pending</p>
                            <p class="text-2xl font-headline font-bold text-amber-600"><%= pendingCount %></p>
                        </div>
                        <div class="rounded-2xl border border-emerald-100 bg-gradient-to-br from-emerald-50 to-white p-4 min-w-[140px] shadow-sm">
                            <p class="text-[11px] uppercase tracking-[0.18em] text-on-surface-variant mb-1">Approved</p>
                            <p class="text-2xl font-headline font-bold text-emerald-600"><%= approvedCount %></p>
                        </div>
                        <div class="rounded-2xl border border-violet-100 bg-gradient-to-br from-violet-50 to-white p-4 min-w-[140px] shadow-sm">
                            <p class="text-[11px] uppercase tracking-[0.18em] text-on-surface-variant mb-1">Completed</p>
                            <p class="text-2xl font-headline font-bold text-violet-600"><%= completedCount %></p>
                        </div>
                    </div>
                    </div>
                </section>

                <% if (flashMessage != null && !flashMessage.trim().isEmpty()) { %>
                <div class="rounded-2xl border px-4 py-3 text-sm font-medium
                    <%= "success".equals(flashType) ? "border-emerald-200 bg-emerald-50 text-emerald-800" : "border-amber-200 bg-amber-50 text-amber-900" %>">
                    <strong class="block mb-1"><%= "success".equals(flashType) ? "Success" : "Notice" %></strong>
                    <div><%= esc(flashMessage) %></div>
                </div>
                <%
                    session.removeAttribute("message");
                    session.removeAttribute("messageType");
                %>
                <% } %>

                <div class="space-y-6">
                    <section class="rounded-[2rem] border border-white/70 bg-white/85 overflow-hidden shadow-[0_18px_50px_-25px_rgba(15,23,42,0.24)] backdrop-blur-xl">
                        <div class="px-6 py-5 border-b border-sky-100 bg-gradient-to-r from-sky-50 via-white to-emerald-50">
                            <div>
                                <h2 class="font-headline font-bold text-xl text-slate-900">Create Booking Request</h2>
                                <p class="text-sm text-on-surface-variant mt-1">
                                    Fill in your trip details and upload your student license card.
                                </p>
                            </div>
                        </div>

                        <div class="p-6 space-y-5">
                            <div class="rounded-2xl border border-cyan-100 bg-gradient-to-r from-cyan-50 via-white to-blue-50 p-4 text-sm text-on-surface-variant shadow-sm">
                                Return time is fixed to 10:00 PM. Late returns are charged at RM 25.00 per hour.
                                Leave your license card at the car centre, and collect it after returning the vehicle.
                                You can pay any delay fee at the car centre.
                            </div>

                            <form action="${pageContext.request.contextPath}/BookingController" method="POST" enctype="multipart/form-data" class="space-y-5">
                                <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                                    <label class="block">
                                        <span class="text-sm font-semibold text-on-surface-variant">Trip Date</span>
                                        <input type="date" id="tripDate" name="tripDate" required min="<%= java.time.LocalDate.now().toString() %>" class="mt-1 w-full rounded-xl border border-outline-variant/30 bg-surface-container-low px-4 py-3 text-sm focus:ring-1 focus:ring-surface-tint"/>
                                    </label>
                                    <label class="block">
                                        <span class="text-sm font-semibold text-on-surface-variant">Return Date</span>
                                        <input type="date" id="returnDate" name="returnDate" required min="<%= java.time.LocalDate.now().toString() %>" class="mt-1 w-full rounded-xl border border-outline-variant/30 bg-surface-container-low px-4 py-3 text-sm focus:ring-1 focus:ring-surface-tint"/>
                                    </label>
                                </div>

                                <label class="block">
                                    <span class="text-sm font-semibold text-on-surface-variant">Destination</span>
                                    <input type="text" name="destination" required placeholder="Example: Kuala Nerus District Office" class="mt-1 w-full rounded-xl border border-outline-variant/30 bg-surface-container-low px-4 py-3 text-sm focus:ring-1 focus:ring-surface-tint"/>
                                </label>

                                <label class="block">
                                    <span class="text-sm font-semibold text-on-surface-variant">Phone Number</span>
                                    <input
                                        type="tel"
                                        name="bookingPhone"
                                        value="<%= esc(currentUser != null ? currentUser.getPhone() : "") %>"
                                        required
                                        placeholder="Example: 012-3456789"
                                        class="mt-1 w-full rounded-xl border border-outline-variant/30 bg-surface-container-low px-4 py-3 text-sm focus:ring-1 focus:ring-surface-tint"/>
                                    <span class="mt-2 block text-sm text-on-surface-variant">We use this number for booking follow-up and urgent contact.</span>
                                </label>

                                <div class="rounded-2xl border border-outline-variant/10 bg-surface-container-low p-4">
                                    <div class="rounded-2xl border <%= hasAvailableVehicle ? "border-emerald-200 bg-gradient-to-r from-emerald-50 via-white to-cyan-50 text-emerald-900" : "border-amber-200 bg-gradient-to-r from-amber-50 via-white to-rose-50 text-amber-900" %> p-4 shadow-sm">
                                        <div class="flex flex-col gap-3 lg:flex-row lg:items-start lg:justify-between">
                                            <div>
                                                <div class="flex items-center gap-2">
                                                    <span class="inline-flex h-9 w-9 items-center justify-center rounded-xl <%= hasAvailableVehicle ? "bg-emerald-600 text-white" : "bg-amber-500 text-white" %>">
                                                        <span class="material-symbols-outlined text-[18px]">directions_car</span>
                                                    </span>
                                                    <div>
                                                        <h3 class="font-semibold text-on-surface">Vehicle Preference</h3>
                                                        <p class="text-sm text-on-surface-variant mt-0.5">
                                                            Passenger count is determined by the selected vehicle type.
                                                        </p>
                                                    </div>
                                                </div>
                                            </div>
                                            <span class="inline-flex items-center gap-2 self-start rounded-full px-3 py-1 text-xs font-bold <%= hasAvailableVehicle ? "bg-emerald-600 text-white" : "bg-amber-500 text-white" %>">
                                                <span class="material-symbols-outlined text-[16px]">lock</span>
                                                Passenger count locked
                                            </span>
                                        </div>

                                        <div class="mt-4 rounded-2xl <%= hasAvailableVehicle ? "bg-white/90 border-emerald-100" : "bg-white/90 border-amber-100" %> border p-4">
                                            <div class="flex items-center justify-between gap-3">
                                                <p class="text-sm font-semibold text-on-surface">
                                                    Vehicles currently available for booking
                                                </p>
                                                <span class="text-xs font-bold uppercase tracking-[0.18em] <%= hasAvailableVehicle ? "text-emerald-700" : "text-amber-700" %>">
                                                    Live fleet availability
                                                </span>
                                            </div>

                                            <% if (hasAvailableVehicle) { %>
                                            <div class="mt-4 grid grid-cols-1 sm:grid-cols-2 gap-3">
                                                <label class="flex items-start gap-3 rounded-2xl border border-emerald-200 bg-gradient-to-br from-white to-emerald-50 p-4 shadow-sm <%= availableSedanCount > 0 ? "cursor-pointer has-[:checked]:border-emerald-500 has-[:checked]:ring-2 has-[:checked]:ring-emerald-100" : "opacity-50 cursor-not-allowed" %>">
                                                    <input type="radio" name="vehicleType" value="SEDAN" <%= "SEDAN".equals(defaultVehicleType) ? "checked" : "" %> <%= availableSedanCount > 0 ? "" : "disabled" %> class="mt-1 text-emerald-600 focus:ring-emerald-500"/>
                                                    <span class="flex-1">
                                                        <span class="block font-semibold text-on-surface">Sedan</span>
                                                        <span class="block text-sm text-on-surface-variant mt-1">Best for 1 to 4 passengers.</span>
                                                        <span class="mt-2 inline-flex rounded-full bg-emerald-100 px-2.5 py-1 text-xs font-bold text-emerald-700"><%= vehicleCountLabel("Sedan", availableSedanCount) %></span>
                                                    </span>
                                                </label>
                                                <label class="flex items-start gap-3 rounded-2xl border border-cyan-200 bg-gradient-to-br from-white to-cyan-50 p-4 shadow-sm <%= availableSuvCount > 0 ? "cursor-pointer has-[:checked]:border-cyan-500 has-[:checked]:ring-2 has-[:checked]:ring-cyan-100" : "opacity-50 cursor-not-allowed" %>">
                                                    <input type="radio" name="vehicleType" value="SUV" <%= "SUV".equals(defaultVehicleType) ? "checked" : "" %> <%= availableSuvCount > 0 ? "" : "disabled" %> class="mt-1 text-cyan-600 focus:ring-cyan-500"/>
                                                    <span class="flex-1">
                                                        <span class="block font-semibold text-on-surface">SUV</span>
                                                        <span class="block text-sm text-on-surface-variant mt-1">Best for 5 to 7 passengers.</span>
                                                        <span class="mt-2 inline-flex rounded-full bg-cyan-100 px-2.5 py-1 text-xs font-bold text-cyan-700"><%= vehicleCountLabel("SUV", availableSuvCount) %></span>
                                                    </span>
                                                </label>
                                            </div>
                                            <% } else { %>
                                            <div class="mt-4 rounded-2xl border border-amber-200 bg-amber-50 px-4 py-3 text-sm text-amber-900">
                                                No vehicles are currently available. Booking submission is disabled until the fleet has at least one available vehicle.
                                            </div>
                                            <% } %>
                                        </div>
                                    </div>

                                    <input type="hidden" name="passengerCount" id="passengerCount" value="<%= "SUV".equals(defaultVehicleType) ? "7" : "4" %>"/>
                                </div>

                                <div class="rounded-2xl border border-primary/10 bg-gradient-to-br from-primary/5 via-white to-surface-container-low p-5 shadow-sm">
                                    <div class="flex flex-col gap-3 md:flex-row md:items-start md:justify-between">
                                        <div>
                                            <h3 class="font-semibold text-on-surface">Price Prediction</h3>
                                            <p class="text-sm text-on-surface-variant mt-1">
                                                Your estimated rental fee updates automatically before you submit.
                                            </p>
                                        </div>
                                        <span class="inline-flex items-center gap-2 self-start rounded-full border border-outline-variant/20 bg-white px-3 py-1 text-xs font-semibold text-on-surface-variant">
                                            <span class="material-symbols-outlined text-[16px]">calculate</span>
                                            Auto calculated
                                        </span>
                                    </div>

                                    <div class="mt-5 grid grid-cols-1 gap-4 md:grid-cols-3">
                                        <div class="rounded-2xl border border-outline-variant/10 bg-white p-4">
                                            <p class="text-[11px] uppercase tracking-[0.18em] text-on-surface-variant">Rental days</p>
                                            <p id="previewDays" class="mt-2 text-2xl font-headline font-bold text-on-surface">-</p>
                                        </div>
                                        <div class="rounded-2xl border border-outline-variant/10 bg-white p-4">
                                            <p class="text-[11px] uppercase tracking-[0.18em] text-on-surface-variant">Daily rate</p>
                                            <p id="previewDailyRate" class="mt-2 text-2xl font-headline font-bold text-on-surface">RM -</p>
                                        </div>
                                        <div class="rounded-2xl border border-primary/15 bg-primary/5 p-4">
                                            <p class="text-[11px] uppercase tracking-[0.18em] text-primary">Estimated fee</p>
                                            <p id="previewEstimatedFee" class="mt-2 text-2xl font-headline font-bold text-primary">RM -</p>
                                        </div>
                                    </div>

                                    <div class="mt-4 rounded-2xl border border-dashed border-outline-variant/20 bg-surface-container-low px-4 py-3 text-sm text-on-surface-variant">
                                        Late fee remains fixed at RM 25.00 per hour for overdue returns.
                                    </div>
                                </div>

                                <label class="block">
                                    <span class="text-sm font-semibold text-on-surface-variant">Purpose of Trip</span>
                                    <textarea name="purpose" rows="5" maxlength="500" required placeholder="Briefly explain the official activity." class="mt-1 w-full rounded-xl border border-outline-variant/30 bg-surface-container-low px-4 py-3 text-sm focus:ring-1 focus:ring-surface-tint"></textarea>
                                </label>

                                <label class="block">
                                    <span class="text-sm font-semibold text-on-surface-variant">Student License Card</span>
                                    <input type="file" name="licenseImage" accept="image/*" required class="mt-1 w-full rounded-xl border border-outline-variant/30 bg-surface-container-low px-4 py-3 text-sm file:mr-4 file:rounded-lg file:border-0 file:bg-primary file:px-4 file:py-2 file:font-semibold file:text-white hover:file:bg-surface-tint"/>
                                    <span class="mt-2 block text-sm text-on-surface-variant">Upload a clear image. PNG, JPG, and JPEG are supported.</span>
                                </label>

                                <div class="flex flex-col-reverse md:flex-row md:items-center md:justify-end gap-3 pt-2">
                                    <div class="flex flex-col sm:flex-row gap-3">
                                        <button type="reset" class="px-5 py-3 rounded-xl border border-outline-variant/30 text-on-surface-variant font-semibold hover:bg-surface-container-high transition-colors">
                                            Reset
                                        </button>
                                        <button type="submit" <%= hasAvailableVehicle ? "" : "disabled" %> class="px-5 py-3 rounded-xl bg-gradient-to-r from-primary to-surface-tint text-white font-semibold shadow-sm <%= hasAvailableVehicle ? "hover:opacity-90" : "opacity-50 cursor-not-allowed" %>">
                                            Submit Request
                                        </button>
                                    </div>
                                </div>
                            </form>
                        </div>
                    </section>

                    <section class="rounded-[2rem] border border-white/70 bg-white/85 overflow-hidden shadow-[0_18px_50px_-25px_rgba(15,23,42,0.22)] backdrop-blur-xl">
                        <div class="px-6 py-5 border-b border-violet-100 bg-gradient-to-r from-violet-50 via-white to-sky-50">
                            <h2 class="font-headline font-bold text-lg text-slate-900">My Booking History</h2>
                            <p class="text-sm text-on-surface-variant mt-1">Your latest booking entries in a compact table.</p>
                        </div>

                        <div class="overflow-x-auto">
                            <table class="w-full border-collapse" data-sortable-table="true">
                                <thead>
                                    <tr class="bg-slate-50/80 text-left">
                                        <th class="px-6 py-4 text-xs uppercase tracking-widest text-on-surface-variant" data-sortable-type="text">Request ID</th>
                                        <th class="px-6 py-4 text-xs uppercase tracking-widest text-on-surface-variant" data-sortable-type="date">Trip</th>
                                        <th class="px-6 py-4 text-xs uppercase tracking-widest text-on-surface-variant" data-sortable-type="text">Destination</th>
                                        <th class="px-6 py-4 text-xs uppercase tracking-widest text-on-surface-variant" data-sortable-type="text">Status</th>
                                        <th class="px-6 py-4 text-xs uppercase tracking-widest text-on-surface-variant">Action</th>
                                    </tr>
                                </thead>
                                <tbody class="divide-y divide-surface">
                                    <% if (bookingList == null || bookingList.isEmpty()) { %>
                                    <tr>
                                        <td colspan="5" class="px-6 py-8 text-center text-sm text-on-surface-variant">
                                            No booking requests found yet.
                                        </td>
                                    </tr>
                                    <% } else {
                                        for (BookingRequest booking : bookingList) {
                                            boolean isPaid = paidBookingIds.contains(booking.getId());
                                            String status = statusLabel(booking);
                                            String displayStatus = isPaid && booking.getStatus() == BookingRequest.Status.APPROVED ? "PAID" : status;
                                            String requestId = safeRequestCode(booking);
                                            String badgeClass = isPaid && booking.getStatus() == BookingRequest.Status.APPROVED
                                                    ? "bg-emerald-100 text-emerald-800"
                                                    : statusBadgeClass(status);
                                            boolean canPay = booking.getStatus() == BookingRequest.Status.APPROVED && !isPaid;
                                            boolean canCancel = booking.getStatus() == BookingRequest.Status.PENDING;
                                    %>
                                    <tr class="hover:bg-violet-50/60 transition-colors">
                                        <td class="px-6 py-4 font-semibold text-primary"><%= esc(requestId) %></td>
                                        <td class="px-6 py-4 text-sm text-on-surface-variant" data-sort-value="<%= booking.getTripDate() == null ? "" : booking.getTripDate() %>">
                                            <%= esc(formatDate(booking, false)) %> to <%= esc(formatDate(booking, true)) %>
                                        </td>
                                        <td class="px-6 py-4 text-sm text-on-surface"><%= esc(booking.getDestination()) %></td>
                                        <td class="px-6 py-4">
                                            <span class="px-3 py-1 rounded-full text-xs font-bold <%= badgeClass %>"><%= esc(displayStatus) %></span>
                                            <% if ("REJECTED".equals(status) && booking.getRejectionReason() != null && !booking.getRejectionReason().trim().isEmpty()) { %>
                                            <div class="mt-2 rounded-lg border border-red-200 bg-red-50 px-3 py-2 text-[11px] leading-5 text-red-800">
                                                <span class="font-bold uppercase tracking-wide">Reason:</span>
                                                <span><%= esc(booking.getRejectionReason()) %></span>
                                            </div>
                                            <% } %>
                                        </td>
                                        <td class="px-6 py-4">
                                            <div class="flex flex-wrap gap-2">
                                                <a href="${pageContext.request.contextPath}/BookingController?action=detail&id=<%= booking.getId() %>" class="inline-flex items-center justify-center px-4 py-2 rounded-xl border border-outline-variant/30 text-sm font-semibold text-on-surface-variant hover:bg-surface-container-high transition-colors">
                                                    View
                                                </a>
                                                <% if (canPay) { %>
                                                <a href="${pageContext.request.contextPath}/PaymentController?id=<%= booking.getId() %>" class="inline-flex items-center justify-center px-4 py-2 rounded-xl bg-primary text-white text-sm font-semibold hover:opacity-90 transition-opacity">
                                                    Make Payment
                                                </a>
                                                <% } %>
                                                <% if (canCancel) { %>
                                                <form action="${pageContext.request.contextPath}/BookingController" method="POST" onsubmit="return confirm('Cancel this booking request?');">
                                                    <input type="hidden" name="action" value="cancel"/>
                                                    <input type="hidden" name="id" value="<%= booking.getId() %>"/>
                                                    <button type="submit" class="inline-flex items-center justify-center px-4 py-2 rounded-xl bg-error text-white text-sm font-semibold hover:opacity-90 transition-opacity">
                                                        Cancel
                                                    </button>
                                                </form>
                                                <% } %>
                                            </div>
                                        </td>
                                    </tr>
                                    <%   }
                                       } %>
                                </tbody>
                            </table>
                        </div>
                    </section>
                </div>
            </div>
        </main>

        <script>
            const vehicleInputs = document.querySelectorAll('input[name="vehicleType"]');
            const passengerCount = document.getElementById('passengerCount');
            const tripDateInput = document.getElementById('tripDate');
            const returnDateInput = document.getElementById('returnDate');
            const previewDays = document.getElementById('previewDays');
            const previewDailyRate = document.getElementById('previewDailyRate');
            const previewEstimatedFee = document.getElementById('previewEstimatedFee');
            const presets = {
                SEDAN: 4,
                SUV: 7
            };
            const rates = {
                SEDAN: 80,
                SUV: 130
            };

            function syncPassengerCount() {
                const selected = document.querySelector('input[name="vehicleType"]:checked');
                if (!selected || !passengerCount) {
                    return;
                }
                passengerCount.value = presets[selected.value] || 4;
            }

            function formatMoney(value) {
                return 'RM ' + value.toFixed(2);
            }

            function parseDate(value) {
                if (!value) {
                    return null;
                }
                const parts = value.split('-').map(Number);
                if (parts.length !== 3 || parts.some(Number.isNaN)) {
                    return null;
                }
                return new Date(parts[0], parts[1] - 1, parts[2]);
            }

            function syncPricePreview() {
                const selected = document.querySelector('input[name="vehicleType"]:checked');
                const tripDate = parseDate(tripDateInput && tripDateInput.value);
                const returnDate = parseDate(returnDateInput && returnDateInput.value);

                if (!selected || !tripDate || !returnDate || !previewDays || !previewDailyRate || !previewEstimatedFee) {
                    if (previewDays) {
                        previewDays.textContent = '-';
                    }
                    if (previewDailyRate) {
                        previewDailyRate.textContent = 'RM -';
                    }
                    if (previewEstimatedFee) {
                        previewEstimatedFee.textContent = 'RM -';
                    }
                    return;
                }

                const dayMs = 24 * 60 * 60 * 1000;
                const diff = Math.floor((returnDate.getTime() - tripDate.getTime()) / dayMs) + 1;

                if (diff < 1) {
                    previewDays.textContent = '-';
                    previewDailyRate.textContent = formatMoney(rates[selected.value] || 0);
                    previewEstimatedFee.textContent = 'Invalid dates';
                    return;
                }

                const dailyRate = rates[selected.value] || 0;
                const estimatedFee = dailyRate * diff;

                previewDays.textContent = String(diff);
                previewDailyRate.textContent = formatMoney(dailyRate);
                previewEstimatedFee.textContent = formatMoney(estimatedFee);
            }

            vehicleInputs.forEach((input) => {
                input.addEventListener('change', syncPassengerCount);
                input.addEventListener('change', syncPricePreview);
            });
            if (tripDateInput) {
                const today = new Date();
                const todayValue = [
                    today.getFullYear(),
                    String(today.getMonth() + 1).padStart(2, '0'),
                    String(today.getDate()).padStart(2, '0')
                ].join('-');
                tripDateInput.min = todayValue;
                if (returnDateInput) {
                    returnDateInput.min = todayValue;
                }

                tripDateInput.addEventListener('change', () => {
                    if (returnDateInput) {
                        returnDateInput.min = tripDateInput.value || todayValue;
                        if (returnDateInput.value && returnDateInput.value < tripDateInput.value) {
                            returnDateInput.value = tripDateInput.value;
                        }
                    }
                });
                tripDateInput.addEventListener('change', syncPricePreview);
                tripDateInput.addEventListener('input', syncPricePreview);
            }
            if (returnDateInput) {
                returnDateInput.addEventListener('change', syncPricePreview);
                returnDateInput.addEventListener('input', syncPricePreview);
            }
            syncPassengerCount();
            syncPricePreview();
        </script>
        <script src="${pageContext.request.contextPath}/assets/js/table-sort.js"></script>
    </body>
</html>
