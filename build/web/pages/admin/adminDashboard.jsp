<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List, com.project.model.BookingRequest, com.project.model.HandoverRecord, com.project.dao.BookingDAO, com.project.dao.AdminDecisionDAO" %>
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap" rel="stylesheet"/>
<%!
    // Helper to escape HTML and prevent XSS
    private String esc(Object value) {
        if (value == null) return "";
        String s = String.valueOf(value);
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#x27;");
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

    // 2. ACTION PROCESSING: Handle button clicks (POST)
    String action = request.getParameter("action");
    if ("POST".equalsIgnoreCase(request.getMethod()) && action != null) {
        try {
            Long bookingId = Long.parseLong(request.getParameter("bookingId"));
            boolean success = false;
            String msg = "";

            if ("APPROVE".equals(action)) {
                success = adminDAO.updateBookingStatus(bookingId, BookingRequest.Status.APPROVED);
                msg = success ? "Booking Approved!" : "Error approving booking.";
            } else if ("REJECT".equals(action)) {
                success = adminDAO.updateBookingStatus(bookingId, BookingRequest.Status.REJECTED);
                msg = success ? "Booking Rejected." : "Error rejecting booking.";
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

    <jsp:include page="/partials/sidebar.jsp">
        <jsp:param name="active" value="dashboard" />
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
                <p class="text-slate-500">Manage vehicle requests and generate physical key passes.</p>
            </header>

            <!-- Stats Grid -->
            <section class="grid grid-cols-1 md:grid-cols-4 gap-6">
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
                    <p class="text-xs font-bold uppercase text-slate-400">Revoked/Cancelled</p>
                    <p class="text-3xl font-bold text-red-600"><%= cancelled %></p>
                </div>
            </section>

            <!-- Bookings Table -->
            <section class="bg-white rounded-2xl border border-slate-200 shadow-sm overflow-hidden">
                <div class="overflow-x-auto">
                    <table class="w-full text-left">
                        <thead class="bg-slate-50 border-b border-slate-200">
                            <tr>
                                <th class="px-6 py-4 text-xs font-bold uppercase text-slate-500">Code</th>
                                <th class="px-6 py-4 text-xs font-bold uppercase text-slate-500">Destination</th>
                                <th class="px-6 py-4 text-xs font-bold uppercase text-slate-500">Status</th>
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
                                    </td>
                                    <td class="px-6 py-4">
                                        <form method="POST" class="flex gap-2">
                                            <input type="hidden" name="bookingId" value="<%= b.getId() %>">
                                            <% if ("PENDING".equals(status)) { %>
                                                <button name="action" value="APPROVE" class="bg-blue-600 text-white px-3 py-1 rounded text-xs font-bold">Approve</button>
                                                <button name="action" value="REJECT" class="bg-slate-200 text-slate-700 px-3 py-1 rounded text-xs font-bold">Reject</button>
                                            <% } else if ("APPROVED".equals(status) && isAdmin) { %>
                                                <button name="action" value="GENERATE_HANDOVER" class="border border-blue-600 text-blue-600 px-3 py-1 rounded text-xs font-bold">Issue Key</button>
                                                <button name="action" value="COMPLETE" class="bg-emerald-600 text-white px-3 py-1 rounded text-xs font-bold">Complete</button>
                                                <button name="action" value="REVOKE" class="bg-red-50 text-red-600 px-3 py-1 rounded text-xs font-bold" onclick="return confirm('Revoke this?')">Revoke</button>
                                            <% } %>
                                        </form>
                                    </td>
                                </tr>
                            <% } } %>
                        </tbody>
                    </table>
                </div>
            </section>
        </div>
    </main>
</body>
</html>
