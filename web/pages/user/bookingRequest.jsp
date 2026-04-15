<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.util.List,com.project.dao.BookingDAO,com.project.model.BookingRequest" %>
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
    Object rawUserId = session == null ? null : session.getAttribute("userId");
    Long currentUserId = null;
    if (rawUserId instanceof Number) {
        long parsed = ((Number) rawUserId).longValue();
        currentUserId = parsed > 0 ? parsed : null;
    } else if (rawUserId != null) {
        try {
            long parsed = Long.parseLong(rawUserId.toString().trim());
            currentUserId = parsed > 0 ? parsed : null;
        } catch (NumberFormatException ignored) {
            currentUserId = null;
        }
    }

    BookingDAO bookingDAO = new BookingDAO();
    List<BookingRequest> bookings = currentUserId == null
            ? bookingDAO.getAllBookings()
            : bookingDAO.getBookingsByUserId(currentUserId);
    int totalRequests = bookings.size();
    int pendingRequests = 0;
    int approvedRequests = 0;
    int cancelledRequests = 0;

    for (BookingRequest booking : bookings) {
        if (booking.getStatus() == null) {
            continue;
        }
        if (booking.getStatus() == BookingRequest.Status.PENDING) {
            pendingRequests++;
        } else if (booking.getStatus() == BookingRequest.Status.APPROVED) {
            approvedRequests++;
        } else if (booking.getStatus() == BookingRequest.Status.CANCELLED) {
            cancelledRequests++;
        }
    }
%>
<!DOCTYPE html>
<html class="light" lang="en">
    <head>
        <meta charset="utf-8"/>
        <meta content="width=device-width, initial-scale=1.0" name="viewport"/>
        <title>Campus Vehicle Booking System | Module 3: Booking Request Management</title>
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

            <div class="pt-24 px-8 pb-12 space-y-8">
                <section class="flex flex-col lg:flex-row lg:items-end lg:justify-between gap-4">
                    <div>
                        <h1 class="font-headline font-extrabold text-3xl tracking-tight text-on-surface">Booking Request Management</h1>
                        <p class="text-on-surface-variant mt-1">Submitting, tracking, modifying, and cancelling trip requests.</p>
                    </div>
                </section>

                <section class="grid grid-cols-1 md:grid-cols-4 gap-4">
                    <div class="bg-surface-container-lowest p-6 rounded-xl border border-outline-variant/5">
                        <p class="text-xs uppercase tracking-widest text-on-surface-variant mb-2">Total Requests</p>
                        <p class="text-3xl font-headline font-bold text-primary"><%= totalRequests %></p>
                    </div>
                    <div class="bg-surface-container-lowest p-6 rounded-xl border border-outline-variant/5">
                        <p class="text-xs uppercase tracking-widest text-on-surface-variant mb-2">Pending</p>
                        <p class="text-3xl font-headline font-bold text-secondary"><%= pendingRequests %></p>
                    </div>
                    <div class="bg-surface-container-lowest p-6 rounded-xl border border-outline-variant/5">
                        <p class="text-xs uppercase tracking-widest text-on-surface-variant mb-2">Approved</p>
                        <p class="text-3xl font-headline font-bold text-primary"><%= approvedRequests %></p>
                    </div>
                    <div class="bg-surface-container-lowest p-6 rounded-xl border border-outline-variant/5">
                        <p class="text-xs uppercase tracking-widest text-on-surface-variant mb-2">Cancelled</p>
                        <p class="text-3xl font-headline font-bold text-error"><%= cancelledRequests %></p>
                    </div>
                </section>

                <section class="grid grid-cols-1 gap-8">
                    <div class="bg-surface-container-lowest rounded-2xl p-6 border border-outline-variant/10">
                        <div class="flex items-center justify-between mb-5">
                            <h2 class="font-headline font-bold text-xl text-on-surface">Submit Booking Request</h2>
                            <span class="text-xs px-3 py-1 rounded-full bg-secondary-container text-on-secondary-container font-semibold">Create</span>
                        </div>

                        <form id="bookingRequestForm" action="${pageContext.request.contextPath}/SubmitBooking" method="POST" class="grid grid-cols-1 md:grid-cols-2 gap-4">                            <label class="block">
                                <span class="text-sm text-on-surface-variant font-medium">Trip Date</span>
                                <input type="date" name="tripDate" required class="mt-1 w-full rounded-lg border border-outline-variant/30 bg-surface-container-low px-3 py-2 text-sm focus:ring-1 focus:ring-surface-tint"/>
                            </label>
                            <label class="block">
                                <span class="text-sm text-on-surface-variant font-medium">Return Date</span>
                                <input type="date" name="returnDate" required class="mt-1 w-full rounded-lg border border-outline-variant/30 bg-surface-container-low px-3 py-2 text-sm focus:ring-1 focus:ring-surface-tint"/>
                            </label>
                            <label class="block md:col-span-2">
                                <span class="text-sm text-on-surface-variant font-medium">Destination</span>
                                <input type="text" name="destination" required placeholder="Example: Kuala Terengganu City Hall" class="mt-1 w-full rounded-lg border border-outline-variant/30 bg-surface-container-low px-3 py-2 text-sm focus:ring-1 focus:ring-surface-tint"/>
                            </label>
                            <label class="block">
                                <span class="text-sm text-on-surface-variant font-medium">Passenger Count</span>
                                <input type="number" name="passengerCount" min="1" required placeholder="10" class="mt-1 w-full rounded-lg border border-outline-variant/30 bg-surface-container-low px-3 py-2 text-sm focus:ring-1 focus:ring-surface-tint"/>
                            </label>
                            <label class="block">
                                <span class="text-sm text-on-surface-variant font-medium">Vehicle Type Requested</span>
                                <select name="vehicleType" required class="mt-1 w-full rounded-lg border border-outline-variant/30 bg-surface-container-low px-3 py-2 text-sm focus:ring-1 focus:ring-surface-tint">
                                    <option value="VAN">Van</option>
                                    <option value="MPV">MPV</option>
                                    <option value="BUS">Bus</option>
                                    <option value="FOUR_BY_FOUR">4x4</option>
                                </select>
                            </label>
                            <label class="block md:col-span-2">
                                <span class="text-sm text-on-surface-variant font-medium">Purpose of Trip</span>
                                <textarea name="purpose" rows="4" required placeholder="Describe event/activity purpose" class="mt-1 w-full rounded-lg border border-outline-variant/30 bg-surface-container-low px-3 py-2 text-sm focus:ring-1 focus:ring-surface-tint"></textarea>
                            </label>
                            <div class="md:col-span-2 flex justify-end gap-3 pt-1">
                                <button id="resetBookingFormBtn" type="button" class="px-5 py-2.5 rounded-md border border-outline-variant/30 text-on-surface-variant font-semibold hover:bg-surface-container-high transition-colors">Reset</button>
                                <button type="submit" class="px-5 py-2.5 rounded-md bg-gradient-to-r from-primary to-surface-tint text-white font-semibold">Submit Request</button>
                            </div>
                        </form>
                    </div>
                </section>

                <section class="bg-surface-container-lowest rounded-2xl overflow-hidden border border-outline-variant/10">
                    <div class="px-6 py-5 border-b border-outline-variant/10 flex flex-col md:flex-row md:items-center md:justify-between gap-3">
                        <h2 class="font-headline font-bold text-xl text-on-surface">Booking History</h2>
                        <div class="flex items-center gap-3">
                            <select id="bookingStatusFilter" class="rounded-md border border-outline-variant/30 bg-surface-container-low px-3 py-2 text-sm">
                                <option>All Status</option>
                                <option>Pending</option>
                                <option>Approved</option>
                                <option>Cancelled</option>
                            </select>
                            <input id="bookingSearchInput" type="text" placeholder="Search by destination or ID" class="rounded-md border border-outline-variant/30 bg-surface-container-low px-3 py-2 text-sm w-64"/>
                        </div>
                    </div>

                    <div class="overflow-x-auto">
                        <table class="w-full border-collapse">
                            <thead>
                                <tr class="bg-surface-container-high/50 text-left">
                                    <th class="px-6 py-4 text-xs uppercase tracking-widest text-on-surface-variant">Request ID</th>
                                    <th class="px-6 py-4 text-xs uppercase tracking-widest text-on-surface-variant">Trip Date</th>
                                    <th class="px-6 py-4 text-xs uppercase tracking-widest text-on-surface-variant">Destination</th>
                                    <th class="px-6 py-4 text-xs uppercase tracking-widest text-on-surface-variant">Passengers</th>
                                    <th class="px-6 py-4 text-xs uppercase tracking-widest text-on-surface-variant">Status</th>
                                    <th class="px-6 py-4 text-xs uppercase tracking-widest text-on-surface-variant text-right">Actions</th>
                                </tr>
                            </thead>
                            <tbody id="bookingHistoryBody" class="divide-y divide-surface">
                                <% for (BookingRequest booking : bookings) {
                                    String statusLabel = booking.getStatus() == null ? "Unknown" : booking.getStatus().name();
                                    String badgeClass = "bg-surface-container-high text-on-surface";
                                    if ("PENDING".equals(statusLabel)) {
                                        badgeClass = "bg-amber-100 text-amber-800";
                                    } else if ("APPROVED".equals(statusLabel)) {
                                        badgeClass = "bg-primary-container text-primary-fixed-dim";
                                    } else if ("CANCELLED".equals(statusLabel) || "REJECTED".equals(statusLabel)) {
                                        badgeClass = "bg-error-container text-on-error-container";
                                    }
                                    String displayStatus = statusLabel.substring(0, 1) + statusLabel.substring(1).toLowerCase();
                                    String requestId = booking.getRequestCode() != null && !booking.getRequestCode().trim().isEmpty()
                                            ? booking.getRequestCode()
                                            : "BK-" + booking.getId();
                                %>
                                <tr class="hover:bg-surface-container-low/60 transition-colors">
                                    <td class="px-6 py-4 font-semibold text-primary"><%= esc(requestId) %></td>
                                    <td class="px-6 py-4 text-sm text-on-surface-variant"><%= booking.getTripDate() == null ? "-" : booking.getTripDate() %></td>
                                    <td class="px-6 py-4 text-sm"><%= esc(booking.getDestination()) %></td>
                                    <td class="px-6 py-4 text-sm"><%= booking.getPassengerCount() %></td>
                                    <td class="px-6 py-4"><span class="px-3 py-1 rounded-full text-xs font-bold <%= badgeClass %>"><%= esc(displayStatus) %></span></td>
                                    <td class="px-6 py-4 text-right space-x-2">
                                        <% if ("PENDING".equals(statusLabel)) { %>
                                        <a href="${pageContext.request.contextPath}/SubmitBooking?action=detail&id=<%= booking.getId() %>" class="inline-block px-3 py-1.5 rounded-md text-xs font-semibold bg-primary text-white hover:bg-primary-fixed-dim">Modify</a>
                                        <% } else { %>
                                        <a href="${pageContext.request.contextPath}/SubmitBooking?action=detail&id=<%= booking.getId() %>" class="inline-block px-3 py-1.5 rounded-md text-xs font-semibold bg-surface-container-high hover:bg-surface-container-highest">View</a>
                                        <% } %>
                                    </td>
                                </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                </section>
            </div>
        </main>
        <script>
            document.addEventListener("DOMContentLoaded", function () {
                const searchInput = document.getElementById("bookingSearchInput");
                const statusFilter = document.getElementById("bookingStatusFilter");
                const tbody = document.getElementById("bookingHistoryBody");
                const rows = Array.from(tbody.querySelectorAll("tr"));
                const bookingRequestForm = document.getElementById("bookingRequestForm");
                const resetBookingFormBtn = document.getElementById("resetBookingFormBtn");

                const emptyRow = document.createElement("tr");
                emptyRow.innerHTML = '<td colspan="6" class="px-6 py-6 text-center text-sm text-on-surface-variant">No booking request found.</td>';
                emptyRow.style.display = "none";
                tbody.appendChild(emptyRow);

                function applyFilters() {
                    const query = searchInput.value.trim().toLowerCase();
                    const selectedStatus = statusFilter.value.toLowerCase();
                    let visibleCount = 0;

                    rows.forEach(function (row) {
                        const rowText = row.textContent.toLowerCase();
                        const statusCell = row.querySelector("td:nth-child(5) span");
                        const rowStatus = statusCell ? statusCell.textContent.trim().toLowerCase() : "";

                        const matchesSearch = query === "" || rowText.includes(query);
                        const matchesStatus = selectedStatus === "all status" || rowStatus === selectedStatus;
                        const isVisible = matchesSearch && matchesStatus;

                        row.style.display = isVisible ? "" : "none";
                        if (isVisible) {
                            visibleCount += 1;
                        }
                    });

                    emptyRow.style.display = visibleCount === 0 ? "" : "none";
                }

                searchInput.addEventListener("input", applyFilters);
                statusFilter.addEventListener("change", applyFilters);
                resetBookingFormBtn.addEventListener("click", function () {
                    bookingRequestForm.reset();
                });
            });
        </script>
    </body>
</html>
