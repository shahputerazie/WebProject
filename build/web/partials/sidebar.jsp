<%
    String active = request.getParameter("active");
    if (active == null) {
        active = "";
    }

    String activeClass = "flex items-center gap-3 bg-blue-400/20 text-white rounded-full px-4 py-3 font-semibold";
    String inactiveClass = "flex items-center gap-3 text-blue-200/70 hover:text-white px-4 py-3 transition-colors hover:bg-blue-400/10 transition-all duration-200";
    
    // Get role from session
    Object roleObj = session.getAttribute("role");
    String role = (roleObj instanceof String) ? (String) roleObj : "";

    String dashboardUrl = "/pages/user/userDashboard.jsp";
    if ("ADMIN".equals(role)) {
        dashboardUrl = "/pages/admin/dashboard.jsp";
    } else if ("STAFF".equals(role)) {
        dashboardUrl = "/pages/staff/dashboard.jsp";
    }
%>

<!-- SideNavBar -->
<aside class="h-screen w-64 fixed left-0 top-0 overflow-y-auto bg-[#002147] dark:bg-slate-950 flex flex-col py-8 px-4 z-50">

    <div class="mb-10 px-4">
        <div class="text-xl font-bold tracking-tighter text-white uppercase font-headline mb-1">
            Vehicle Booking System
        </div>

        <div class="flex items-center gap-3 mt-6">
            <div class="w-12 h-12 rounded-xl overflow-hidden bg-white p-1 shadow-sm">
                <img
                    class="w-full h-full object-contain"
                    alt="University Malaysia Terengganu crest"
                    src="${pageContext.request.contextPath}/assets/images/Logo_Rasmi_UMT.png"
                    />
            </div>

            <div>
                <p class="text-white font-semibold text-sm leading-tight">
                    University Malaysia Terengganu
                </p>
                <p class="text-blue-200/60 text-xs font-medium">
                    ${sessionScope.userName}
                </p>
            </div>
        </div>
    </div>

    <nav class="flex-1 space-y-2">

        <!-- Dashboard -->
        <a class="<%= "dashboard".equals(active) ? activeClass : inactiveClass%>"
           href="${pageContext.request.contextPath}<%= dashboardUrl %>">
            <span class="material-symbols-outlined">dashboard</span>
            <span class="font-medium">Dashboard</span>
        </a>

        <% if ("STUDENT".equals(role) || "LECTURER".equals(role)) { %>
        <p class="px-4 pt-4 pb-1 text-[10px] uppercase tracking-[0.18em] text-blue-200/50 font-bold">User Module</p>
        <a class="<%= "booking".equals(active) ? activeClass : inactiveClass%>"
           href="${pageContext.request.contextPath}/BookingController">
            <span class="material-symbols-outlined">event_note</span>
            <span class="font-medium">Booking Requests</span>
        </a>
        <% } %>

        <% if ("STAFF".equals(role) || "ADMIN".equals(role)) { %>
        <p class="px-4 pt-4 pb-1 text-[10px] uppercase tracking-[0.18em] text-blue-200/50 font-bold">Transport Team</p>
        <a class="<%= "fleet".equals(active) ? activeClass : inactiveClass%>"
           href="${pageContext.request.contextPath}/VehicleController?action=list">
            <span class="material-symbols-outlined">directions_car</span>
            <span class="font-medium">Fleet Management</span>
        </a>
        <a class="<%= "approvals".equals(active) ? activeClass : inactiveClass%>"
           href="${pageContext.request.contextPath}/pages/admin/adminDashboard.jsp">
            <span class="material-symbols-outlined">fact_check</span>
            <span class="font-medium">Booking Approvals</span>
        </a>
        <% } %>

        <% if ("ADMIN".equals(role)) { %>
        <p class="px-4 pt-4 pb-1 text-[10px] uppercase tracking-[0.18em] text-blue-200/50 font-bold">Administration</p>
        <a class="<%= "users".equals(active) ? activeClass : inactiveClass%>"
           href="${pageContext.request.contextPath}/AdminUserController">
            <span class="material-symbols-outlined">manage_accounts</span>
            <span class="font-medium">User Management</span>
        </a>
        <% } %>

    </nav>

    <div class="mt-auto px-4 pt-6 pb-6 border-t border-white/5 flex flex-col gap-4">

        <% if ("STUDENT".equals(role) || "LECTURER".equals(role)) { %>
        <a class="block text-center w-full bg-gradient-to-r from-primary to-surface-tint text-white py-3 rounded-xl font-bold text-sm tracking-tight hover:scale-95 duration-150 ease-in-out shadow-md"
           href="${pageContext.request.contextPath}/BookingController">
            New Booking
        </a>
        <% } %>

    </div>

</aside>
