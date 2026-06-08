<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List, com.project.dao.BookingDAO, com.project.dao.UserDAO, com.project.dao.VehicleDAO, com.project.model.BookingRequest, com.project.model.Vehicle, com.project.model.User" %>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap" rel="stylesheet"/>
<%!
    private String esc(Object value) {
        if (value == null) return "";
        String s = String.valueOf(value);
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#x27;");
    }

    private String formatDate(java.time.LocalDate date) {
        if (date == null) return "-";
        return date.format(java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy"));
    }

    private String badgeClass(String status) {
        if (status == null) return "bg-slate-100 text-slate-700";
        switch (status.toUpperCase()) {
            case "PENDING":
                return "bg-amber-100 text-amber-700";
            case "APPROVED":
                return "bg-blue-100 text-blue-700";
            case "COMPLETED":
                return "bg-emerald-100 text-emerald-700";
            case "REJECTED":
            case "CANCELLED":
                return "bg-red-100 text-red-700";
            default:
                return "bg-slate-100 text-slate-700";
        }
    }
%>
<%
    Object rawRole = session.getAttribute("role");
    String role = (rawRole instanceof String) ? ((String) rawRole).trim().toUpperCase() : null;
    if (!"ADMIN".equals(role)) {
        response.sendRedirect(request.getContextPath() + "/pages/login/login.jsp?error=unauthorized");
        return;
    }

    BookingDAO bookingDAO = new BookingDAO();
    VehicleDAO vehicleDAO = new VehicleDAO();
    UserDAO userDAO = new UserDAO();

    List<BookingRequest> bookings = bookingDAO.getAllBookings();
    List<Vehicle> vehicles = vehicleDAO.getAllVehicles();
    List<User> users = userDAO.getAllUsers();

    int pending = 0;
    int approved = 0;
    int completed = 0;
    int cancelled = 0;
    int availableVehicles = 0;
    int unavailableVehicles = 0;
    int normalVehicles = 0;
    int largeVehicles = 0;

    if (bookings != null) {
        for (BookingRequest booking : bookings) {
            if (booking.getStatus() == BookingRequest.Status.PENDING) {
                pending++;
            } else if (booking.getStatus() == BookingRequest.Status.APPROVED) {
                approved++;
            } else if (booking.getStatus() == BookingRequest.Status.COMPLETED) {
                completed++;
            } else if (booking.getStatus() == BookingRequest.Status.CANCELLED || booking.getStatus() == BookingRequest.Status.REJECTED) {
                cancelled++;
            }
        }
    }

    if (vehicles != null) {
        for (Vehicle vehicle : vehicles) {
            if ("AVAILABLE".equalsIgnoreCase(vehicle.getStatus())) {
                availableVehicles++;
            } else {
                unavailableVehicles++;
            }

            if (vehicle.getType() != null && "SUV".equalsIgnoreCase(vehicle.getType())) {
                largeVehicles++;
            } else {
                normalVehicles++;
            }
        }
    }

    int totalBookings = bookings != null ? bookings.size() : 0;
    int totalVehicles = vehicles != null ? vehicles.size() : 0;
    int totalUsers = users != null ? users.size() : 0;
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Admin Dashboard | Vehicle Booking System</title>
    <script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <link href="https://fonts.googleapis.com/css2?family=Manrope:wght@400;600;700;800&family=Inter:wght@400;500;600&display=swap" rel="stylesheet"/>
</head>
<body class="bg-slate-50 text-slate-900 font-sans">
    <jsp:include page="/partials/sidebar.jsp">
        <jsp:param name="active" value="dashboard" />
    </jsp:include>

    <main class="pl-64 min-h-screen">
        <jsp:include page="/partials/navbar.jsp" />

        <div class="pt-24 px-8 pb-10 space-y-8">
            <section class="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-4 gap-5">
                <div class="rounded-3xl bg-white border border-slate-200 p-6 shadow-sm">
                    <p class="text-xs font-bold uppercase tracking-[0.18em] text-slate-400">Total bookings</p>
                    <p class="mt-4 text-4xl font-extrabold text-slate-900"><%= totalBookings %></p>
                    <p class="mt-2 text-sm text-slate-500">All requests in the system</p>
                </div>
                <div class="rounded-3xl bg-white border border-slate-200 p-6 shadow-sm">
                    <p class="text-xs font-bold uppercase tracking-[0.18em] text-slate-400">Pending approvals</p>
                    <p class="mt-4 text-4xl font-extrabold text-amber-600"><%= pending %></p>
                    <p class="mt-2 text-sm text-slate-500">Need staff assignment</p>
                </div>
                <div class="rounded-3xl bg-white border border-slate-200 p-6 shadow-sm">
                    <p class="text-xs font-bold uppercase tracking-[0.18em] text-slate-400">Available Cars</p>
                    <p class="mt-4 text-4xl font-extrabold text-emerald-600"><%= availableVehicles %></p>
                    <p class="mt-2 text-sm text-slate-500">Ready for booking assignment</p>
                </div>
                <div class="rounded-3xl bg-white border border-slate-200 p-6 shadow-sm">
                    <p class="text-xs font-bold uppercase tracking-[0.18em] text-slate-400">Users</p>
                    <p class="mt-4 text-4xl font-extrabold text-blue-600"><%= totalUsers %></p>
                    <p class="mt-2 text-sm text-slate-500">Admins, staff, and students</p>
                </div>
            </section>

            <section class="grid grid-cols-1 xl:grid-cols-2 gap-6">
                <div class="rounded-[2rem] bg-white border border-slate-200 shadow-sm p-6">
                    <div class="flex items-center justify-between mb-4">
                        <div>
                            <h2 class="text-xl font-bold text-slate-900">Booking status graph</h2>
                            <p class="text-sm text-slate-500">Distribution of current booking requests</p>
                        </div>
                    </div>
                    <div class="h-80">
                        <canvas id="bookingStatusChart"></canvas>
                    </div>
                </div>

                <div class="rounded-[2rem] bg-white border border-slate-200 shadow-sm p-6">
                    <div class="flex items-center justify-between mb-4">
                        <div>
                            <h2 class="text-xl font-bold text-slate-900">Fleet graph</h2>
                            <p class="text-sm text-slate-500">Vehicle status and type overview</p>
                        </div>
                    </div>
                    <div class="h-80">
                        <canvas id="fleetChart"></canvas>
                    </div>
                </div>
            </section>

            <section class="grid grid-cols-1 xl:grid-cols-3 gap-6">
                <div class="xl:col-span-2 rounded-[2rem] bg-white border border-slate-200 shadow-sm overflow-hidden">
                    <div class="flex items-center justify-between px-6 py-5 border-b border-slate-200">
                        <div>
                            <h2 class="text-xl font-bold text-slate-900">Recent bookings</h2>
                            <p class="text-sm text-slate-500">Latest requests and current states</p>
                        </div>
                        <a href="${pageContext.request.contextPath}/pages/admin/adminDashboard.jsp" class="text-sm font-semibold text-blue-600 hover:text-blue-700">
                            Open approvals
                        </a>
                    </div>
                    <div class="overflow-x-auto">
                        <table class="w-full text-left" data-sortable-table="true">
                            <thead class="bg-slate-50">
                                <tr>
                                    <th class="px-6 py-4 text-xs font-bold uppercase tracking-wide text-slate-500" data-sortable-type="text">Code</th>
                                    <th class="px-6 py-4 text-xs font-bold uppercase tracking-wide text-slate-500" data-sortable-type="text">Destination</th>
                                    <th class="px-6 py-4 text-xs font-bold uppercase tracking-wide text-slate-500" data-sortable-type="date">Trip Date</th>
                                    <th class="px-6 py-4 text-xs font-bold uppercase tracking-wide text-slate-500" data-sortable-type="text">Status</th>
                                </tr>
                            </thead>
                            <tbody class="divide-y divide-slate-100">
                                <%
                                    if (bookings == null || bookings.isEmpty()) {
                                %>
                                <tr>
                                    <td colspan="4" class="px-6 py-10 text-center text-slate-400">No bookings found.</td>
                                </tr>
                                <%
                                    } else {
                                        int limit = Math.min(bookings.size(), 6);
                                        for (int i = 0; i < limit; i++) {
                                            BookingRequest booking = bookings.get(i);
                                            String status = booking.getStatus() != null ? booking.getStatus().name() : "UNKNOWN";
                                %>
                                <tr>
                                    <td class="px-6 py-4 font-mono text-sm font-bold text-blue-700"><%= esc(booking.getRequestCode()) %></td>
                                    <td class="px-6 py-4 text-sm font-medium text-slate-800"><%= esc(booking.getDestination()) %></td>
                                    <td class="px-6 py-4 text-sm text-slate-600" data-sort-value="<%= booking.getTripDate() == null ? "" : booking.getTripDate() %>"><%= formatDate(booking.getTripDate()) %></td>
                                    <td class="px-6 py-4">
                                        <span class="inline-flex items-center rounded-full px-3 py-1 text-xs font-bold <%= badgeClass(status) %>"><%= status %></span>
                                    </td>
                                </tr>
                                <%
                                        }
                                    }
                                %>
                            </tbody>
                        </table>
                    </div>
                </div>

                <div class="space-y-6">
                    <div class="rounded-[2rem] bg-white border border-slate-200 shadow-sm p-6">
                        <h2 class="text-xl font-bold text-slate-900">Quick stats</h2>
                        <div class="mt-5 space-y-4">
                            <div class="flex items-center justify-between rounded-2xl bg-slate-50 px-4 py-3">
                                <span class="text-sm font-medium text-slate-600">Approved</span>
                                <span class="text-sm font-bold text-blue-700"><%= approved %></span>
                            </div>
                            <div class="flex items-center justify-between rounded-2xl bg-slate-50 px-4 py-3">
                                <span class="text-sm font-medium text-slate-600">Completed</span>
                                <span class="text-sm font-bold text-emerald-700"><%= completed %></span>
                            </div>
                            <div class="flex items-center justify-between rounded-2xl bg-slate-50 px-4 py-3">
                                <span class="text-sm font-medium text-slate-600">Cancelled / Rejected</span>
                                <span class="text-sm font-bold text-red-700"><%= cancelled %></span>
                            </div>
                            <div class="flex items-center justify-between rounded-2xl bg-slate-50 px-4 py-3">
                                <span class="text-sm font-medium text-slate-600">Vehicles total</span>
                                <span class="text-sm font-bold text-slate-900"><%= totalVehicles %></span>
                            </div>
                            <div class="flex items-center justify-between rounded-2xl bg-slate-50 px-4 py-3">
                                <span class="text-sm font-medium text-slate-600">Vehicles unavailable</span>
                                <span class="text-sm font-bold text-slate-900"><%= unavailableVehicles %></span>
                            </div>
                        </div>
                    </div>

                    <div class="rounded-[2rem] bg-[#002147] text-white shadow-sm p-6">
                        <p class="text-xs font-bold uppercase tracking-[0.22em] text-blue-200/70">Next action</p>
                        <h3 class="mt-3 text-2xl font-bold">Review pending requests</h3>
                        <p class="mt-3 text-sm leading-relaxed text-blue-100/80">
                            Assign a specific vehicle from the approvals page, then generate the handover pass when needed.
                        </p>
                        <a href="${pageContext.request.contextPath}/pages/admin/adminDashboard.jsp" class="mt-5 inline-flex rounded-2xl bg-white px-4 py-3 text-sm font-bold text-[#002147] hover:opacity-90 transition">
                            Go to approvals
                        </a>
                    </div>
                </div>
            </section>
        </div>
    </main>

    <script>
        const bookingStatusCtx = document.getElementById('bookingStatusChart');
        if (bookingStatusCtx) {
            new Chart(bookingStatusCtx, {
                type: 'doughnut',
                data: {
                    labels: ['Pending', 'Approved', 'Completed', 'Cancelled / Rejected'],
                    datasets: [{
                        data: [<%= pending %>, <%= approved %>, <%= completed %>, <%= cancelled %>],
                        backgroundColor: ['#f59e0b', '#3b82f6', '#10b981', '#ef4444'],
                        borderWidth: 0
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: {
                            position: 'bottom'
                        }
                    }
                }
            });
        }

        const fleetChartCtx = document.getElementById('fleetChart');
        if (fleetChartCtx) {
            new Chart(fleetChartCtx, {
                type: 'bar',
                data: {
                    labels: ['Available', 'Unavailable', 'Sedan', 'SUV'],
                    datasets: [{
                        label: 'Vehicles',
                        data: [<%= availableVehicles %>, <%= unavailableVehicles %>, <%= normalVehicles %>, <%= largeVehicles %>],
                        backgroundColor: ['#22c55e', '#ef4444', '#2563eb', '#0f766e'],
                        borderRadius: 12
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: {
                            display: false
                        }
                    },
                    scales: {
                        y: {
                            beginAtZero: true,
                            ticks: {
                                precision: 0
                            }
                        }
                    }
                }
            });
        }
    </script>
    <script src="${pageContext.request.contextPath}/assets/js/table-sort.js"></script>
</body>
</html>
