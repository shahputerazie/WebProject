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
        <title>Campus Vehicle Booking System | Dashboard</title>
        <script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
        <script src="${pageContext.request.contextPath}/assets/js/tailwind.config.js"></script>
        <link href="https://fonts.googleapis.com/css2?family=Manrope:wght@400;600;700;800&amp;family=Inter:wght@400;500;600&amp;display=swap" rel="stylesheet"/>
        <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&amp;display=swap" rel="stylesheet"/>
        <link href="${pageContext.request.contextPath}/assets/css/fleet-management.css" rel="stylesheet"/>
    </head>
    <body class="bg-surface text-on-surface font-body selection:bg-secondary-container">
        <jsp:include page="/partials/sidebar.jsp">
            <jsp:param name="active" value="dashboard" />
        </jsp:include>

        <main class="pl-64 min-h-screen">
            <jsp:include page="/partials/navbar.jsp" />

            <div class="pt-24 px-8 pb-12 space-y-8">
                <section class="flex flex-col lg:flex-row lg:items-end lg:justify-between gap-4">
                    <div>
                        <h1 class="font-headline font-extrabold text-3xl tracking-tight text-on-surface">Campus Vehicle Booking Dashboard</h1>
                        <p class="text-on-surface-variant mt-1">Overview of all four modules and current platform operations.</p>
                    </div>
                </section>

                <section class="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-4 gap-4">
                    <div class="bg-surface-container-lowest p-6 rounded-xl border border-outline-variant/5">
                        <p class="text-xs uppercase tracking-widest text-on-surface-variant mb-2">Total Requests</p>
                        <p class="text-3xl font-headline font-bold text-primary"><%= totalRequests %></p>
                    </div>
                    <div class="bg-surface-container-lowest p-6 rounded-xl border border-outline-variant/5">
                        <p class="text-xs uppercase tracking-widest text-on-surface-variant mb-2">Pending Requests</p>
                        <p class="text-3xl font-headline font-bold text-secondary"><%= pendingRequests %></p>
                    </div>
                    <div class="bg-surface-container-lowest p-6 rounded-xl border border-outline-variant/5">
                        <p class="text-xs uppercase tracking-widest text-on-surface-variant mb-2">Approved Requests</p>
                        <p class="text-3xl font-headline font-bold text-primary"><%= approvedRequests %></p>
                    </div>
                    <div class="bg-surface-container-lowest p-6 rounded-xl border border-outline-variant/5">
                        <p class="text-xs uppercase tracking-widest text-on-surface-variant mb-2">Cancelled Requests</p>
                        <p class="text-3xl font-headline font-bold text-error"><%= cancelledRequests %></p>
                    </div>
                </section>

                <section class="bg-surface-container-lowest rounded-2xl border border-outline-variant/10 overflow-hidden">
                    <div class="px-6 py-5 border-b border-outline-variant/10">
                        <h2 class="font-headline font-bold text-xl">Recent Booking Activity</h2>
                    </div>
                    <div class="overflow-x-auto">
                        <table class="w-full border-collapse">
                            <thead>
                                <tr class="bg-surface-container-high/50 text-left">
                                    <th class="px-6 py-4 text-xs uppercase tracking-widest text-on-surface-variant">Request ID</th>
                                    <th class="px-6 py-4 text-xs uppercase tracking-widest text-on-surface-variant">Requester</th>
                                    <th class="px-6 py-4 text-xs uppercase tracking-widest text-on-surface-variant">Destination</th>
                                    <th class="px-6 py-4 text-xs uppercase tracking-widest text-on-surface-variant">Status</th>
                                </tr>
                            </thead>
                            <tbody class="divide-y divide-surface">
                                <% if (bookings.isEmpty()) { %>
                                <tr>
                                    <td colspan="4" class="px-6 py-6 text-center text-sm text-on-surface-variant">No booking activity found.</td>
                                </tr>
                                <% } else {
                                    int maxRows = Math.min(bookings.size(), 5);
                                    for (int i = 0; i < maxRows; i++) {
                                        BookingRequest booking = bookings.get(i);
                                        String statusLabel = booking.getStatus() == null ? "Unknown" : booking.getStatus().name();
                                        String displayStatus = statusLabel.substring(0, 1) + statusLabel.substring(1).toLowerCase();
                                        String badgeClass = "bg-surface-container-high text-on-surface";
                                        if ("PENDING".equals(statusLabel)) {
                                            badgeClass = "bg-amber-100 text-amber-800";
                                        } else if ("APPROVED".equals(statusLabel)) {
                                            badgeClass = "bg-primary-container text-primary-fixed-dim";
                                        } else if ("CANCELLED".equals(statusLabel) || "REJECTED".equals(statusLabel)) {
                                            badgeClass = "bg-error-container text-on-error-container";
                                        }
                                        String requestId = booking.getRequestCode() != null && !booking.getRequestCode().trim().isEmpty()
                                                ? booking.getRequestCode()
                                                : "BK-" + booking.getId();
                                        String requester = currentUserId == null
                                                ? "User #" + booking.getUserId()
                                                : "You";
                                %>
                                <tr>
                                    <td class="px-6 py-4 font-semibold text-primary"><%= esc(requestId) %></td>
                                    <td class="px-6 py-4 text-sm"><%= esc(requester) %></td>
                                    <td class="px-6 py-4 text-sm"><%= esc(booking.getDestination()) %></td>
                                    <td class="px-6 py-4"><span class="px-3 py-1 rounded-full text-xs font-bold <%= badgeClass %>"><%= esc(displayStatus) %></span></td>
                                </tr>
                                <%      }
                                   } %>
                            </tbody>
                        </table>
                    </div>
                </section>
            </div>
        </main>
    </body>
</html>
