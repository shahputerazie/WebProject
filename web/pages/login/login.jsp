<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>Login | University Vehicle Booking</title>
        <script src="https://cdn.tailwindcss.com?plugins=forms"></script>
        <link href="https://fonts.googleapis.com/css2?family=Manrope:wght@400;600;700;800&display=swap" rel="stylesheet"/>
    </head>

    <body class="bg-gray-50 font-sans flex items-center justify-center min-h-screen">

        <div class="max-w-md w-full p-8">
            <div class="text-center mb-10">
                <h1 class="text-3xl font-extrabold text-gray-900">Welcome Back</h1>
                <p class="text-gray-500 mt-2">Sign in to manage your bookings</p>
            </div>

            <c:if test="${param.error != null}">
                <div class="bg-red-100 text-red-700 p-4 rounded-xl mb-6 text-sm border border-red-200">
                    Invalid email or password. Please try again.
                </div>
            </c:if>

            <form action="LoginController" method="POST" class="bg-white p-8 rounded-2xl shadow-sm border space-y-5">
                <div>
                    <label class="block text-sm font-semibold mb-2">University Email</label>
                    <input type="email" name="email" 
                           class="w-full rounded-xl border-gray-300 focus:ring-2 focus:ring-blue-500" 
                           placeholder="name@umt.edu.my" required>
                </div>

                <div>
                    <label class="block text-sm font-semibold mb-2">Password</label>
                    <input type="password" name="password" 
                           class="w-full rounded-xl border-gray-300 focus:ring-2 focus:ring-blue-500" 
                           placeholder="••••••••" required>
                </div>

                <button type="submit" 
                        class="w-full bg-blue-600 text-white py-3 rounded-xl font-bold hover:bg-blue-700 transition-colors">
                    Sign In
                </button>

                <p class="text-center text-sm text-gray-500 mt-4">
                    Don't have an account? 
                    <a href="register.jsp" class="text-blue-600 font-semibold hover:underline">Register here</a>
                </p>
            </form>
        </div>

    </body>
</html>