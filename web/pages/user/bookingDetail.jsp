<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="com.project.model.BookingRequest" %>
<%@ page import="com.project.model.Vehicle, com.project.dao.VehicleDAO" %>
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
%>
<%
    BookingRequest booking = (BookingRequest) request.getAttribute("booking");
    if (booking == null) {
        response.sendRedirect(request.getContextPath() + "/BookingController");
        return;
    }

    boolean canModify = Boolean.TRUE.equals(request.getAttribute("canModify"));
    boolean canPay = booking.getStatus() == BookingRequest.Status.APPROVED;
    String lockAttr = canModify ? "" : "disabled";
    String statusLabel = booking.getStatus() == null ? "Unknown" : booking.getStatus().name();
    String displayStatus = statusLabel.substring(0, 1) + statusLabel.substring(1).toLowerCase();
    String requestId = booking.getRequestCode() != null && !booking.getRequestCode().trim().isEmpty()
            ? booking.getRequestCode()
            : "BK-" + booking.getId();
    String dailyFee = booking.getDailyRentalFee() == null ? "0.00" : booking.getDailyRentalFee().toPlainString();
    String estimatedFee = booking.getEstimatedRentalFee() == null ? "0.00" : booking.getEstimatedRentalFee().toPlainString();
    String lateFee = booking.getLateFeePerHour() == null ? "25.00" : booking.getLateFeePerHour().toPlainString();
    String tripDate = booking.getTripDate() == null ? "-" : booking.getTripDate().toString();
    String returnDate = booking.getReturnDate() == null ? "-" : booking.getReturnDate().toString();
    Vehicle assignedVehicle = null;
    if (booking.getAssignedVehicleId() != null) {
        assignedVehicle = new VehicleDAO().getVehicleById(booking.getAssignedVehicleId().intValue());
    }

    String success = request.getParameter("success");
    String error = request.getParameter("error");
%>
<!DOCTYPE html>
<html class="light" lang="en">
    <head>
        <meta charset="utf-8"/>
        <meta content="width=device-width, initial-scale=1.0" name="viewport"/>
        <title>Campus Vehicle Booking System | Booking Detail</title>
        <script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
        <script src="${pageContext.request.contextPath}/assets/js/tailwind.config.js"></script>
        <link href="https://fonts.googleapis.com/css2?family=Manrope:wght@400;600;700;800&amp;family=Inter:wght@400;500;600&amp;display=swap" rel="stylesheet"/>
        <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
        <link href="${pageContext.request.contextPath}/assets/css/fleet-management.css" rel="stylesheet"/>
    </head>
    <body class="bg-surface text-on-surface font-body selection:bg-secondary-container">
        <jsp:include page="/partials/sidebar.jsp">
            <jsp:param name="active" value="booking" />
        </jsp:include>

        <main class="pl-64 min-h-screen">
            <jsp:include page="/partials/navbar.jsp" />

            <div class="pt-24 px-8 pb-12 space-y-6">
                <section class="flex items-center justify-between">
                    <div>
                        <h1 class="font-headline font-extrabold text-3xl tracking-tight text-on-surface">Booking Request Detail</h1>
                        <p class="text-on-surface-variant mt-1">
                            Request <span class="font-semibold text-primary"><%= esc(requestId) %></span>
                            • Status: <span class="font-semibold"><%= esc(displayStatus) %></span>
                        </p>
                        <p class="text-on-surface-variant mt-1 text-sm">
                            Trip: <span class="font-semibold"><span class="display-date"><%= esc(tripDate) %></span></span>
                            • Return: <span class="font-semibold"><span class="display-date"><%= esc(returnDate) %></span></span>
                        </p>
                    </div>
                    <a href="${pageContext.request.contextPath}/BookingController" class="px-4 py-2 rounded-md border border-outline-variant/30 text-sm font-semibold hover:bg-surface-container-high">Back</a>
                </section>

                <% if ("updated".equals(success)) { %>
                <div class="rounded-lg border border-green-200 bg-green-50 text-green-700 px-4 py-3 text-sm font-medium">
                    Booking updated successfully.
                </div>
                <% } %>
                <% if ("readonly".equals(error)) { %>
                <div class="rounded-lg border border-amber-200 bg-amber-50 text-amber-700 px-4 py-3 text-sm font-medium">
                    This request is no longer pending and cannot be modified.
                </div>
                <% } else if ("missing_fields".equals(error) || "invalid_input".equals(error)) { %>
                <div class="rounded-lg border border-red-200 bg-red-50 text-red-700 px-4 py-3 text-sm font-medium">
                    Please provide valid input for all required fields.
                </div>
                <% } else if ("update_failed".equals(error)) { %>
                <div class="rounded-lg border border-red-200 bg-red-50 text-red-700 px-4 py-3 text-sm font-medium">
                    Unable to update this booking. It may have changed status.
                </div>
                <% } else if ("cancel_failed".equals(error)) { %>
                <div class="rounded-lg border border-red-200 bg-red-50 text-red-700 px-4 py-3 text-sm font-medium">
                    Unable to cancel this booking. It may have changed status.
                </div>
                <% } %>

                <section class="bg-surface-container-lowest rounded-2xl p-6 border border-outline-variant/10 space-y-6">
                    <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
                        <div class="rounded-xl border border-outline-variant/10 bg-surface-container-low p-4">
                            <p class="text-xs uppercase tracking-wider text-on-surface-variant">Rental fee per day</p>
                            <p class="mt-1 text-xl font-extrabold text-on-surface">RM <%= esc(dailyFee) %></p>
                        </div>
                        <div class="rounded-xl border border-outline-variant/10 bg-surface-container-low p-4">
                            <p class="text-xs uppercase tracking-wider text-on-surface-variant">Estimated rental fee</p>
                            <p class="mt-1 text-xl font-extrabold text-on-surface">RM <%= esc(estimatedFee) %></p>
                        </div>
                        <div class="rounded-xl border border-outline-variant/10 bg-surface-container-low p-4">
                            <p class="text-xs uppercase tracking-wider text-on-surface-variant">Late fee per hour</p>
                            <p class="mt-1 text-xl font-extrabold text-on-surface">RM <%= esc(lateFee) %></p>
                        </div>
                    </div>

                    <div class="rounded-xl border border-amber-200 bg-amber-50 p-4 text-sm text-amber-900">
                        Please leave your matric card at the car centre and collect it after returning the vehicle.
                        Return the vehicle before 10:00 PM. Delays beyond the approved return time will be charged RM 25.00 per hour, and you can pay the delay fee at the car centre.
                    </div>
                    <% if (booking.getStatus() == BookingRequest.Status.REJECTED && booking.getRejectionReason() != null && !booking.getRejectionReason().trim().isEmpty()) { %>
                    <div class="rounded-xl border border-red-200 bg-red-50 p-4 text-sm text-red-900">
                        <p class="text-xs font-bold uppercase tracking-wider text-red-700">Rejection Reason</p>
                        <p class="mt-1"><%= esc(booking.getRejectionReason()) %></p>
                    </div>
                    <% } %>
                    <% if (assignedVehicle != null) { %>
                    <div class="rounded-xl border border-blue-200 bg-blue-50 p-4 text-sm text-blue-900">
                        Assigned vehicle: <span class="font-semibold"><%= esc(assignedVehicle.getLicensePlate()) %></span> | <%= esc(assignedVehicle.getType()) %>
                    </div>
                    <% } %>

                    <form action="${pageContext.request.contextPath}/BookingController" method="POST" class="grid grid-cols-1 md:grid-cols-2 gap-4">
                        <input type="hidden" name="action" value="update"/>
                        <input type="hidden" name="id" value="<%= booking.getId() %>"/>

                        <label class="block">
                            <span class="text-sm text-on-surface-variant font-medium">Trip Date</span>
                            <input type="date" name="tripDate" value="<%= booking.getTripDate() == null ? "" : booking.getTripDate() %>" required class="mt-1 w-full rounded-lg border border-outline-variant/30 bg-surface-container-low px-3 py-2 text-sm focus:ring-1 focus:ring-surface-tint disabled:opacity-70" <%= lockAttr %>/>
                        </label>
                        <label class="block">
                            <span class="text-sm text-on-surface-variant font-medium">Return Date</span>
                            <input type="date" name="returnDate" value="<%= booking.getReturnDate() == null ? "" : booking.getReturnDate() %>" required class="mt-1 w-full rounded-lg border border-outline-variant/30 bg-surface-container-low px-3 py-2 text-sm focus:ring-1 focus:ring-surface-tint disabled:opacity-70" <%= lockAttr %>/>
                        </label>
                        <label class="block md:col-span-2">
                            <span class="text-sm text-on-surface-variant font-medium">Destination</span>
                            <input type="text" name="destination" value="<%= esc(booking.getDestination()) %>" required class="mt-1 w-full rounded-lg border border-outline-variant/30 bg-surface-container-low px-3 py-2 text-sm focus:ring-1 focus:ring-surface-tint disabled:opacity-70" <%= lockAttr %>/>
                        </label>
                        <label class="block">
                            <span class="text-sm text-on-surface-variant font-medium">Passenger Count</span>
                            <input type="number" name="passengerCount" id="passengerCount" min="1" value="<%= booking.getPassengerCount() %>" required class="mt-1 w-full rounded-lg border border-outline-variant/30 bg-surface-container-low px-3 py-2 text-sm focus:ring-1 focus:ring-surface-tint disabled:opacity-70" <%= lockAttr %>/>
                        </label>
                        <label class="block">
                            <span class="text-sm text-on-surface-variant font-medium">Vehicle Type Requested</span>
                            <select name="vehicleType" id="vehicleType" required class="mt-1 w-full rounded-lg border border-outline-variant/30 bg-surface-container-low px-3 py-2 text-sm focus:ring-1 focus:ring-surface-tint disabled:opacity-70" <%= lockAttr %>>
                                <option value="SEDAN" <%= booking.getVehicleType() == BookingRequest.VehicleType.SEDAN ? "selected" : "" %>>Sedan</option>
                                <option value="SUV" <%= booking.getVehicleType() == BookingRequest.VehicleType.SUV ? "selected" : "" %>>SUV</option>
                            </select>
                        </label>
                        <label class="block md:col-span-2">
                            <span class="text-sm text-on-surface-variant font-medium">Purpose of Trip</span>
                            <textarea name="purpose" rows="4" required class="mt-1 w-full rounded-lg border border-outline-variant/30 bg-surface-container-low px-3 py-2 text-sm focus:ring-1 focus:ring-surface-tint disabled:opacity-70" <%= lockAttr %>><%= esc(booking.getPurpose()) %></textarea>
                        </label>

                    <div class="md:col-span-2 rounded-xl border border-outline-variant/10 bg-surface-container-low p-4">
                            <p class="text-sm font-semibold text-on-surface-variant mb-2">Student Matrix Card</p>
                            <% if (booking.getLicenseImagePath() != null && !booking.getLicenseImagePath().trim().isEmpty()) { %>
                                <img src="${pageContext.request.contextPath}<%= esc(booking.getLicenseImagePath()) %>" alt="Student matrix card" class="max-h-64 rounded-xl border border-outline-variant/20 object-contain bg-white"/>
                            <% } else { %>
                                <p class="text-sm text-on-surface-variant">No matrix card image uploaded for this request.</p>
                            <% } %>
                        </div>

                        <div class="md:col-span-2 flex justify-end gap-3 pt-1">
                            <a href="${pageContext.request.contextPath}/BookingController" class="px-5 py-2.5 rounded-md border border-outline-variant/30 text-on-surface-variant font-semibold hover:bg-surface-container-high transition-colors">Back to List</a>
                            <% if (canPay) { %>
                            <a href="${pageContext.request.contextPath}/pages/user/payment.jsp?id=<%= booking.getId() %>" class="px-5 py-2.5 rounded-md bg-primary text-white font-semibold hover:opacity-90">
                                Make Payment
                            </a>
                            <% } %>
                            <% if (canModify) { %>
                            <button type="submit" name="action" value="cancel" formnovalidate
                                    onclick="return confirm('Cancel this booking request?');"
                                    class="px-5 py-2.5 rounded-md bg-error text-white font-semibold hover:opacity-90">
                                Cancel Request
                            </button>
                            <button type="submit" class="px-5 py-2.5 rounded-md bg-gradient-to-r from-primary to-surface-tint text-white font-semibold">Save Changes</button>
                            <% } %>
                        </div>
                    </form>
                </section>
            </div>
        </main>
        <script>
            const vehicleTypeInput = document.getElementById('vehicleType');
            const passengerCountInput = document.getElementById('passengerCount');
            const passengerCaps = {
                SEDAN: { defaultValue: 4, min: 1, max: 4 },
                SUV: { defaultValue: 7, min: 5, max: 7 }
            };

            function applyPassengerPreset() {
                if (!vehicleTypeInput || !passengerCountInput) {
                    return;
                }
                const preset = passengerCaps[vehicleTypeInput.value] || passengerCaps.SEDAN;
                passengerCountInput.min = preset.min;
                passengerCountInput.max = preset.max;
                if (!passengerCountInput.value || Number(passengerCountInput.value) < preset.min || Number(passengerCountInput.value) > preset.max) {
                    passengerCountInput.value = preset.defaultValue;
                }
            }

            if (vehicleTypeInput && passengerCountInput) {
                vehicleTypeInput.addEventListener('change', applyPassengerPreset);
                applyPassengerPreset();
            }

            function toDisplayDate(value) {
                if (!value) return '-';
                const parts = String(value).split('-');
                if (parts.length !== 3) return value;
                return parts[2] + '/' + parts[1] + '/' + parts[0];
            }

            document.querySelectorAll('.display-date').forEach((el) => {
                el.textContent = toDisplayDate(el.textContent.trim());
            });
        </script>
    </body>
</html>
