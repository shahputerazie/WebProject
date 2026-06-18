<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List, com.project.model.BookingRequest, com.project.model.HandoverRecord, com.project.model.Vehicle, com.project.dao.BookingDAO, com.project.dao.AdminDecisionDAO, com.project.dao.VehicleDAO" %>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap" rel="stylesheet"/>
<%!
    // Helper to escape HTML and prevent XSS
    private String esc(Object value) {
        if (value == null) return "";
        String s = String.valueOf(value);
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#x27;");
    }

    private String normalizeVehicleCategory(String value) {
        if (value == null) return "";
        String normalized = value.trim().toUpperCase();
        if ("SEDAN".equals(normalized) || "COMPACT_CAR".equals(normalized) || "NORMAL_CAR".equals(normalized) || "VAN".equals(normalized)) {
            return "SEDAN";
        }
        if ("SUV".equals(normalized) || "MPV".equals(normalized) || "LARGE_CAR".equals(normalized)
                || "BUS".equals(normalized) || "FOUR_BY_FOUR".equals(normalized)) {
            return "SUV";
        }
        return normalized;
    }
%>

<%
    // 1. SECURITY CHECK: Safe retrieval of attributes
    Object rawRole = session.getAttribute("role");
    Object rawUserId = session.getAttribute("userId");

    String role = (rawRole instanceof String) ? (String) rawRole : null;
    Long adminId = null;

    // Robust parsing for userId (handles both String and Long types in session)
    if (rawUserId instanceof Number) {
        adminId = ((Number) rawUserId).longValue();
    } else if (rawUserId != null) {
        try {
            adminId = Long.parseLong(rawUserId.toString().trim());
        } catch (NumberFormatException e) {
            adminId = null;
        }
    }
    
    boolean isAdmin = "ADMIN".equals(role);
    boolean isStaff = "STAFF".equals(role);

    // Check if authorized (Admin or Staff)
    if ((!isAdmin && !isStaff) || adminId == null) {
        response.sendRedirect(request.getContextPath() + "/pages/login/login.jsp?error=unauthorized");
        return;
    }

    AdminDecisionDAO adminDAO = new AdminDecisionDAO();
    BookingDAO bookingDAO = new BookingDAO();
    VehicleDAO vehicleDAO = new VehicleDAO();

    // 2. ACTION PROCESSING: Handle button clicks (POST)
    String action = request.getParameter("action");
    if ("POST".equalsIgnoreCase(request.getMethod()) && action != null) {
        try {
            Long bookingId = Long.parseLong(request.getParameter("bookingId"));
            boolean success = false;
            String msg = "";

            if ("APPROVE".equals(action)) {
                success = adminDAO.approveBookingWithVehicle(bookingId, null);
                msg = success ? "Booking approved and reserved vehicle confirmed." : "Failed to approve booking. Check the reserved vehicle and booking status.";
            } else if ("REJECT".equals(action)) {
                String rejectionReason = request.getParameter("rejectionReason");
                if (rejectionReason == null || rejectionReason.trim().isEmpty()) {
                    msg = "Please provide a rejection reason.";
                    session.setAttribute("errorMsg", msg);
                    response.sendRedirect(request.getRequestURI());
                    return;
                }
                success = adminDAO.updateBookingStatus(bookingId, BookingRequest.Status.REJECTED, rejectionReason);
                msg = success ? "Booking rejected with reason saved." : "Error rejecting booking.";
            } else if ("COMPLETE".equals(action) && isAdmin) {
                success = adminDAO.updateBookingStatus(bookingId, BookingRequest.Status.COMPLETED);
                msg = success ? "Booking Completed." : "Error completing booking.";
            } else if ("REVOKE".equals(action) && isAdmin) {
                success = adminDAO.revokeApproval(bookingId);
                msg = success ? "Approval Revoked." : "Error revoking approval.";
            } else if ("GENERATE_HANDOVER".equals(action) && isAdmin) {
                HandoverRecord record = adminDAO.generateHandoverPass(bookingId, String.valueOf(adminId));
                success = (record != null);
                msg = success ? "Pass Generated: " + record.getPassCode() : "Error generating pass.";
            } else {
                msg = "You are not authorized for this action.";
            }

            session.setAttribute(success ? "successMsg" : "errorMsg", msg);
            // Redirect to self to prevent form resubmission on refresh
            response.sendRedirect(request.getRequestURI());
            return;
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // 3. DATA FETCHING: Load bookings for display
    List<BookingRequest> bookings = bookingDAO.getAllBookings();
    List<Vehicle> availableVehicles = vehicleDAO.getVehiclesByStatus("AVAILABLE");
    int pending = 0, approved = 0, completed = 0, cancelled = 0;
    if (bookings != null) {
        for (BookingRequest b : bookings) {
            if (b.getStatus() == BookingRequest.Status.PENDING) pending++;
            else if (b.getStatus() == BookingRequest.Status.APPROVED) approved++;
            else if (b.getStatus() == BookingRequest.Status.COMPLETED) completed++;
            else if (b.getStatus() == BookingRequest.Status.CANCELLED) cancelled++;
        }
    }
%>

<!DOCTYPE html>
<html class="light" lang="en">
<head>
    <meta charset="utf-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Admin Decisions | Fleet Management</title>
    <script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
    <link href="https://fonts.googleapis.com/css2?family=Manrope:wght@400;700;800&family=Inter:wght@400;600&display=swap" rel="stylesheet"/>
</head>
<body class="bg-slate-50 text-slate-900 font-sans">

    <%
        String sidebarActive = "approvals";
        Object sidebarActiveObj = request.getAttribute("sidebarActive");
        if (sidebarActiveObj instanceof String && !((String) sidebarActiveObj).trim().isEmpty()) {
            sidebarActive = (String) sidebarActiveObj;
        }
        request.setAttribute("sidebarActiveResolved", sidebarActive);
    %>
    <jsp:include page="/partials/sidebar.jsp">
        <jsp:param name="active" value="${requestScope.sidebarActiveResolved}" />
    </jsp:include>

    <main class="pl-64 min-h-screen">
        <jsp:include page="/partials/navbar.jsp" />

        <div class="pt-24 px-8 pb-12 space-y-8">
            <!-- Alert Messages -->
            <% if (session.getAttribute("successMsg") != null) { %>
                <div class="bg-green-100 border border-green-400 text-green-700 px-4 py-3 rounded"><%= session.getAttribute("successMsg") %><% session.removeAttribute("successMsg"); %></div>
            <% } %>
            <% if (session.getAttribute("errorMsg") != null) { %>
                <div class="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded"><%= session.getAttribute("errorMsg") %><% session.removeAttribute("errorMsg"); %></div>
            <% } %>

            <header>
                <h1 class="text-3xl font-extrabold tracking-tight">Admin Decisions & Handover</h1>
                <p class="text-slate-500">Review pending requests, verify the reserved vehicle, and record a reason when rejecting a booking.</p>
            </header>

            <!-- Stats Grid -->
            <section class="grid grid-cols-1 md:grid-cols-5 gap-6">
                <div class="bg-white p-6 rounded-xl border border-slate-200 shadow-sm">
                    <p class="text-xs font-bold uppercase text-slate-400">Pending</p>
                    <p class="text-3xl font-bold text-amber-600"><%= pending %></p>
                </div>
                <div class="bg-white p-6 rounded-xl border border-slate-200 shadow-sm">
                    <p class="text-xs font-bold uppercase text-slate-400">Approved</p>
                    <p class="text-3xl font-bold text-blue-600"><%= approved %></p>
                </div>
                <div class="bg-white p-6 rounded-xl border border-slate-200 shadow-sm">
                    <p class="text-xs font-bold uppercase text-slate-400">Completed</p>
                    <p class="text-3xl font-bold text-emerald-600"><%= completed %></p>
                </div>
                <div class="bg-white p-6 rounded-xl border border-slate-200 shadow-sm">
                    <p class="text-xs font-bold uppercase text-slate-400">Available Cars</p>
                    <p class="text-3xl font-bold text-emerald-600"><%= availableVehicles.size() %></p>
                </div>
                <div class="bg-white p-6 rounded-xl border border-slate-200 shadow-sm">
                    <p class="text-xs font-bold uppercase text-slate-400">Revoked/Cancelled</p>
                    <p class="text-3xl font-bold text-red-600"><%= cancelled %></p>
                </div>
            </section>

            <!-- Bookings Table -->
            <section class="bg-white rounded-2xl border border-slate-200 shadow-sm overflow-hidden">
                <div class="overflow-x-auto">
                    <table class="w-full text-left" data-sortable-table="true">
                        <thead class="bg-slate-50 border-b border-slate-200">
                            <tr>
                                <th class="px-6 py-4 text-xs font-bold uppercase text-slate-500" data-sortable-type="text">Code</th>
                                <th class="px-6 py-4 text-xs font-bold uppercase text-slate-500" data-sortable-type="text">Destination</th>
                                <th class="px-6 py-4 text-xs font-bold uppercase text-slate-500" data-sortable-type="text">Status</th>
                                <th class="px-6 py-4 text-xs font-bold uppercase text-slate-500">Actions</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-slate-100">
                            <% if (bookings == null || bookings.isEmpty()) { %>
                                <tr><td colspan="4" class="px-6 py-10 text-center text-slate-400">No requests found.</td></tr>
                            <% } else { 
                                for (BookingRequest b : bookings) { 
                                    String status = b.getStatus().name();
                            %>
                                <tr>
                                    <td class="px-6 py-4 font-mono text-sm text-blue-600 font-bold"><%= esc(b.getRequestCode()) %></td>
                                    <td class="px-6 py-4 text-sm font-medium"><%= esc(b.getDestination()) %></td>
                                    <td class="px-6 py-4">
                                        <span class="px-2.5 py-1 rounded-full text-xs font-bold 
                                            <%= "PENDING".equals(status) ? "bg-amber-100 text-amber-700" : 
                                                "APPROVED".equals(status) ? "bg-blue-100 text-blue-700" :
                                                "COMPLETED".equals(status) ? "bg-emerald-100 text-emerald-700" :
                                                "REJECTED".equals(status) ? "bg-red-100 text-red-700" :
                                                "bg-slate-100 text-slate-700" %>">
                                            <%= status %>
                                        </span>
                                        <% if ("APPROVED".equals(status)) {
                                            String pass = adminDAO.getHandoverPassCode(b.getId());
                                            if (pass != null) { %> <div class="mt-1 text-[10px] font-mono font-black text-blue-800">KEY: <%= pass %></div> <% }
                                        } %>
                                        <% if ("REJECTED".equals(status) && b.getRejectionReason() != null && !b.getRejectionReason().trim().isEmpty()) { %>
                                        <div class="mt-2 rounded-lg border border-red-200 bg-red-50 px-3 py-2 text-[11px] leading-5 text-red-800">
                                            <span class="font-bold uppercase tracking-wide">Reason:</span>
                                            <span><%= esc(b.getRejectionReason()) %></span>
                                        </div>
                                        <% } %>
                                        <% if (b.getAssignedVehicleId() != null) {
                                            Vehicle assignedVehicle = vehicleDAO.getVehicleById(b.getAssignedVehicleId().intValue());
                                            if (assignedVehicle != null) { %>
                                                <div class="mt-1 text-[10px] font-semibold text-slate-500">
                                                    Vehicle: <%= esc(assignedVehicle.getLicensePlate()) %> | <%= esc(assignedVehicle.getType()) %>
                                                </div>
                                            <% }
                                        } %>
                                    </td>
                                    <td class="px-6 py-4">
                                        <a href="${pageContext.request.contextPath}/admin/decisions?action=detail&bookingId=<%= b.getId() %>"
                                           class="inline-flex items-center gap-2 rounded-xl bg-slate-900 px-4 py-2.5 text-xs font-bold text-white shadow-sm transition-colors hover:bg-slate-800">
                                            <span class="material-symbols-outlined text-[18px]">visibility</span>
                                            Review Details
                                        </a>
                                    </td>
                                </tr>
                            <% } } %>
                        </tbody>
                    </table>
                </div>
            </section>
        </div>
    </main>
    <script src="${pageContext.request.contextPath}/assets/js/table-sort.js"></script>
</body>
</html>
