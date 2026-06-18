<!-- TopNavBar -->
<%
    Object roleObj = session == null ? null : session.getAttribute("role");
    String currentRole = (roleObj instanceof String) ? ((String) roleObj).trim().toUpperCase() : "";
    boolean isStaffOrAdmin = "STAFF".equals(currentRole) || "ADMIN".equals(currentRole);
    int notificationCount = 0;
    String notificationTitle = "";
    String[] notificationLines = new String[0];
    String notificationActionText = "";
    String notificationActionUrl = "";

    if ("STAFF".equals(currentRole)) {
        notificationCount = 3;
        notificationTitle = "Transport Team Alerts";
        notificationLines = new String[] {
            "Pending bookings are waiting for approval.",
            "Check the latest reserved vehicle assignments.",
            "Review fleet availability before approving new requests."
        };
        notificationActionText = "Open Booking Queue";
        notificationActionUrl = request.getContextPath() + "/staff/manage-bookings";
    } else if ("ADMIN".equals(currentRole)) {
        notificationCount = 4;
        notificationTitle = "Admin Alerts";
        notificationLines = new String[] {
            "New approval activity needs review.",
            "User management updates may require attention.",
            "Completed bookings are ready for handover follow-up.",
            "Monitor available vehicles and system usage."
        };
        notificationActionText = "Open Approvals";
        notificationActionUrl = request.getContextPath() + "/admin/decisions";
    }

    String manageProfileReturnUrl = request.getRequestURI();
    String manageProfileQuery = request.getQueryString();
    if (manageProfileQuery != null && !manageProfileQuery.trim().isEmpty()) {
        manageProfileReturnUrl += "?" + manageProfileQuery;
    }
    String manageProfileReturnParam = manageProfileReturnUrl;
    try {
        manageProfileReturnParam = java.net.URLEncoder.encode(manageProfileReturnUrl, "UTF-8");
    } catch (java.io.UnsupportedEncodingException ignored) {
        manageProfileReturnParam = manageProfileReturnUrl;
    }
%>
<header
    class="fixed top-0 right-0 w-[calc(100%-16rem)] h-16 z-40 bg-white/80 dark:bg-slate-900/80 backdrop-blur-xl shadow-sm dark:shadow-none">
    
    <div class="flex justify-between items-center px-8 w-full h-full">
        <div class="flex items-center gap-6"></div>

        <div class="flex items-center gap-4">
            <form method="POST" action="${pageContext.request.contextPath}/RoleSwitchController" class="hidden sm:flex items-center gap-2">
                <label for="roleSwitch" class="text-xs font-semibold uppercase tracking-[0.18em] text-slate-400">Interface</label>
                <select id="roleSwitch" name="role"
                        onchange="this.form.submit()"
                        class="rounded-xl border border-slate-200 bg-white px-3 py-2 text-sm font-semibold text-slate-700 shadow-sm focus:border-slate-300 focus:ring-2 focus:ring-slate-100">
                    <option value="STUDENT" <%= "STUDENT".equals(currentRole) || "LECTURER".equals(currentRole) ? "selected" : "" %>>Student</option>
                    <option value="STAFF" <%= "STAFF".equals(currentRole) ? "selected" : "" %>>Staff</option>
                    <option value="ADMIN" <%= "ADMIN".equals(currentRole) ? "selected" : "" %>>Admin</option>
                </select>
            </form>

            <div class="relative">
                <button type="button"
                        id="notificationBellButton"
                        onclick="toggleNavbarNotifications()"
                        class="relative inline-flex items-center justify-center rounded-xl p-2 text-on-surface-variant hover:bg-slate-50 transition-all">
                    <span class="material-symbols-outlined">notifications</span>
                    <% if (isStaffOrAdmin) { %>
                    <span class="absolute -right-0.5 -top-0.5 inline-flex h-5 min-w-5 items-center justify-center rounded-full bg-rose-500 px-1 text-[10px] font-bold text-white shadow-sm">
                        <%= notificationCount %>
                    </span>
                    <% } %>
                </button>

                <% if (isStaffOrAdmin) { %>
                <div id="navbarNotificationsPanel" class="hidden absolute right-0 mt-3 w-[24rem] overflow-hidden rounded-3xl border border-slate-200 bg-white shadow-[0_20px_60px_-20px_rgba(15,23,42,0.28)] z-50">
                    <div class="bg-gradient-to-r <%= "ADMIN".equals(currentRole) ? "from-slate-900 via-slate-800 to-indigo-900" : "from-blue-900 via-sky-800 to-cyan-900" %> px-5 py-4 text-white">
                        <p class="text-[11px] font-bold uppercase tracking-[0.22em] text-white/70">Notifications</p>
                        <h3 class="mt-1 text-lg font-extrabold"><%= notificationTitle %></h3>
                    </div>
                    <div class="p-4 space-y-3">
                        <% for (String line : notificationLines) { %>
                        <div class="rounded-2xl border border-slate-200 bg-slate-50 px-4 py-3 text-sm text-slate-700">
                            <div class="flex items-start gap-3">
                                <span class="mt-0.5 inline-flex h-8 w-8 items-center justify-center rounded-xl <%= "ADMIN".equals(currentRole) ? "bg-slate-900 text-white" : "bg-blue-600 text-white" %>">
                                    <span class="material-symbols-outlined text-[18px]">notifications_active</span>
                                </span>
                                <p class="leading-6"><%= line %></p>
                            </div>
                        </div>
                        <% } %>
                    </div>
                    <div class="border-t border-slate-200 bg-slate-50 px-4 py-3">
                        <a href="<%= notificationActionUrl %>" class="inline-flex w-full items-center justify-center gap-2 rounded-2xl bg-slate-900 px-4 py-3 text-sm font-semibold text-white hover:bg-slate-800 transition-colors">
                            <span class="material-symbols-outlined text-[18px]">open_in_new</span>
                            <%= notificationActionText %>
                        </a>
                    </div>
                </div>
                <% } %>
            </div>

            <button class="material-symbols-outlined p-2 text-on-surface-variant hover:bg-slate-50 rounded-lg transition-all">
                help_outline
            </button>

            <div class="h-8 w-px bg-outline-variant/30 mx-2"></div>

            <a href="${pageContext.request.contextPath}/ProfileController?returnUrl=<%= manageProfileReturnParam %>"
               class="flex items-center gap-3 hover:text-primary">
                <span>Manage Profile</span>
                <img
                    class="w-8 h-8 rounded-full object-cover"
                    src="${pageContext.request.contextPath}/assets/images/admin-profile.svg"
                    alt="Profile icon" />
            </a>

            <button type="button"
                    onclick="openLogoutModal()"
                    class="inline-flex items-center gap-2 px-4 py-2 rounded-xl bg-red-50 text-red-700 font-semibold hover:bg-red-100 transition-all">
                <span class="material-symbols-outlined text-base">logout</span>
                Logout
            </button>
        </div>
    </div>

    <script>
        function toggleNavbarNotifications() {
            const panel = document.getElementById("navbarNotificationsPanel");
            if (!panel) {
                return;
            }
            panel.classList.toggle("hidden");
        }

        document.addEventListener("click", function (event) {
            const panel = document.getElementById("navbarNotificationsPanel");
            const button = document.getElementById("notificationBellButton");
            if (!panel || panel.classList.contains("hidden")) {
                return;
            }
            if (panel.contains(event.target) || (button && button.contains(event.target))) {
                return;
            }
            panel.classList.add("hidden");
        });

        document.addEventListener("keydown", function (event) {
            if (event.key !== "Escape") {
                return;
            }
            const panel = document.getElementById("navbarNotificationsPanel");
            if (panel) {
                panel.classList.add("hidden");
            }
        });

        function openLogoutModal() {
            const modal = document.getElementById("logoutModal");
            if (modal) {
                modal.classList.remove("hidden");
            }
        }

        function closeLogoutModal() {
            const modal = document.getElementById("logoutModal");
            if (modal) {
                modal.classList.add("hidden");
            }
        }
    </script>
</header>

<div id="logoutModal" class="hidden fixed inset-0 z-[999] px-4">
    <div class="absolute inset-0 bg-slate-950/60 backdrop-blur-md" onclick="closeLogoutModal()"></div>

    <div role="dialog" aria-modal="true" aria-labelledby="logoutModalTitle" aria-describedby="logoutModalDescription"
         class="absolute left-1/2 top-1/2 w-full max-w-lg -translate-x-1/2 -translate-y-1/2 overflow-hidden rounded-[2rem] border border-white/30 bg-white shadow-[0_30px_80px_-20px_rgba(15,23,42,0.35)]">
        <div class="h-2 bg-gradient-to-r from-rose-500 via-red-500 to-orange-400"></div>

        <div class="px-6 pt-6 pb-5 bg-gradient-to-b from-rose-50/90 via-white to-white">
            <div class="mx-auto mb-4 flex h-16 w-16 items-center justify-center rounded-3xl bg-rose-100 text-rose-600 shadow-sm ring-8 ring-rose-50">
                <span class="material-symbols-outlined text-[30px]">logout</span>
            </div>
            <h2 id="logoutModalTitle" class="text-center text-2xl font-extrabold tracking-tight text-slate-900">
                Sign out of your session?
            </h2>
            <p id="logoutModalDescription" class="mt-3 text-center text-sm leading-6 text-slate-500">
                You can sign back in anytime. Save your work first, because any unsaved changes on this page may be lost.
            </p>
        </div>

        <div class="px-6 pb-6">
            <div class="rounded-2xl border border-slate-200 bg-slate-50 px-4 py-4 text-sm text-slate-600">
                <div class="flex items-start gap-3">
                    <span class="mt-0.5 inline-flex h-8 w-8 items-center justify-center rounded-xl bg-white text-slate-500 shadow-sm">
                        <span class="material-symbols-outlined text-[18px]">account_circle</span>
                    </span>
                    <div>
                        <p class="text-xs font-semibold uppercase tracking-[0.18em] text-slate-400">Current account</p>
                        <p class="mt-1 font-semibold text-slate-900">${sessionScope.userName}</p>
                        <p class="mt-1 text-slate-500">You will return to the login page after signing out.</p>
                    </div>
                </div>
            </div>

            <div class="mt-5 grid grid-cols-1 gap-3 sm:grid-cols-2">
                <button type="button"
                        onclick="closeLogoutModal()"
                        class="inline-flex items-center justify-center gap-2 rounded-xl border border-slate-300 bg-white px-4 py-3 font-semibold text-slate-700 transition-colors hover:bg-slate-100">
                    Keep me signed in
                </button>

                <a href="${pageContext.request.contextPath}/LogoutController"
                   class="inline-flex items-center justify-center gap-2 rounded-xl bg-red-600 px-4 py-3 font-semibold text-white transition-colors hover:bg-red-700">
                    <span class="material-symbols-outlined text-[18px]">logout</span>
                    Logout now
                </a>
            </div>
        </div>
    </div>
</div>
