<!-- TopNavBar -->
<header
    class="fixed top-0 right-0 w-[calc(100%-16rem)] h-16 z-40 bg-white/80 dark:bg-slate-900/80 backdrop-blur-xl shadow-sm dark:shadow-none">
    
    <div class="flex justify-between items-center px-8 w-full h-full">
        <div class="flex items-center gap-6"></div>

        <div class="flex items-center gap-4">
            <button class="material-symbols-outlined p-2 text-on-surface-variant hover:bg-slate-50 rounded-lg transition-all">
                notifications
            </button>

            <button class="material-symbols-outlined p-2 text-on-surface-variant hover:bg-slate-50 rounded-lg transition-all">
                help_outline
            </button>

            <div class="h-8 w-px bg-outline-variant/30 mx-2"></div>

            <a href="${pageContext.request.contextPath}/ProfileController"
               class="flex items-center gap-3 hover:text-primary">
                <span>Manage Profile</span>
                <img
                    class="w-8 h-8 rounded-full object-cover"
                    src="${pageContext.request.contextPath}/assets/images/admin-profile.svg"
                    alt="Profile icon" />
            </a>
        </div>
    </div>
</header>