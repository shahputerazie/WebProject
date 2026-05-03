<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>My Profile | Vehicle Booking</title>
        <script src="https://cdn.tailwindcss.com?plugins=forms"></script>
        <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined" rel="stylesheet"/>
    </head>

    <body class="bg-gray-50 font-sans min-h-screen flex items-center justify-center p-6">

        <div class="w-full max-w-2xl">

            <div class="mb-6 flex items-center gap-4">
                <a href="${pageContext.request.contextPath}/pages/user/userDashboard.jsp"
                   class="p-2 bg-white rounded-full border hover:bg-gray-100 transition">
                    <span class="material-symbols-outlined text-gray-600">arrow_back</span>
                </a>
                <h1 class="text-2xl font-bold text-gray-800">Account Settings</h1>
            </div>

            <c:if test="${param.status == 'updated'}">
                <div class="bg-green-100 text-green-700 p-4 rounded-xl mb-6 text-sm border border-green-200">
                    Profile updated successfully.
                </div>
            </c:if>

            <c:if test="${param.status == 'error'}">
                <div class="bg-red-100 text-red-700 p-4 rounded-xl mb-6 text-sm border border-red-200">
                    Failed to update profile.
                </div>
            </c:if>

            <div class="bg-white rounded-3xl shadow-sm border overflow-hidden">
                <div class="bg-blue-600 p-8 text-white flex items-center gap-6">
                    <div class="h-20 w-20 bg-blue-400 rounded-2xl flex items-center justify-center">
                        <span class="material-symbols-outlined text-4xl">person</span>
                    </div>

                    <div>
                        <h2 class="text-xl font-bold">${user.name}</h2>
                        <p class="opacity-80 text-sm">Role ID: ${user.roleId}</p>
                    </div>
                </div>

                <form action="${pageContext.request.contextPath}/ProfileController"
                      method="POST"
                      class="p-8 space-y-6"
                      onsubmit="return validatePasswords()">

                    <div class="grid grid-cols-2 gap-6">

                        <div class="col-span-2">
                            <label class="block text-sm font-semibold mb-2">Full Name</label>
                            <input type="text" name="name" value="${user.name}"
                                   class="w-full rounded-xl border-gray-300 focus:ring-2 focus:ring-blue-500" required>
                        </div>

                        <div>
                            <label class="block text-sm font-semibold mb-2">Email Address</label>
                            <input type="email" value="${user.email}"
                                   class="w-full rounded-xl border-gray-100 bg-gray-50 text-gray-500 cursor-not-allowed"
                                   readonly>
                        </div>

                        <div>
                            <label class="block text-sm font-semibold mb-2">Phone Number</label>
                            <input type="text" name="phone" value="${user.phone}"
                                   class="w-full rounded-xl border-gray-300 focus:ring-2 focus:ring-blue-500" required>
                        </div>
                    </div>

                    <div class="pt-6 border-t">
                        <h3 class="font-bold text-gray-800 mb-4">Security & Password</h3>

                        <div class="grid grid-cols-2 gap-6">
                            <div>
                                <label class="block text-sm font-semibold mb-2">New Password</label>
                                <input type="password" id="newPass" name="newPassword"
                                       class="w-full rounded-xl border-gray-300 focus:ring-2 focus:ring-blue-500">
                            </div>

                            <div>
                                <label class="block text-sm font-semibold mb-2">Confirm New Password</label>
                                <input type="password" id="confirmPass"
                                       class="w-full rounded-xl border-gray-300 focus:ring-2 focus:ring-blue-500">
                            </div>
                        </div>

                        <p id="errorMsg" class="text-red-500 text-xs mt-2 hidden">
                            Passwords do not match!
                        </p>
                    </div>

                    <div class="flex justify-end pt-4">
                        <button type="submit"
                                class="bg-blue-600 text-white px-8 py-3 rounded-xl font-bold hover:bg-blue-700 transition">
                            Save Changes
                        </button>
                    </div>
                </form>
            </div>
        </div>

        <script>
            function validatePasswords() {
                const p1 = document.getElementById('newPass').value;
                const p2 = document.getElementById('confirmPass').value;

                if (p1 && p1 !== p2) {
                    document.getElementById('errorMsg').classList.remove('hidden');
                    return false;
                }

                return true;
            }
        </script>

    </body>
</html>