<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.util.List,com.project.dao.BookingDAO,com.project.model.BookingRequest" %>
<%!
    private String esc(Object value) {
        if (value == null) {
            return "";
        }
        return String.valueOf(value)
                .replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#x27;");
    }
%>
<%
    // HEPA Admin fetches ALL bookings instead of filtering by userId
    BookingDAO bookingDAO = new BookingDAO();
    List<BookingRequest> allBookings = bookingDAO.getAllBookings();

    int totalRequests = allBookings.size();
    int pendingRequests = 0;
    int approvedRequests = 0;
    int cancelledRequests = 0;

    for (BookingRequest booking : allBookings) {
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
        <title>HEPA Admin | System Overview</title>
        <script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
        <link href="https://fonts.googleapis.com/css2?family=Manrope:wght@400;600;700;800&family=Inter:wght@400;500;600&display=swap" rel="stylesheet"/>
        <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap" rel="stylesheet"/>
        <link href="${pageContext.request.contextPath}/assets/css/fleet-management.css" rel="stylesheet"/>
    </head>
    <body class="bg-surface text-on-surface font-body">
        <jsp:include page="/partials/sidebar.jsp">
            <jsp:param name="active" value="dashboard" />
        </jsp:include>

        <main class="pl-64 min-h-screen">
            <jsp:include page="/partials/navbar.jsp" />

            <div class="pt-24 px-8 pb-12 space-y-8">
                <section class="flex flex-col lg:flex-row lg:items-end lg:justify-between gap-4">
                    <div>
                        <h1 class="font-headline font-extrabold text-3xl tracking-tight text-on-surface">HEPA Administrative Dashboard</h1>
                        <p class="text-on-surface-variant mt-1">Global monitoring of vehicle bookings and user activity.</p>
                    </div>
                </section>

                <section class="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-4 gap-4">
                    <div class="bg-surface-container-lowest p-6 rounded-xl border border-outline-variant/5">
                        <p class="text-xs uppercase tracking-widest text-on-surface-variant mb-2">Total System Requests</p>
                        <p class="text-3xl font-headline font-bold text-primary"><%= totalRequests%></p>
                    </div>
                    <div class="bg-surface-container-lowest p-6 rounded-xl border border-outline-variant/5 flex justify-between items-start">
                        <div>
                            <p class="text-xs uppercase tracking-widest text-on-surface-variant mb-2">Needs Approval</p>
                            <p class="text-3xl font-headline font-bold text-secondary"><%= pendingRequests%></p>
                        </div>
                        <span class="material-symbols-outlined text-secondary bg-secondary-container/20 p-2 rounded-lg">notifications_active</span>
                    </div>
                    <div class="bg-surface-container-lowest p-6 rounded-xl border border-outline-variant/5">
                        <p class="text-xs uppercase tracking-widest text-on-surface-variant mb-2">Total Approved</p>
                        <p class="text-3xl font-headline font-bold text-primary"><%= approvedRequests%></p>
                    </div>
                    <div class="bg-surface-container-lowest p-6 rounded-xl border border-outline-variant/5">
                        <p class="text-xs uppercase tracking-widest text-on-surface-variant mb-2">Total Cancelled</p>
                        <p class="text-3xl font-headline font-bold text-error"><%= cancelledRequests%></p>
                    </div>
                </section>

                <section class="bg-surface-container-lowest rounded-2xl border border-outline-variant/10 overflow-hidden">
                    <div class="px-6 py-5 border-b border-outline-variant/10 flex justify-between items-center">
                        <h2 class="font-headline font-bold text-xl">Recent Global Activity</h2>
                        <a href="${pageContext.request.contextPath}/staff/manage-bookings" class="text-primary text-sm font-bold hover:underline">Manage All Requests →</a>
                    </div>
                    <div class="overflow-x-auto">
                        <table class="w-full border-collapse">
                            <thead>
                                <tr class="bg-surface-container-high/50 text-left">
                                    <th class="px-6 py-4 text-xs uppercase tracking-widest text-on-surface-variant">Request ID</th>
                                    <th class="px-6 py-4 text-xs uppercase tracking-widest text-on-surface-variant">User ID</th>
                                    <th class="px-6 py-4 text-xs uppercase tracking-widest text-on-surface-variant">Destination</th>
                                    <th class="px-6 py-4 text-xs uppercase tracking-widest text-on-surface-variant">Status</th>
                                    <th class="px-6 py-4 text-xs uppercase tracking-widest text-on-surface-variant">Action</th>
                                </tr>
                            </thead>
                            <tbody class="divide-y divide-surface">
                                <% if (allBookings.isEmpty()) { %>
                                <tr>
                                    <td colspan="5" class="px-6 py-6 text-center text-sm text-on-surface-variant">No system activity found.</td>
                                </tr>
                                <% } else {
                                    int maxRows = Math.min(allBookings.size(), 8); // Show more for admin
                                    for (int i = 0; i < maxRows; i++) {
                                        BookingRequest booking = allBookings.get(i);
                                        String statusLabel = booking.getStatus() == null ? "UNKNOWN" : booking.getStatus().name();
                                        String badgeClass = "bg-surface-container-high text-on-surface";

                                        if ("PENDING".equals(statusLabel))
                                            badgeClass = "bg-amber-100 text-amber-800";
                                        else if ("APPROVED".equals(statusLabel))
                                            badgeClass = "bg-primary-container text-primary-fixed-dim";
                                        else if ("CANCELLED".equals(statusLabel))
                                            badgeClass = "bg-error-container text-on-error-container";
                                %>
                                <tr class="hover:bg-surface-container-low/50 transition-colors">
                                    <td class="px-6 py-4 font-semibold text-primary"><%= esc(booking.getRequestCode())%></td>
                                    <td class="px-6 py-4 text-sm font-medium"><%= esc(booking.getUserId())%></td>
                                    <td class="px-6 py-4 text-sm"><%= esc(booking.getDestination())%></td>
                                    <td class="px-6 py-4">
                                        <span class="px-3 py-1 rounded-full text-[10px] font-bold uppercase tracking-wider <%= badgeClass%>">
                                            <%= statusLabel%>
                                        </span>
                                    </td>
                                    <td class="px-6 py-4">
                                        <a href="${pageContext.request.contextPath}/staff/manage-bookings?id=<%= booking.getId()%>" class="material-symbols-outlined text-on-surface-variant hover:text-primary transition-colors">
                                            visibility
                                        </a>
                                    </td>
                                </tr>
                                <% }
                                    }%>
                            </tbody>
                        </table>
                    </div>
                </section>
            </div>
        </main>
    </body>
</html>