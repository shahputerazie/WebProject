<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.util.List,com.project.model.BookingRequest" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    List<BookingRequest> bookingList = (List<BookingRequest>) request.getAttribute("bookings");
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
        <title>Campus Vehicle Booking System | Booking Requests</title>
        <script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
        <script src="${pageContext.request.contextPath}/assets/js/tailwind.config.js"></script>
        <link href="https://fonts.googleapis.com/css2?family=Manrope:wght@400;600;700;800&family=Inter:wght@400;500;600&display=swap" rel="stylesheet"/>
        <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap" rel="stylesheet"/>
        <link href="${pageContext.request.contextPath}/assets/css/fleet-management.css" rel="stylesheet"/>
    </head>
    <body class="bg-surface text-on-surface font-body selection:bg-secondary-container">
        <jsp:include page="/partials/sidebar.jsp">
            <jsp:param name="active" value="booking" />
        </jsp:include>

        <main class="pl-64 min-h-screen">
            <jsp:include page="/partials/navbar.jsp" />

            <div class="pt-24 px-8 pb-12 space-y-8">
                <section class="flex flex-col xl:flex-row xl:items-end xl:justify-between gap-4">
                    <div class="max-w-3xl">
                        <p class="text-xs uppercase tracking-[0.24em] font-semibold text-on-surface-variant">User module</p>
                        <h1 class="font-headline font-extrabold text-3xl tracking-tight text-on-surface mt-2">Booking Request Studio</h1>
                        <p class="text-on-surface-variant mt-2">
                            Submit a request, check pricing immediately, and review your latest bookings from the same page.
                        </p>
                    </div>
                    <div class="grid grid-cols-2 md:grid-cols-4 gap-3 w-full xl:w-auto">
                        <div class="bg-surface-container-lowest p-4 rounded-xl border border-outline-variant/5 min-w-[140px]">
                            <p class="text-[11px] uppercase tracking-[0.18em] text-on-surface-variant mb-1">Total</p>
                            <p class="text-2xl font-headline font-bold text-primary"><%= totalCount %></p>
                        </div>
                        <div class="bg-surface-container-lowest p-4 rounded-xl border border-outline-variant/5 min-w-[140px]">
                            <p class="text-[11px] uppercase tracking-[0.18em] text-on-surface-variant mb-1">Pending</p>
                            <p class="text-2xl font-headline font-bold text-secondary"><%= pendingCount %></p>
                        </div>
                        <div class="bg-surface-container-lowest p-4 rounded-xl border border-outline-variant/5 min-w-[140px]">
                            <p class="text-[11px] uppercase tracking-[0.18em] text-on-surface-variant mb-1">Approved</p>
                            <p class="text-2xl font-headline font-bold text-primary"><%= approvedCount %></p>
                        </div>
                        <div class="bg-surface-container-lowest p-4 rounded-xl border border-outline-variant/5 min-w-[140px]">
                            <p class="text-[11px] uppercase tracking-[0.18em] text-on-surface-variant mb-1">Completed</p>
                            <p class="text-2xl font-headline font-bold text-emerald-600"><%= completedCount %></p>
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
                    <section class="bg-surface-container-lowest rounded-2xl border border-outline-variant/10 overflow-hidden shadow-sm">
                        <div class="px-6 py-5 border-b border-outline-variant/10">
                            <div>
                                <h2 class="font-headline font-bold text-xl">Create Booking Request</h2>
                                <p class="text-sm text-on-surface-variant mt-1">
                                    Fill in your trip details and upload your student matrix card.
                                </p>
                            </div>
                        </div>

                        <div class="p-6 space-y-5">
                            <div class="rounded-2xl border border-primary/10 bg-primary/5 p-4 text-sm text-on-surface-variant">
                                Return time is fixed to 10:00 PM. Late returns are charged at RM 25.00 per hour.
                                Leave your matrix card at the car centre, and collect it after returning the vehicle.
                                You can pay any delay fee at the car centre.
                            </div>

                            <div class="rounded-2xl border <%= hasAvailableVehicle ? "border-emerald-200 bg-emerald-50 text-emerald-800" : "border-amber-200 bg-amber-50 text-amber-900" %> p-4 text-sm">
                                <% if (hasAvailableVehicle) { %>
                                Vehicles currently available for booking: <strong>Sedan <%= availableSedanCount %></strong>, <strong>SUV <%= availableSuvCount %></strong>.
                                <% } else { %>
                                No vehicles are currently available. Booking submission is disabled until the fleet has at least one available vehicle.
                                <% } %>
                            </div>

                            <form action="${pageContext.request.contextPath}/BookingController" method="POST" enctype="multipart/form-data" class="space-y-5">
                                <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                                    <label class="block">
                                        <span class="text-sm font-semibold text-on-surface-variant">Trip Date</span>
                                        <input type="date" id="tripDate" name="tripDate" required class="mt-1 w-full rounded-xl border border-outline-variant/30 bg-surface-container-low px-4 py-3 text-sm focus:ring-1 focus:ring-surface-tint"/>
                                    </label>
                                    <label class="block">
                                        <span class="text-sm font-semibold text-on-surface-variant">Return Date</span>
                                        <input type="date" id="returnDate" name="returnDate" required class="mt-1 w-full rounded-xl border border-outline-variant/30 bg-surface-container-low px-4 py-3 text-sm focus:ring-1 focus:ring-surface-tint"/>
                                    </label>
                                </div>

                                <label class="block">
                                    <span class="text-sm font-semibold text-on-surface-variant">Destination</span>
                                    <input type="text" name="destination" required placeholder="Example: Kuala Nerus District Office" class="mt-1 w-full rounded-xl border border-outline-variant/30 bg-surface-container-low px-4 py-3 text-sm focus:ring-1 focus:ring-surface-tint"/>
                                </label>

                                <div class="rounded-2xl border border-outline-variant/10 bg-surface-container-low p-4">
                                    <div class="flex items-start justify-between gap-4 mb-4">
                                        <div>
                                            <h3 class="font-semibold text-on-surface">Vehicle Preference</h3>
                                            <p class="text-sm text-on-surface-variant mt-1">
                                                Passenger count is determined by the selected vehicle type.
                                            </p>
                                        </div>
                                        <span class="px-3 py-1 rounded-full text-xs font-bold bg-surface-container-high text-on-surface-variant">
                                            Passenger count locked
                                        </span>
                                    </div>

                                    <div class="grid grid-cols-1 md:grid-cols-2 gap-3">
                                        <label class="flex items-start gap-3 rounded-2xl border border-outline-variant/20 bg-white p-4 <%= availableSedanCount > 0 ? "cursor-pointer has-[:checked]:border-primary has-[:checked]:bg-primary/5" : "opacity-50 cursor-not-allowed" %>">
                                            <input type="radio" name="vehicleType" value="SEDAN" <%= "SEDAN".equals(defaultVehicleType) ? "checked" : "" %> <%= availableSedanCount > 0 ? "" : "disabled" %> class="mt-1 text-primary focus:ring-primary"/>
                                            <span class="flex-1">
                                                <span class="block font-semibold text-on-surface">Sedan</span>
                                                <span class="block text-sm text-on-surface-variant mt-1">Best for 1 to 4 passengers. <%= availableSedanCount > 0 ? availableSedanCount + " available" : "No sedan available right now." %></span>
                                            </span>
                                        </label>
                                        <label class="flex items-start gap-3 rounded-2xl border border-outline-variant/20 bg-white p-4 <%= availableSuvCount > 0 ? "cursor-pointer has-[:checked]:border-primary has-[:checked]:bg-primary/5" : "opacity-50 cursor-not-allowed" %>">
                                            <input type="radio" name="vehicleType" value="SUV" <%= "SUV".equals(defaultVehicleType) ? "checked" : "" %> <%= availableSuvCount > 0 ? "" : "disabled" %> class="mt-1 text-primary focus:ring-primary"/>
                                            <span class="flex-1">
                                                <span class="block font-semibold text-on-surface">SUV</span>
                                                <span class="block text-sm text-on-surface-variant mt-1">Best for 5 to 7 passengers. <%= availableSuvCount > 0 ? availableSuvCount + " available" : "No SUV available right now." %></span>
                                            </span>
                                        </label>
                                    </div>

                                    <input type="hidden" name="passengerCount" id="passengerCount" value="<%= "SUV".equals(defaultVehicleType) ? "7" : "4" %>"/>
                                </div>

                                <label class="block">
                                    <span class="text-sm font-semibold text-on-surface-variant">Purpose of Trip</span>
                                    <textarea name="purpose" rows="5" maxlength="500" required placeholder="Briefly explain the official activity." class="mt-1 w-full rounded-xl border border-outline-variant/30 bg-surface-container-low px-4 py-3 text-sm focus:ring-1 focus:ring-surface-tint"></textarea>
                                </label>

                                <label class="block">
                                    <span class="text-sm font-semibold text-on-surface-variant">Student Matrix Card</span>
                                    <input type="file" name="licenseImage" accept="image/*" required class="mt-1 w-full rounded-xl border border-outline-variant/30 bg-surface-container-low px-4 py-3 text-sm file:mr-4 file:rounded-lg file:border-0 file:bg-primary file:px-4 file:py-2 file:font-semibold file:text-white hover:file:bg-surface-tint"/>
                                    <span class="mt-2 block text-sm text-on-surface-variant">Upload a clear image. PNG, JPG, and JPEG are supported.</span>
                                </label>

                                <div class="flex flex-col-reverse md:flex-row md:items-center md:justify-between gap-3 pt-2">
                                    <a href="${pageContext.request.contextPath}/pages/user/userDashboard.jsp" class="inline-flex items-center justify-center px-5 py-3 rounded-xl border border-outline-variant/30 text-on-surface-variant font-semibold hover:bg-surface-container-high transition-colors">
                                        Back to Dashboard
                                    </a>
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

                    <section class="bg-surface-container-lowest rounded-2xl border border-outline-variant/10 overflow-hidden shadow-sm">
                        <div class="px-6 py-5 border-b border-outline-variant/10">
                            <h2 class="font-headline font-bold text-lg">Recent Requests</h2>
                            <p class="text-sm text-on-surface-variant mt-1">Your latest booking entries in a compact table.</p>
                        </div>

                        <div class="overflow-x-auto">
                            <table class="w-full border-collapse" data-sortable-table="true">
                                <thead>
                                    <tr class="bg-surface-container-high/50 text-left">
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
                                            String status = statusLabel(booking);
                                            String requestId = safeRequestCode(booking);
                                            String badgeClass = statusBadgeClass(status);
                                            boolean canPay = booking.getStatus() == BookingRequest.Status.APPROVED;
                                            boolean canCancel = booking.getStatus() == BookingRequest.Status.PENDING;
                                    %>
                                    <tr class="hover:bg-surface-container-low/60">
                                        <td class="px-6 py-4 font-semibold text-primary"><%= esc(requestId) %></td>
                                        <td class="px-6 py-4 text-sm text-on-surface-variant" data-sort-value="<%= booking.getTripDate() == null ? "" : booking.getTripDate() %>">
                                            <%= esc(formatDate(booking, false)) %> to <%= esc(formatDate(booking, true)) %>
                                        </td>
                                        <td class="px-6 py-4 text-sm text-on-surface"><%= esc(booking.getDestination()) %></td>
                                        <td class="px-6 py-4">
                                            <span class="px-3 py-1 rounded-full text-xs font-bold <%= badgeClass %>"><%= esc(status) %></span>
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
                                                <a href="${pageContext.request.contextPath}/pages/user/payment.jsp?id=<%= booking.getId() %>" class="inline-flex items-center justify-center px-4 py-2 rounded-xl bg-primary text-white text-sm font-semibold hover:opacity-90 transition-opacity">
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
            const presets = {
                SEDAN: 4,
                SUV: 7
            };

            function syncPassengerCount() {
                const selected = document.querySelector('input[name="vehicleType"]:checked');
                if (!selected || !passengerCount) {
                    return;
                }
                passengerCount.value = presets[selected.value] || 4;
            }

            vehicleInputs.forEach((input) => {
                input.addEventListener('change', syncPassengerCount);
            });
            syncPassengerCount();
        </script>
        <script src="${pageContext.request.contextPath}/assets/js/table-sort.js"></script>
    </body>
</html>
