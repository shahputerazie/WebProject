<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

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

        <div class="w-full max-w-2xl">
            <div class="text-center mb-8">
                <h1 class="text-3xl font-extrabold text-gray-900">Create New Account</h1>
                <p class="text-gray-500 mt-2">Join the University Vehicle Booking System [cite: 52]</p>
            </div>

            <div id="errorMessage" class="hidden bg-red-100 text-red-700 p-4 rounded-xl mb-6 text-sm border border-red-200">
                Passwords do not match.
            </div>

            <form id="registerForm" action="RegistrationController" method="POST" 
                  class="bg-white p-10 rounded-3xl shadow-sm border space-y-6"
                  onsubmit="return validateForm()">

                <input type="hidden" name="action" value="register">

                <div class="grid grid-cols-2 gap-6">
                    <div class="col-span-2">
                        <label class="block text-sm font-semibold mb-2 text-gray-700">Full Name</label>
                        <div class="relative">
                            <span class="material-symbols-outlined absolute left-3 top-2.5 text-gray-400 text-xl">person</span>
                            <input type="text" name="name" 
                                   class="w-full pl-10 rounded-xl border-gray-300 focus:ring-2 focus:ring-blue-500" 
                                   placeholder="Enter your full name" required>
                        </div>
                    </div>

                    <div>
                        <label class="block text-sm font-semibold mb-2 text-gray-700">University Email</label>
                        <div class="relative">
                            <span class="material-symbols-outlined absolute left-3 top-2.5 text-gray-400 text-xl">mail</span>
                            <input type="email" name="email" 
                                   class="w-full pl-10 rounded-xl border-gray-300 focus:ring-2 focus:ring-blue-500" 
                                   placeholder="S12345@umt.edu.my" required>
                        </div>
                    </div>

                    <div>
                        <label class="block text-sm font-semibold mb-2 text-gray-700">Phone Number [cite: 120]</label>
                        <div class="relative">
                            <span class="material-symbols-outlined absolute left-3 top-2.5 text-gray-400 text-xl">call</span>
                            <input type="text" name="phone" 
                                   class="w-full pl-10 rounded-xl border-gray-300 focus:ring-2 focus:ring-blue-500" 
                                   placeholder="012-3456789" required>
                        </div>
                    </div>

                    <div>
                        <label class="block text-sm font-semibold mb-2 text-gray-700">Account Type</label>
                        <select name="roleId" class="w-full rounded-xl border-gray-300 focus:ring-2 focus:ring-blue-500">
                            <option value="1">Student (Club Leader) </option>
                            <option value="2">Lecturer </option>
                            <option value="3">Staff/Admin [cite: 83]</option>
                        </select>
                    </div>

                    <div class="hidden grid-cols-1"></div> <div>
                        <label class="block text-sm font-semibold mb-2 text-gray-700">Password</label>
                        <input type="password" id="password" name="password" 
                               class="w-full rounded-xl border-gray-300 focus:ring-2 focus:ring-blue-500" 
                               required>
                    </div>

                    <div>
                        <label class="block text-sm font-semibold mb-2 text-gray-700">Confirm Password</label>
                        <input type="password" id="confirmPassword" 
                               class="w-full rounded-xl border-gray-300 focus:ring-2 focus:ring-blue-500" 
                               required>
                    </div>
                </div>

                <div class="flex flex-col gap-4 pt-4">
                    <button type="submit" 
                            class="w-full bg-blue-600 text-white py-3.5 rounded-xl font-bold hover:bg-blue-700 flex items-center justify-center gap-2 transition shadow-lg shadow-blue-100">
                        <span class="material-symbols-outlined">person_add</span>
                        Register Account
                    </button>

                    <a href="login.jsp" class="text-center text-sm text-gray-500 hover:text-blue-600 transition">
                        Already have an account? <span class="font-bold underline">Login</span>
                    </a>
                </div>
            </form>
        </div>

        <script>
            function validateForm() {
                const password = document.getElementById("password").value;
                const confirm = document.getElementById("confirmPassword").value;
                const errorBox = document.getElementById("errorMessage");

                if (password !== confirm) {
                    errorBox.classList.remove("hidden");
                    window.scrollTo(0, 0);
                    return false;
                }
                return true;
            }
        </script>
    </body>
</html>