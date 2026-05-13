<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>Admin | User Management</title>
        <script src="https://cdn.tailwindcss.com?plugins=forms"></script>
        <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined" rel="stylesheet"/>
    </head>
    <body class="bg-gray-50 font-sans">
        <jsp:include page="/partials/sidebar.jsp">
            <jsp:param name="active" value="users" />
        </jsp:include>

        <main class="pl-64 min-h-screen">
            <jsp:include page="/partials/navbar.jsp" />

            <div class="p-8 mt-16">
                <div class="mb-8 flex justify-between items-end">
                    <div>
                        <h1 class="text-2xl font-bold text-gray-800">User Management</h1>
                        <p class="text-gray-500 text-sm">Control access levels and manage active accounts.</p>
                    </div>
                </div>

                <div class="bg-white rounded-2xl shadow-sm border overflow-hidden">
                    <table class="w-full text-left">
                        <thead class="bg-gray-50 border-b">
                            <tr>
                                <th class="p-4 font-semibold text-sm text-gray-600">User Details</th>
                                <th class="p-4 font-semibold text-sm text-gray-600">Role</th>
                                <th class="p-4 font-semibold text-sm text-gray-600">Status</th>
                                <th class="p-4 font-semibold text-sm text-gray-600 text-right">Actions</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y">
                            <c:forEach var="u" items="${userList}">
                                <tr>
                                    <td class="p-4">
                                        <div class="font-bold text-gray-800">${u.name}</div>
                                        <div class="text-xs text-gray-500">${u.email}</div>
                                    </td>
                                    <td class="p-4 text-sm">
                                        <form action="AdminController" method="POST" class="flex gap-2">
                                            <input type="hidden" name="action" value="updateRole">
                                            <input type="hidden" name="userId" value="${u.userId}">
                                            <select name="roleId" onchange="this.form.submit()" class="text-xs rounded-lg border-gray-300 py-1">
                                                <option value="1" ${u.roleId == 1 ? 'selected' : ''}>Student</option>
                                                <option value="2" ${u.roleId == 2 ? 'selected' : ''}>Lecturer</option>
                                                <option value="3" ${u.roleId == 3 ? 'selected' : ''}>Staff/Admin</option>
                                            </select>
                                        </form>
                                    </td>
                                    <td class="p-4">
                                        <span class="px-2 py-1 rounded-full text-[10px] font-bold ${u.isActive ? 'bg-green-100 text-green-700' : 'bg-red-100 text-red-700'}">
                                            ${u.isActive ? 'ACTIVE' : 'INACTIVE'}
                                        </span>
                                    </td>
                                    <td class="p-4 text-right">
                                        <c:if test="${u.isActive}">
                                            <form action="AdminController" method="POST" onsubmit="return confirm('Deactivate this account?')">
                                                <input type="hidden" name="action" value="deactivate">
                                                <input type="hidden" name="userId" value="${u.userId}">
                                                <button type="submit" class="text-red-500 hover:text-red-700 text-sm font-semibold">Deactivate</button>
                                            </form>
                                        </c:if>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </div>
        </main>
    </body>
</html>