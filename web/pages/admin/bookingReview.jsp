<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.project.model.BookingRequest, com.project.model.Vehicle, com.project.dao.VehicleDAO" %>
<%!
    private String esc(Object value) {
        if (value == null) {
            return "";
        }
        String s = String.valueOf(value);
        return s.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#x27;");
    }

    private String formatStatus(BookingRequest booking) {
        if (booking == null || booking.getStatus() == null) {
            return "UNKNOWN";
        }
        return booking.getStatus().name();
    }
%>
<%
    BookingRequest booking = (BookingRequest) request.getAttribute("booking");
    if (booking == null) {
        response.sendRedirect(request.getContextPath() + "/admin/decisions");
        return;
    }

    Vehicle assignedVehicle = null;
    if (booking.getAssignedVehicleId() != null) {
        assignedVehicle = new VehicleDAO().getVehicleById(booking.getAssignedVehicleId().intValue());
    }

    String status = formatStatus(booking);
    boolean canDecide = "PENDING".equals(status);
    boolean canAdminActions = "APPROVED".equals(status);
    String requestCode = booking.getRequestCode() == null ? ("BK-" + booking.getId()) : booking.getRequestCode();
    String dailyFee = booking.getDailyRentalFee() == null ? "0.00" : booking.getDailyRentalFee().toPlainString();
    String lateFee = booking.getLateFeePerHour() == null ? "25.00" : booking.getLateFeePerHour().toPlainString();
    String estimatedFee = booking.getEstimatedRentalFee() == null ? "0.00" : booking.getEstimatedRentalFee().toPlainString();
    String licensePath = booking.getLicenseImagePath();
%>
<!DOCTYPE html>
<html class="light" lang="en">
<head>
    <meta charset="utf-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Booking Review | Admin</title>
    <script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
    <link href="https://fonts.googleapis.com/css2?family=Manrope:wght@400;700;800&family=Inter:wght@400;600&display=swap" rel="stylesheet"/>
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap" rel="stylesheet"/>
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

        <div class="pt-24 px-8 pb-12 space-y-6">
            <section class="flex flex-wrap items-center justify-between gap-4">
                <div>
                    <p class="text-xs font-bold uppercase tracking-[0.24em] text-slate-400">Booking Review</p>
                    <h1 class="mt-2 text-3xl font-extrabold tracking-tight">Review request <span class="text-blue-600"><%= esc(requestCode) %></span></h1>
                    <p class="mt-2 text-slate-500">
                        Booker details, booking summary, and license image are shown here before approval or rejection.
                    </p>
                </div>
                <a href="${pageContext.request.contextPath}/admin/decisions" class="inline-flex items-center gap-2 rounded-xl border border-slate-200 bg-white px-4 py-2.5 text-sm font-semibold text-slate-700 shadow-sm hover:bg-slate-50">
                    <span class="material-symbols-outlined text-[18px]">arrow_back</span>
                    Back to Requests
                </a>
            </section>

            <section class="grid grid-cols-1 lg:grid-cols-[1.25fr_0.85fr] gap-6">
                <div class="space-y-6">
                    <div class="rounded-3xl border border-slate-200 bg-white shadow-sm overflow-hidden">
                        <div class="bg-gradient-to-r from-slate-900 via-slate-800 to-blue-900 px-6 py-6 text-white">
                            <div class="flex flex-wrap items-center gap-4">
                                <div class="flex h-16 w-16 items-center justify-center rounded-2xl bg-white/15 text-white font-extrabold text-2xl">
                                    <%= (booking.getBookerName() != null && !booking.getBookerName().trim().isEmpty())
                                            ? booking.getBookerName().trim().substring(0, 1).toUpperCase()
                                            : "?" %>
                                </div>
                                <div>
                                    <p class="text-xs font-bold uppercase tracking-[0.24em] text-white/70">Requester</p>
                                    <h2 class="mt-1 text-2xl font-extrabold"><%= esc(booking.getBookerName()) %></h2>
                                    <p class="mt-1 text-sm text-white/80"><%= esc(booking.getBookerRole()) %></p>
                                </div>
                            </div>
                        </div>

                        <div class="grid grid-cols-1 md:grid-cols-2 gap-4 p-6">
                            <div class="flex min-h-[96px] flex-col justify-between rounded-2xl border border-slate-200 bg-slate-50 p-4">
                                <p class="text-[11px] font-bold uppercase tracking-[0.22em] text-slate-400">Booker Email</p>
                                <p class="mt-2 text-sm font-semibold text-slate-900 break-all leading-6"><%= esc(booking.getBookerEmail()) %></p>
                            </div>
                            <div class="flex min-h-[96px] flex-col justify-between rounded-2xl border border-sky-200 bg-gradient-to-br from-sky-50 to-white p-4 shadow-sm">
                                <p class="text-[11px] font-bold uppercase tracking-[0.22em] text-slate-400">Booker Phone</p>
                                <p class="mt-2 text-sm font-semibold text-sky-900 leading-6"><%= esc(booking.getBookerPhone()) %></p>
                            </div>
                            <div class="rounded-2xl border border-slate-200 bg-slate-50 p-4">
                                <p class="text-[11px] font-bold uppercase tracking-[0.22em] text-slate-400">Status</p>
                                <p class="mt-2 text-sm font-semibold text-slate-900">
                                    <span class="inline-flex rounded-full px-3 py-1 text-xs font-bold
                                        <%= "PENDING".equals(status) ? "bg-amber-100 text-amber-700" :
                                            "APPROVED".equals(status) ? "bg-blue-100 text-blue-700" :
                                            "COMPLETED".equals(status) ? "bg-emerald-100 text-emerald-700" :
                                            "REJECTED".equals(status) ? "bg-red-100 text-red-700" :
                                            "bg-slate-100 text-slate-700" %>">
                                        <%= esc(status) %>
                                    </span>
                                </p>
                            </div>
                            <div class="rounded-2xl border border-slate-200 bg-slate-50 p-4">
                                <p class="text-[11px] font-bold uppercase tracking-[0.22em] text-slate-400">Purpose</p>
                                <p class="mt-2 text-sm font-semibold text-slate-900"><%= esc(booking.getPurpose()) %></p>
                            </div>
                        </div>
                    </div>

                    <div class="rounded-3xl border border-slate-200 bg-white p-6 shadow-sm">
                        <div class="flex items-center justify-between gap-4">
                            <div>
                                <p class="text-[11px] font-bold uppercase tracking-[0.22em] text-slate-400">License Image</p>
                                <h3 class="mt-1 text-xl font-extrabold">Student License Card</h3>
                            </div>
                            <span class="inline-flex items-center gap-2 rounded-full border border-slate-200 bg-slate-50 px-3 py-1.5 text-xs font-semibold text-slate-600">
                                <span class="material-symbols-outlined text-[18px]">id_card</span>
                                Verification
                            </span>
                        </div>

                        <div class="mt-4 overflow-hidden rounded-2xl border border-slate-200 bg-slate-50">
                            <% if (licensePath != null && !licensePath.trim().isEmpty()) { %>
                                <img src="${pageContext.request.contextPath}<%= esc(licensePath) %>"
                                     alt="License image"
                                     class="w-full max-h-[560px] object-contain bg-white"/>
                            <% } else { %>
                                <div class="flex min-h-[280px] items-center justify-center text-sm text-slate-400">
                                    No license image uploaded for this request.
                                </div>
                            <% } %>
                        </div>
                    </div>
                </div>

                <aside class="space-y-6">
                    <div class="rounded-3xl border border-slate-200 bg-white p-6 shadow-sm">
                        <p class="text-[11px] font-bold uppercase tracking-[0.22em] text-slate-400">Booking Summary</p>
                        <div class="mt-4 space-y-3 text-sm">
                            <div class="flex items-center justify-between gap-4 rounded-2xl bg-slate-50 px-4 py-3">
                                <span class="text-slate-500">Trip Date</span>
                                <span class="font-semibold text-slate-900"><%= booking.getTripDate() == null ? "-" : booking.getTripDate() %></span>
                            </div>
                            <div class="flex items-center justify-between gap-4 rounded-2xl bg-slate-50 px-4 py-3">
                                <span class="text-slate-500">Return Date</span>
                                <span class="font-semibold text-slate-900"><%= booking.getReturnDate() == null ? "-" : booking.getReturnDate() %></span>
                            </div>
                            <div class="flex items-center justify-between gap-4 rounded-2xl bg-slate-50 px-4 py-3">
                                <span class="text-slate-500">Return Time</span>
                                <span class="font-semibold text-slate-900"><%= booking.getReturnTime() == null ? "-" : booking.getReturnTime() %></span>
                            </div>
                            <div class="flex items-center justify-between gap-4 rounded-2xl bg-slate-50 px-4 py-3">
                                <span class="text-slate-500">Destination</span>
                                <span class="font-semibold text-slate-900 text-right"><%= esc(booking.getDestination()) %></span>
                            </div>
                            <div class="flex items-center justify-between gap-4 rounded-2xl bg-slate-50 px-4 py-3">
                                <span class="text-slate-500">Vehicle Type</span>
                                <span class="font-semibold text-slate-900"><%= booking.getVehicleType() == null ? "-" : esc(booking.getVehicleType().name()) %></span>
                            </div>
                            <div class="flex items-center justify-between gap-4 rounded-2xl bg-slate-50 px-4 py-3">
                                <span class="text-slate-500">Passenger Count</span>
                                <span class="font-semibold text-slate-900"><%= booking.getPassengerCount() %></span>
                            </div>
                            <div class="flex items-center justify-between gap-4 rounded-2xl bg-slate-50 px-4 py-3">
                                <span class="text-slate-500">Daily Fee</span>
                                <span class="font-semibold text-slate-900">RM <%= esc(dailyFee) %></span>
                            </div>
                            <div class="flex items-center justify-between gap-4 rounded-2xl bg-slate-50 px-4 py-3">
                                <span class="text-slate-500">Late Fee / Hour</span>
                                <span class="font-semibold text-slate-900">RM <%= esc(lateFee) %></span>
                            </div>
                            <div class="flex items-center justify-between gap-4 rounded-2xl border border-blue-100 bg-blue-50 px-4 py-3">
                                <span class="text-blue-700">Estimated Fee</span>
                                <span class="text-lg font-extrabold text-blue-900">RM <%= esc(estimatedFee) %></span>
                            </div>
                        </div>
                    </div>

                    <div class="rounded-3xl border border-slate-200 bg-white p-6 shadow-sm">
                        <p class="text-[11px] font-bold uppercase tracking-[0.22em] text-slate-400">Reserved Vehicle</p>
                        <% if (assignedVehicle != null) { %>
                            <div class="mt-4 rounded-2xl border border-emerald-100 bg-emerald-50 p-4">
                                <p class="text-lg font-extrabold text-emerald-900"><%= esc(assignedVehicle.getLicensePlate()) %></p>
                                <p class="mt-1 text-sm font-semibold text-emerald-700"><%= esc(assignedVehicle.getType()) %></p>
                                <p class="mt-2 text-xs text-emerald-700">This vehicle is already reserved for this booking request.</p>
                            </div>
                        <% } else { %>
                            <div class="mt-4 rounded-2xl border border-slate-200 bg-slate-50 p-4 text-sm text-slate-500">
                                No reserved vehicle found.
                            </div>
                        <% } %>
                    </div>

                    <% if (booking.getRejectionReason() != null && !booking.getRejectionReason().trim().isEmpty()) { %>
                    <div class="rounded-3xl border border-red-200 bg-red-50 p-6 shadow-sm">
                        <p class="text-[11px] font-bold uppercase tracking-[0.22em] text-red-600">Rejection Reason</p>
                        <p class="mt-2 text-sm text-red-900"><%= esc(booking.getRejectionReason()) %></p>
                    </div>
                    <% } %>

                    <div class="rounded-3xl border border-slate-200 bg-white p-6 shadow-sm space-y-3">
                        <p class="text-[11px] font-bold uppercase tracking-[0.22em] text-slate-400">Actions</p>
                        <% if (canDecide) { %>
                            <form method="POST" action="${pageContext.request.contextPath}/admin/decisions" class="space-y-3">
                                <input type="hidden" name="bookingId" value="<%= booking.getId() %>">
                                <input type="hidden" name="action" value="APPROVE">
                                <button type="submit" class="w-full inline-flex items-center justify-center gap-2 rounded-2xl bg-blue-600 px-4 py-3 text-sm font-bold text-white shadow-sm hover:bg-blue-700">
                                    <span class="material-symbols-outlined text-[18px]">check_circle</span>
                                    Approve Request
                                </button>
                            </form>

                            <form method="POST" action="${pageContext.request.contextPath}/admin/decisions" class="space-y-3">
                                <input type="hidden" name="bookingId" value="<%= booking.getId() %>">
                                <input type="hidden" name="action" value="REJECT">
                                <label class="block">
                                    <span class="text-sm font-semibold text-slate-700">Reject Reason</span>
                                    <textarea name="rejectionReason" rows="4" required maxlength="500" placeholder="Explain why the booking is rejected" class="mt-2 w-full rounded-2xl border border-slate-200 bg-slate-50 px-4 py-3 text-sm focus:border-red-300 focus:ring-2 focus:ring-red-100"></textarea>
                                </label>
                                <button type="submit" onclick="return confirm('Reject this booking and save the reason?')" class="w-full inline-flex items-center justify-center gap-2 rounded-2xl bg-red-600 px-4 py-3 text-sm font-bold text-white shadow-sm hover:bg-red-700">
                                    <span class="material-symbols-outlined text-[18px]">close</span>
                                    Reject Request
                                </button>
                            </form>
                        <% } else if (canAdminActions) { %>
                            <form method="POST" action="${pageContext.request.contextPath}/admin/decisions">
                                <input type="hidden" name="bookingId" value="<%= booking.getId() %>">
                                <button name="action" value="GENERATE_HANDOVER" class="w-full rounded-2xl border border-blue-600 px-4 py-3 text-sm font-bold text-blue-700 hover:bg-blue-50">Issue Key</button>
                            </form>
                            <form method="POST" action="${pageContext.request.contextPath}/admin/decisions">
                                <input type="hidden" name="bookingId" value="<%= booking.getId() %>">
                                <button name="action" value="COMPLETE" class="w-full rounded-2xl bg-emerald-600 px-4 py-3 text-sm font-bold text-white hover:bg-emerald-700">Mark Complete</button>
                            </form>
                            <form method="POST" action="${pageContext.request.contextPath}/admin/decisions">
                                <input type="hidden" name="bookingId" value="<%= booking.getId() %>">
                                <button name="action" value="REVOKE" class="w-full rounded-2xl bg-rose-50 px-4 py-3 text-sm font-bold text-rose-700 hover:bg-rose-100" onclick="return confirm('Revoke this approval?')">Revoke Approval</button>
                            </form>
                        <% } else { %>
                            <div class="rounded-2xl bg-slate-50 px-4 py-3 text-sm text-slate-500">
                                This booking is no longer pending, so approval actions are disabled.
                            </div>
                        <% } %>
                    </div>
                </aside>
            </section>
        </div>
    </main>
</body>
</html>
