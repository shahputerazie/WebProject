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
           href="${pageContext.request.contextPath}/pages/user/userDashboard.jsp">
            <span class="material-symbols-outlined">dashboard</span>
            <span class="font-medium">Dashboard</span>
        </a>

        <!-- Booking Requests -->
        <a class="<%= "booking".equals(active) ? activeClass : inactiveClass%>"
           href="${pageContext.request.contextPath}/pages/user/bookingRequest.jsp">
            <span class="material-symbols-outlined">event_note</span>
            <span class="font-medium">Booking Requests</span>
        </a>

        <!-- Fleet Management -->
        <a class="<%= "fleet".equals(active) ? activeClass : inactiveClass%>"
           href="${pageContext.request.contextPath}/VehicleController?action=list">
            <span class="material-symbols-outlined">directions_car</span>
            <span class="font-medium">Fleet Management</span>
        </a>

    </nav>

    <div class="mt-auto px-4 pt-6 pb-6 border-t border-white/5 flex flex-col gap-4">

        <a class="block text-center w-full bg-gradient-to-r from-primary to-surface-tint text-white py-3 rounded-xl font-bold text-sm tracking-tight hover:scale-95 duration-150 ease-in-out shadow-md"
           href="${pageContext.request.contextPath}/pages/user/bookingRequest.jsp">
            New Booking
        </a>

        <button type="button"
                onclick="openLogoutModal()"
                class="block text-center w-full bg-red-500 text-white py-3 rounded-xl font-bold text-sm hover:bg-red-600 transition shadow-md">
            Logout
        </button>

    </div>

    <!-- Logout Modal -->
    <div id="logoutModal"
         class="hidden fixed inset-0 bg-black/50 z-[999] flex items-center justify-center">

        <div class="bg-white rounded-2xl shadow-xl w-80 p-6 text-center">

            <div class="mx-auto mb-4 w-12 h-12 rounded-full bg-red-100 flex items-center justify-center">
                <span class="material-symbols-outlined text-red-600">logout</span>
            </div>

            <h2 class="text-lg font-bold text-gray-900 mb-2">
                Confirm Logout
            </h2>

            <p class="text-sm text-gray-500 mb-6">
                Are you sure you want to logout?
            </p>

            <div class="flex gap-3">

                <button type="button"
                        onclick="closeLogoutModal()"
                        class="flex-1 py-2 rounded-xl border border-gray-300 text-gray-700 font-semibold hover:bg-gray-100">
                    Cancel
                </button>

                <a href="${pageContext.request.contextPath}/LogoutController"
                   class="flex-1 py-2 rounded-xl bg-red-500 text-white font-semibold hover:bg-red-600">
                    Logout
                </a>

            </div>

        </div>

    </div>

    <script>
        function openLogoutModal() {
            document.getElementById("logoutModal").classList.remove("hidden");
        }

        function closeLogoutModal() {
            document.getElementById("logoutModal").classList.add("hidden");
        }
    </script>

</aside>