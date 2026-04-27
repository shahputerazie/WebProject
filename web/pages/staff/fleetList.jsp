<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>Staff | Fleet Management</title>

        <script src="https://cdn.tailwindcss.com?plugins=forms"></script>
        <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined" rel="stylesheet"/>
        <link href="https://fonts.googleapis.com/css2?family=Manrope:wght@400;600;700;800&display=swap" rel="stylesheet"/>
    </head>

    <body class="bg-gray-50 font-sans">

        <jsp:include page="/partials/sidebar.jsp">
            <jsp:param name="active" value="fleet" />
        </jsp:include>

        <main class="pl-64 min-h-screen">

            <jsp:include page="/partials/navbar.jsp" />

            <div class="p-8 mt-16">

                <!-- Header -->
                <div class="flex justify-between items-center mb-8">
                    <div>
                        <h1 class="text-2xl font-bold text-gray-800">Fleet Management</h1>
                        <p class="text-sm text-gray-500">
                            Manage university vehicles, availability, capacity, and maintenance status.
                        </p>
                    </div>

                    <a href="${pageContext.request.contextPath}/pages/staff/addVehicle.jsp"
                       class="bg-blue-600 hover:bg-blue-700 text-white px-5 py-2.5 rounded-xl font-semibold transition-colors flex items-center gap-2 shadow-lg shadow-blue-100">
                        <span class="material-symbols-outlined text-lg">add</span>
                        Add Vehicle
                    </a>
                </div>

                <!-- Success -->
                <c:if test="${not empty param.success}">
                    <div class="bg-green-50 border-l-4 border-green-500 text-green-700 p-4 rounded-lg mb-6 flex items-center gap-3">
                        <span class="material-symbols-outlined">check_circle</span>
                        <p class="text-sm font-medium">Vehicle action completed successfully.</p>
                    </div>
                </c:if>

                <!-- Error -->
                <c:if test="${not empty param.error}">
                    <div class="bg-red-50 border-l-4 border-red-500 text-red-700 p-4 rounded-lg mb-6 flex items-center gap-3">
                        <span class="material-symbols-outlined">error</span>
                        <p class="text-sm font-medium">Something went wrong. Please try again.</p>
                    </div>
                </c:if>

                <!-- Search -->
                <form action="${pageContext.request.contextPath}/VehicleController" method="GET"
                      class="bg-white p-5 rounded-2xl shadow-sm border border-gray-200 mb-6">

                    <input type="hidden" name="action" value="list">

                    <div class="grid grid-cols-1 md:grid-cols-3 gap-4">

                        <div>
                            <label class="block text-sm font-semibold text-gray-700 mb-2">Search Plate</label>
                            <input type="text" name="keyword"
                                   value="${param.keyword}"
                                   placeholder="e.g. VAA1234"
                                   class="w-full rounded-xl border-gray-300 focus:ring-2 focus:ring-blue-500">
                        </div>

                        <div>
                            <label class="block text-sm font-semibold text-gray-700 mb-2">Vehicle Type</label>
                            <select name="type"
                                    class="w-full rounded-xl border-gray-300 focus:ring-2 focus:ring-blue-500">
                                <option value="">All Types</option>
                                <option value="Bus">Bus</option>
                                <option value="Van">Van</option>
                                <option value="SUV">SUV</option>
                                <option value="Sedan">Sedan</option>
                            </select>
                        </div>

                        <div>
                            <label class="block text-sm font-semibold text-gray-700 mb-2">Status</label>
                            <select name="status"
                                    class="w-full rounded-xl border-gray-300 focus:ring-2 focus:ring-blue-500">
                                <option value="">All Status</option>
                                <option value="AVAILABLE">Available</option>
                                <option value="MAINTENANCE">Maintenance</option>
                                <option value="UNAVAILABLE">Unavailable</option>
                            </select>
                        </div>

                    </div>

                    <div class="flex justify-end gap-3 mt-5">
                        <a href="${pageContext.request.contextPath}/VehicleController?action=list"
                           class="px-5 py-2.5 rounded-xl bg-gray-100 text-gray-600 font-semibold hover:bg-gray-200">
                            Reset
                        </a>

                        <button type="submit"
                                class="px-6 py-2.5 rounded-xl bg-blue-600 text-white font-semibold hover:bg-blue-700 flex items-center gap-2">
                            <span class="material-symbols-outlined text-lg">search</span>
                            Search
                        </button>
                    </div>
                </form>

                <!-- Table -->
                <div class="bg-white rounded-2xl shadow-sm border border-gray-200 overflow-hidden">

                    <div class="px-6 py-4 border-b border-gray-100">
                        <h2 class="font-bold text-gray-800">Vehicle Inventory</h2>
                        <p class="text-xs text-gray-500">List of registered fleet vehicles</p>
                    </div>

                    <table class="w-full text-left border-collapse">

                        <thead class="bg-gray-50 text-gray-600 text-xs uppercase tracking-wider">
                            <tr>
                                <th class="p-4 font-semibold">ID</th>
                                <th class="p-4 font-semibold">License Plate</th>
                                <th class="p-4 font-semibold">Type</th>
                                <th class="p-4 font-semibold">Capacity</th>
                                <th class="p-4 font-semibold">Status</th>
                                <th class="p-4 font-semibold text-right">Actions</th>
                            </tr>
                        </thead>

                        <tbody class="divide-y divide-gray-100">

                            <c:forEach var="v" items="${vehicles}">
                                <tr class="hover:bg-gray-50">

                                    <td class="p-4 text-sm text-gray-500">
                                        #${v.id}
                                    </td>

                                    <td class="p-4 font-semibold text-gray-800">
                                        ${v.licensePlate}
                                    </td>

                                    <td class="p-4 text-sm text-gray-700">
                                        ${v.type}
                                    </td>

                                    <td class="p-4 text-sm text-gray-700">
                                        ${v.capacity} seats
                                    </td>

                                    <td class="p-4">
                                        <span class="px-3 py-1 rounded-full text-xs font-bold
                                              ${v.status == 'AVAILABLE' ? 'bg-green-100 text-green-700' :
                                                v.status == 'MAINTENANCE' ? 'bg-yellow-100 text-yellow-700' :
                                                'bg-red-100 text-red-700'}">
                                                  ${v.status}
                                              </span>
                                        </td>

                                        <td class="p-4 text-right">
                                            <div class="flex justify-end gap-2">

                                                <a href="${pageContext.request.contextPath}/VehicleController?action=edit&id=${v.id}"
                                                   class="p-2 rounded-lg text-blue-600 hover:bg-blue-50">
                                                    <span class="material-symbols-outlined">edit</span>
                                                </a>

                                                <form action="${pageContext.request.contextPath}/VehicleController" method="POST"
                                                      onsubmit="return confirm('Delete this vehicle?');">
                                                    <input type="hidden" name="action" value="delete">
                                                    <input type="hidden" name="id" value="${v.id}">

                                                    <button type="submit"
                                                            class="p-2 rounded-lg text-red-600 hover:bg-red-50">
                                                        <span class="material-symbols-outlined">delete</span>
                                                    </button>
                                                </form>

                                            </div>
                                        </td>

                                    </tr>
                                </c:forEach>

                                <c:if test="${empty vehicles}">
                                    <tr>
                                        <td colspan="6" class="p-10 text-center text-gray-400">
                                            No vehicles found.
                                        </td>
                                    </tr>
                                </c:if>

                            </tbody>

                        </table>

                    </div>

                </div>

            </main>

        </body>
    </html>