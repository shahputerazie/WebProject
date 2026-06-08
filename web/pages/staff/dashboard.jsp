<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List, com.project.dao.VehicleDAO, com.project.model.Vehicle" %>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap" rel="stylesheet"/>
<%!
    private String esc(Object value) {
        if (value == null) return "";
        String s = String.valueOf(value);
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#x27;");
    }

    private String badgeClass(String status) {
        if (status == null) return "bg-slate-100 text-slate-700";
        if ("AVAILABLE".equalsIgnoreCase(status)) return "bg-emerald-100 text-emerald-700";
        if ("MAINTENANCE".equalsIgnoreCase(status)) return "bg-amber-100 text-amber-700";
        return "bg-red-100 text-red-700";
    }
%>
<%
    Object rawRole = session.getAttribute("role");
    String role = (rawRole instanceof String) ? ((String) rawRole).trim().toUpperCase() : null;
    if (!("ADMIN".equals(role) || "STAFF".equals(role))) {
        response.sendRedirect(request.getContextPath() + "/pages/login/login.jsp?error=unauthorized");
        return;
    }

    VehicleDAO vehicleDAO = new VehicleDAO();
    List<Vehicle> vehicles = vehicleDAO.getAllVehicles();

    int totalVehicles = 0;
    int availableVehicles = 0;
    int maintenanceVehicles = 0;
    int unavailableVehicles = 0;
    int normalVehicles = 0;
    int largeVehicles = 0;

    if (vehicles != null) {
        totalVehicles = vehicles.size();
        for (Vehicle vehicle : vehicles) {
            if ("AVAILABLE".equalsIgnoreCase(vehicle.getStatus())) {
                availableVehicles++;
            } else if ("MAINTENANCE".equalsIgnoreCase(vehicle.getStatus())) {
                maintenanceVehicles++;
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
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Staff Dashboard | Vehicle Booking System</title>
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
                    <p class="text-xs font-bold uppercase tracking-[0.18em] text-slate-400">Total vehicles</p>
                    <p class="mt-4 text-4xl font-extrabold text-slate-900"><%= totalVehicles %></p>
                    <p class="mt-2 text-sm text-slate-500">All fleet records</p>
                </div>
                <div class="rounded-3xl bg-white border border-slate-200 p-6 shadow-sm">
                    <p class="text-xs font-bold uppercase tracking-[0.18em] text-slate-400">Available Cars</p>
                    <p class="mt-4 text-4xl font-extrabold text-emerald-600"><%= availableVehicles %></p>
                    <p class="mt-2 text-sm text-slate-500">Ready for assignment</p>
                </div>
                <div class="rounded-3xl bg-white border border-slate-200 p-6 shadow-sm">
                    <p class="text-xs font-bold uppercase tracking-[0.18em] text-slate-400">Maintenance</p>
                    <p class="mt-4 text-4xl font-extrabold text-amber-600"><%= maintenanceVehicles %></p>
                    <p class="mt-2 text-sm text-slate-500">Needs attention</p>
                </div>
                <div class="rounded-3xl bg-white border border-slate-200 p-6 shadow-sm">
                    <p class="text-xs font-bold uppercase tracking-[0.18em] text-slate-400">Unavailable</p>
                    <p class="mt-4 text-4xl font-extrabold text-red-600"><%= unavailableVehicles %></p>
                    <p class="mt-2 text-sm text-slate-500">Currently occupied</p>
                </div>
            </section>

            <section class="grid grid-cols-1 xl:grid-cols-2 gap-6">
                <div class="rounded-[2rem] bg-white border border-slate-200 shadow-sm p-6">
                    <div class="flex items-center justify-between mb-4">
                        <div>
                            <h2 class="text-xl font-bold text-slate-900">Fleet status graph</h2>
                            <p class="text-sm text-slate-500">Availability across the transport team fleet</p>
                        </div>
                    </div>
                    <div class="h-80">
                        <canvas id="fleetStatusChart"></canvas>
                    </div>
                </div>

                <div class="rounded-[2rem] bg-white border border-slate-200 shadow-sm p-6">
                    <div class="flex items-center justify-between mb-4">
                        <div>
                            <h2 class="text-xl font-bold text-slate-900">Vehicle type graph</h2>
                            <p class="text-sm text-slate-500">Normal car versus big car inventory</p>
                        </div>
                    </div>
                    <div class="h-80">
                        <canvas id="vehicleTypeChart"></canvas>
                    </div>
                </div>
            </section>

            <section class="rounded-[2rem] bg-white border border-slate-200 shadow-sm overflow-hidden">
                <div class="px-6 py-5 border-b border-slate-200">
                    <h2 class="text-xl font-bold text-slate-900">Recent vehicles</h2>
                    <p class="text-sm text-slate-500">Latest fleet records shown in one place</p>
                </div>
                <div class="overflow-x-auto">
                    <table class="w-full text-left" data-sortable-table="true">
                        <thead class="bg-slate-50">
                            <tr>
                                <th class="px-6 py-4 text-xs font-bold uppercase tracking-wide text-slate-500" data-sortable-type="text">Plate</th>
                                <th class="px-6 py-4 text-xs font-bold uppercase tracking-wide text-slate-500" data-sortable-type="text">Type</th>
                                <th class="px-6 py-4 text-xs font-bold uppercase tracking-wide text-slate-500" data-sortable-type="number">Capacity</th>
                                <th class="px-6 py-4 text-xs font-bold uppercase tracking-wide text-slate-500" data-sortable-type="text">Status</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-slate-100">
                            <%
                                if (vehicles == null || vehicles.isEmpty()) {
                            %>
                            <tr>
                                <td colspan="4" class="px-6 py-10 text-center text-slate-400">No vehicles found.</td>
                            </tr>
                            <%
                                } else {
                                    int limit = Math.min(vehicles.size(), 6);
                                    for (int i = 0; i < limit; i++) {
                                        Vehicle vehicle = vehicles.get(i);
                            %>
                            <tr>
                                <td class="px-6 py-4 font-semibold text-slate-900"><%= esc(vehicle.getLicensePlate()) %></td>
                                <td class="px-6 py-4 text-sm text-slate-600"><%= esc(vehicle.getType()) %></td>
                                <td class="px-6 py-4 text-sm text-slate-600"><%= vehicle.getCapacity() %> seats</td>
                                <td class="px-6 py-4">
                                    <span class="inline-flex rounded-full px-3 py-1 text-xs font-bold <%= badgeClass(vehicle.getStatus()) %>"><%= esc(vehicle.getStatus()) %></span>
                                </td>
                            </tr>
                            <%
                                    }
                                }
                            %>
                        </tbody>
                    </table>
                </div>
            </section>
        </div>
    </main>

    <script>
        const fleetStatusCtx = document.getElementById('fleetStatusChart');
        if (fleetStatusCtx) {
            new Chart(fleetStatusCtx, {
                type: 'doughnut',
                data: {
                    labels: ['Available Cars', 'Maintenance', 'Unavailable'],
                    datasets: [{
                        data: [<%= availableVehicles %>, <%= maintenanceVehicles %>, <%= unavailableVehicles %>],
                        backgroundColor: ['#10b981', '#f59e0b', '#ef4444'],
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

        const vehicleTypeCtx = document.getElementById('vehicleTypeChart');
        if (vehicleTypeCtx) {
            new Chart(vehicleTypeCtx, {
                type: 'bar',
                data: {
                    labels: ['Sedan', 'SUV'],
                    datasets: [{
                        label: 'Count',
                        data: [<%= normalVehicles %>, <%= largeVehicles %>],
                        backgroundColor: ['#2563eb', '#0f766e'],
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
