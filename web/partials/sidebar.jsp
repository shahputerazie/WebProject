<%
    String active = request.getParameter("active");
    if (active == null) {
        active = "";
    }
    String activeClass = "flex items-center gap-3 bg-blue-400/20 text-white rounded-full px-4 py-3 font-semibold";
    String inactiveClass = "flex items-center gap-3 text-blue-200/70 hover:text-white px-4 py-3 transition-colors hover:bg-blue-400/10 transition-all duration-200";
%>
<!-- SideNavBar -->
<aside class="h-screen w-64 fixed left-0 top-0 overflow-y-auto bg-[#002147] dark:bg-slate-950 flex flex-col py-8 px-4 z-50">
    <div class="mb-10 px-4">
        <div class="text-xl font-bold tracking-tighter text-white uppercase font-headline mb-1">Vehicle Booking System</div>
        <div class="flex items-center gap-3 mt-6">
            <div class="w-12 h-12 rounded-xl overflow-hidden bg-white p-1 shadow-sm">
                <img
                    class="w-full h-full object-contain"
                    alt="University Malaysia Terengganu crest"
                    src="${pageContext.request.contextPath}/assets/images/Logo_Rasmi_UMT.png"
                />
            </div>
            <div>
                <p class="text-white font-semibold text-sm leading-tight">University Malaysia Terengganu</p>
                <p class="text-blue-200/60 text-xs font-medium">Shah Semak</p>
            </div>
        </div>
    </div>
    <nav class="flex-1 space-y-2">
        <!-- Dashboard -->
        <a class="<%= "dashboard".equals(active) ? activeClass : inactiveClass %>" href="${pageContext.request.contextPath}/pages/user/userDashboard.jsp">
            <span class="material-symbols-outlined">dashboard</span>
            <span class="font-medium">Dashboard</span>
        </a>
        <!-- Booking Request Management -->
        <a class="<%= "booking".equals(active) ? activeClass : inactiveClass %>" href="${pageContext.request.contextPath}/pages/user/bookingRequest.jsp">
            <span class="material-symbols-outlined">event_note</span>
            <span class="font-medium">Booking Requests</span>
        </a>
    </nav>
    <div class="mt-auto px-4 pt-6 border-t border-white/5">
        <button class="w-full bg-gradient-to-r from-primary to-surface-tint text-white py-3 rounded-md font-bold text-sm tracking-tight hover:scale-95 duration-150 ease-in-out" href="${pageContext.request.contextPath}/pages/user/bookingRequest.jsp">
            New Booking
        </button>
    </div>
</aside>
