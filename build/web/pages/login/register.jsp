<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>Register | University Vehicle Booking</title>

        <script src="https://cdn.tailwindcss.com?plugins=forms"></script>
        <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined" rel="stylesheet"/>
        <link href="https://fonts.googleapis.com/css2?family=Manrope:wght@400;600;700;800&display=swap" rel="stylesheet"/>
    </head>

    <body class="bg-gray-50 font-sans min-h-screen flex items-center justify-center p-6">
        
        <%
            String error = request.getParameter("error");
            if ("email".equals(error)) {
        %>
            <script>
                alert("⚠️ This email is already registered. Please use another email.");
            </script>
        <%
            }
        %>
        
        <div class="w-full max-w-2xl">

            <!-- Header -->
            <div class="text-center mb-8">
                <h1 class="text-3xl font-extrabold text-gray-900">Create New Account</h1>
                <p class="text-gray-500 mt-2">Join the University Vehicle Booking System</p>
            </div>

            <!-- Error Box -->
            <div id="errorMessage"
                 class="hidden bg-red-100 text-red-700 p-4 rounded-xl mb-6 text-sm border border-red-200">
                Passwords do not match.
            </div>

            <!-- FORM -->
            <form id="registerForm"
                  action="${pageContext.request.contextPath}/RegistrationController"
                  method="POST"
                  onsubmit="return validateForm()">

                <input type="hidden" name="action" value="register">

                <div class="grid grid-cols-2 gap-6">

                    <!-- Full Name -->
                    <div class="col-span-2">
                        <label class="block text-sm font-semibold mb-2 text-gray-700">Full Name</label>
                        <input type="text" name="name"
                               class="w-full rounded-xl border-gray-300 focus:ring-2 focus:ring-blue-500 p-2"
                               placeholder="Enter your full name" required>
                    </div>

                    <!-- Email -->
                    <div>
                        <label class="block text-sm font-semibold mb-2 text-gray-700">University Email</label>
                        <input type="email" name="email"
                               class="w-full rounded-xl border-gray-300 focus:ring-2 focus:ring-blue-500 p-2"
                               placeholder="S12345@umt.edu.my" required>
                    </div>

                    <!-- Phone -->
                    <div>
                        <label class="block text-sm font-semibold mb-2 text-gray-700">Phone Number</label>
                        <input type="text" name="phone"
                               class="w-full rounded-xl border-gray-300 focus:ring-2 focus:ring-blue-500 p-2"
                               placeholder="012-3456789" required>
                    </div>

                    <!-- Role -->
                    <div>
                        <label class="block text-sm font-semibold mb-2 text-gray-700">Account Type</label>
                        <select name="roleId"
                                class="w-full rounded-xl border-gray-300 focus:ring-2 focus:ring-blue-500 p-2">
                            <option value="1">Student</option>
                            <option value="2">Lecturer</option>
                        </select>
                    </div>

                    <!-- Password -->
                    <div>
                        <label class="block text-sm font-semibold mb-2 text-gray-700">Password</label>
                        <input type="password" id="password" name="password"
                               class="w-full rounded-xl border-gray-300 focus:ring-2 focus:ring-blue-500 p-2"
                               required>
                    </div>

                    <!-- Confirm Password -->
                    <div>
                        <label class="block text-sm font-semibold mb-2 text-gray-700">Confirm Password</label>
                        <input type="password" id="confirmPassword" name="confirmPassword"
                               class="w-full rounded-xl border-gray-300 focus:ring-2 focus:ring-blue-500 p-2"
                               required>
                    </div>

                </div>

                <!-- Button -->
                <div class="pt-6">
                    <button type="submit"
                            class="w-full bg-blue-600 text-white py-3 rounded-xl font-bold hover:bg-blue-700 transition">
                        Register Account
                    </button>
                </div>

                <!-- Login Link -->
                <div class="text-center mt-4 text-sm text-gray-600">
                    Already have an account?
                    <a href="${pageContext.request.contextPath}/pages/login/login.jsp"
                       class="text-blue-600 font-bold hover:underline">
                        Login here
                    </a>
                </div>

            </form>
        </div>

        <!-- JS VALIDATION -->
        <script>
            function validateForm() {
                const password = document.getElementById("password").value;
                const confirm = document.getElementById("confirmPassword").value;
                const errorBox = document.getElementById("errorMessage");

                if (password !== confirm) {
                    errorBox.classList.remove("hidden");
                    return false;
                }

                errorBox.classList.add("hidden");
                return true;
            }
        </script>

    </body>
</html>