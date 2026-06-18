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

                <c:if test="${param.status == 'success'}">
                    <div class="mb-4 rounded-xl border border-green-200 bg-green-50 px-4 py-3 text-sm text-green-700">
                        User record updated successfully.
                    </div>
                </c:if>
                <c:if test="${param.status == 'error'}">
                    <div class="mb-4 rounded-xl border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700">
                        Update failed. Please try again.
                    </div>
                </c:if>

                <div class="bg-white rounded-2xl shadow-sm border overflow-hidden">
                    <table class="w-full text-left" data-sortable-table="true">
                        <thead class="bg-gray-50 border-b">
                            <tr>
                                <th class="p-4 font-semibold text-sm text-gray-600" data-sortable-type="text">User Details</th>
                                <th class="p-4 font-semibold text-sm text-gray-600" data-sortable-type="text">Role</th>
                                <th class="p-4 font-semibold text-sm text-gray-600" data-sortable-type="text">Status</th>
                                <th class="p-4 font-semibold text-sm text-gray-600 text-right">Actions</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y">
                            <c:forEach var="u" items="${users}">
                                <tr>
                                    <td class="p-4">
                                        <div class="font-bold text-gray-800">${u.name}</div>
                                        <div class="text-xs text-gray-500">${u.email}</div>
                                    </td>
                                    <td class="p-4 text-sm">
                                        <form action="${pageContext.request.contextPath}/AdminUserController" method="POST" class="flex gap-2">
                                            <input type="hidden" name="action" value="modifyRole">
                                            <input type="hidden" name="userId" value="${u.userId}">
                                            <input type="hidden" name="isActive" value="${u.active}">
                                            <select name="role" onchange="this.form.submit()" class="text-xs rounded-lg border-gray-300 py-1">
                                                <option value="STUDENT" ${u.role eq 'STUDENT' ? 'selected' : ''}>Student</option>
                                                <option value="LECTURER" ${u.role eq 'LECTURER' ? 'selected' : ''}>Lecturer</option>
                                                <option value="STAFF" ${u.role eq 'STAFF' ? 'selected' : ''}>Staff</option>
                                                <option value="ADMIN" ${u.role eq 'ADMIN' ? 'selected' : ''}>Admin</option>
                                            </select>
                                        </form>
                                    </td>
                                    <td class="p-4">
                                        <span class="px-2 py-1 rounded-full text-[10px] font-bold ${u.active ? 'bg-green-100 text-green-700' : 'bg-red-100 text-red-700'}">
                                            ${u.active ? 'ACTIVE' : 'INACTIVE'}
                                        </span>
                                    </td>
                                    <td class="p-4 text-right">
                                        <div class="flex justify-end">
                                            <c:if test="${u.active}">
                                                <form action="${pageContext.request.contextPath}/AdminUserController" method="POST" onsubmit="return confirm('Deactivate this account?')">
                                                    <input type="hidden" name="action" value="deactivate">
                                                    <input type="hidden" name="userId" value="${u.userId}">
                                                    <button type="submit"
                                                            class="inline-flex items-center gap-2 rounded-full border border-rose-200 bg-rose-50 px-4 py-2 text-sm font-semibold text-rose-700 shadow-sm transition-all hover:-translate-y-0.5 hover:bg-rose-100 hover:shadow-md focus:outline-none focus:ring-2 focus:ring-rose-300 focus:ring-offset-2">
                                                        <span class="material-symbols-outlined text-[18px]">person_off</span>
                                                        Deactivate
                                                    </button>
                                                </form>
                                            </c:if>
                                            <c:if test="${not u.active}">
                                                <form action="${pageContext.request.contextPath}/AdminUserController" method="POST">
                                                    <input type="hidden" name="action" value="activate">
                                                    <input type="hidden" name="userId" value="${u.userId}">
                                                    <input type="hidden" name="role" value="${u.role}">
                                                    <button type="submit"
                                                            class="inline-flex items-center gap-2 rounded-full border border-blue-200 bg-blue-50 px-4 py-2 text-sm font-semibold text-blue-700 shadow-sm transition-all hover:-translate-y-0.5 hover:bg-blue-100 hover:shadow-md focus:outline-none focus:ring-2 focus:ring-blue-300 focus:ring-offset-2">
                                                        <span class="material-symbols-outlined text-[18px]">person_check</span>
                                                        Activate
                                                    </button>
                                                </form>
                                            </c:if>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </div>
        </main>
        <script src="${pageContext.request.contextPath}/assets/js/table-sort.js"></script>
    </body>
</html>
