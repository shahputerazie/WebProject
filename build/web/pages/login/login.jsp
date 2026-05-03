<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Login | University Vehicle Booking</title>
    <script src="https://cdn.tailwindcss.com?plugins=forms"></script>
    <link href="https://fonts.googleapis.com/css2?family=Manrope:wght@400;600;700;800&display=swap" rel="stylesheet"/>
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined" rel="stylesheet"/>
</head>

<body class="${param.loginType == 'staff' 
              ? 'bg-slate-100 font-sans flex items-center justify-center min-h-screen' 
              : 'bg-gray-50 font-sans flex items-center justify-center min-h-screen'}">

<div class="max-w-md w-full p-8">

    <div class="mb-6">
        <a href="${pageContext.request.contextPath}/pages/login/preLogin.jsp"
           class="${param.loginType == 'staff' 
                    ? 'inline-flex items-center gap-2 text-sm font-medium text-slate-500 hover:text-slate-900 transition' 
                    : 'inline-flex items-center gap-2 text-sm font-medium text-gray-500 hover:text-blue-600 transition'}">
            <span class="text-lg">←</span>
            <span>Back</span>
        </a>
    </div>

    <c:choose>
        <c:when test="${param.loginType == 'staff'}">
            <div class="text-center mb-10">
                <div class="mx-auto w-16 h-16 rounded-2xl bg-slate-900 flex items-center justify-center mb-5 shadow-md">
                    <span class="material-symbols-outlined text-white text-4xl">admin_panel_settings</span>
                </div>
                <h1 class="text-3xl font-extrabold text-slate-900">Staff / Admin Login</h1>
                <p class="text-slate-500 mt-2">Authorized access for system management</p>
            </div>
        </c:when>

        <c:otherwise>
            <div class="text-center mb-10">
                <h1 class="text-3xl font-extrabold text-gray-900">Welcome Back</h1>
                <p class="text-gray-500 mt-2">Sign in to manage your bookings</p>
            </div>
        </c:otherwise>
    </c:choose>

    <c:if test="${param.error != null}">
        <div class="bg-red-100 text-red-700 p-4 rounded-xl mb-6 text-sm border border-red-200">
            Invalid email, password, or login type. Please try again.
        </div>
    </c:if>

    <form action="${pageContext.request.contextPath}/LoginController" method="POST"
          class="${param.loginType == 'staff' 
                   ? 'bg-white p-8 rounded-2xl shadow-lg border border-slate-200 space-y-5' 
                   : 'bg-white p-8 rounded-2xl shadow-sm border space-y-5'}">

        <input type="hidden" name="loginType" value="${param.loginType}">

        <div>
            <label class="block text-sm font-semibold mb-2 ${param.loginType == 'staff' ? 'text-slate-800' : 'text-gray-800'}">
                University Email
            </label>
            <input type="email" name="email"
                   class="w-full rounded-xl border-gray-300 ${param.loginType == 'staff' ? 'focus:ring-2 focus:ring-slate-700' : 'focus:ring-2 focus:ring-blue-500'}"
                   placeholder="name@umt.edu.my" required>
        </div>

        <div>
            <label class="block text-sm font-semibold mb-2 ${param.loginType == 'staff' ? 'text-slate-800' : 'text-gray-800'}">
                Password
            </label>
            <input type="password" name="password"
                   class="w-full rounded-xl border-gray-300 ${param.loginType == 'staff' ? 'focus:ring-2 focus:ring-slate-700' : 'focus:ring-2 focus:ring-blue-500'}"
                   placeholder="••••••••" required>
        </div>

        <button type="submit"
                class="${param.loginType == 'staff' 
                         ? 'w-full bg-slate-900 text-white py-3 rounded-xl font-bold hover:bg-slate-800 transition-colors' 
                         : 'w-full bg-blue-600 text-white py-3 rounded-xl font-bold hover:bg-blue-700 transition-colors'}">
            Sign In
        </button>

        <c:if test="${param.loginType != 'staff'}">
            <p class="mt-6 text-sm text-gray-500 text-center">
                Don't have an account?
                <a href="${pageContext.request.contextPath}/pages/login/register.jsp"
                   class="font-semibold text-blue-600 hover:text-blue-700 hover:underline transition">
                    Register here
                </a>
            </p>
        </c:if>

        <c:if test="${param.loginType == 'staff'}">
            <p class="mt-6 text-xs text-slate-400 text-center">
                Staff/Admin accounts are managed by the administrator.
            </p>
        </c:if>
    </form>
</div>

</body>
</html>