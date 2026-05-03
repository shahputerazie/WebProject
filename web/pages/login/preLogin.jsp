<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>Pre Login | Campus Vehicle Booking System</title>
        <script src="https://cdn.tailwindcss.com?plugins=forms"></script>
    </head>

    <body class="bg-gray-50 min-h-screen flex items-center justify-center font-sans">

        <!-- Wrapper (fix footer position) -->
        <div class="flex flex-col items-center">

            <!-- CARD -->
            <div class="bg-white w-full max-w-md rounded-2xl shadow-sm border p-8 text-center">

                <!-- Header -->
                <div class="mb-8">

                    <img src="${pageContext.request.contextPath}/assets/images/Logo_Rasmi_UMT.png"
                         alt="UMT Logo"
                         class="mx-auto w-32 h-auto mb-4">

                    <h1 class="text-3xl font-extrabold text-gray-900">
                        Campus Vehicle Booking
                    </h1>

                    <p class="text-gray-500 mt-2">
                        Login :
                    </p>
                </div>

                <!-- Form -->
                <form action="${pageContext.request.contextPath}/PreLoginController" method="POST" class="space-y-5">

                    <!-- STAFF -->
                    <div>
                        <button type="submit" name="loginType" value="staff"
                                class="w-full py-4 bg-blue-600 hover:bg-blue-700 text-white font-bold rounded-xl transition hover:scale-[1.02]">
                            🔐 STAFF / ADMIN
                        </button>
                    </div>

                    <!-- Divider -->
                    <div class="flex items-center my-2">
                        <div class="flex-grow h-px bg-gray-200"></div>
                        <span class="px-3 text-xs text-gray-400">OR</span>
                        <div class="flex-grow h-px bg-gray-200"></div>
                    </div>

                    <!-- OTHERS -->
                    <div>
                        <button type="submit" name="loginType" value="others"
                                class="w-full py-4 bg-gray-200 hover:bg-gray-300 text-gray-900 font-bold rounded-xl transition hover:scale-[1.02]">
                            👤 OTHERS
                        </button>
                    </div>

                </form>

                <!-- Note -->
                <p class="text-xs text-gray-400 mt-8">
                    Staff/Admin account is managed by administrator.
                </p>

            </div>

            <!-- FOOTER (fixed position) -->
            <p class="text-[11px] text-gray-400 mt-6 text-center">
                © 2026 Campus Vehicle Booking System | UMT
            </p>

        </div>

    </body>
</html>