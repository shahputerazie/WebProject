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
                        <h1 class="text-2xl font-bold text-gray-800">
                            Fleet Management
                        </h1>

                        <p class="text-sm text-gray-500">
                            Manage university vehicles, availability, capacity, and maintenance status.
                        </p>
                    </div>

                    <a href="${pageContext.request.contextPath}/pages/staff/addVehicle.jsp"
                       class="bg-blue-600 hover:bg-blue-700 text-white px-5 py-2.5 rounded-xl font-semibold transition-colors flex items-center gap-2 shadow-lg shadow-blue-100">

                        <span class="material-symbols-outlined text-lg">
                            add
                        </span>

                        Add Vehicle
                    </a>
                </div>

                <!-- Success Message -->
                <c:if test="${not empty param.success}">
                    <div class="bg-green-50 border-l-4 border-green-500 text-green-700 p-4 rounded-lg mb-6 flex items-center gap-3">

                        <span class="material-symbols-outlined">
                            check_circle
                        </span>

                        <p class="text-sm font-medium">
                            Vehicle action completed successfully.
                        </p>
                    </div>
                </c:if>

                <!-- Error Message -->
                <c:if test="${not empty param.error}">
                    <div class="bg-red-50 border-l-4 border-red-500 text-red-700 p-4 rounded-lg mb-6 flex items-center gap-3">

                        <span class="material-symbols-outlined">
                            error
                        </span>

                        <p class="text-sm font-medium">
                            Something went wrong. Please try again.
                        </p>
                    </div>
                </c:if>

                <!-- Search Section -->
                <form action="${pageContext.request.contextPath}/VehicleController"
                      method="GET"
                      class="bg-white p-5 rounded-2xl shadow-sm border border-gray-200 mb-6">

                    <input type="hidden" name="action" value="list">

                    <div class="grid grid-cols-1 md:grid-cols-3 gap-4">

                        <!-- Search Plate -->
                        <div>
                            <label class="block text-sm font-semibold text-gray-700 mb-2">
                                Search Plate
                            </label>

                            <input type="text"
                                   name="keyword"
                                   value="${param.keyword}"
                                   placeholder="e.g. VAA1234"
                                   class="w-full rounded-xl border-gray-300 focus:ring-2 focus:ring-blue-500">
                        </div>

                        <!-- Vehicle Type -->
                        <div>
                            <label class="block text-sm font-semibold text-gray-700 mb-2">
                                Vehicle Type
                            </label>

                            <select name="type"
                                    class="w-full rounded-xl border-gray-300 focus:ring-2 focus:ring-blue-500">

                                <option value="" ${empty param.type ? 'selected' : ''}>All Types</option>
                                <option value="SEDAN" ${param.type == 'SEDAN' ? 'selected' : ''}>Sedan</option>
                                <option value="SUV" ${param.type == 'SUV' ? 'selected' : ''}>SUV</option>

                            </select>
                        </div>

                        <!-- Status -->
                        <div>
                            <label class="block text-sm font-semibold text-gray-700 mb-2">
                                Status
                            </label>

                            <select name="status"
                                    class="w-full rounded-xl border-gray-300 focus:ring-2 focus:ring-blue-500">

                                <option value="" ${empty param.status ? 'selected' : ''}>All Status</option>
                                <option value="AVAILABLE" ${param.status == 'AVAILABLE' ? 'selected' : ''}>Available</option>
                                <option value="MAINTENANCE" ${param.status == 'MAINTENANCE' ? 'selected' : ''}>Maintenance</option>
                                <option value="UNAVAILABLE" ${param.status == 'UNAVAILABLE' ? 'selected' : ''}>Unavailable</option>

                            </select>
                        </div>

                    </div>

                    <!-- Buttons -->
                    <div class="flex justify-end gap-3 mt-5">

                        <a href="${pageContext.request.contextPath}/VehicleController?action=list"
                           class="px-5 py-2.5 rounded-xl bg-gray-100 text-gray-600 font-semibold hover:bg-gray-200">

                            Reset
                        </a>

                        <button type="submit"
                                class="px-6 py-2.5 rounded-xl bg-blue-600 text-white font-semibold hover:bg-blue-700 flex items-center gap-2">

                            <span class="material-symbols-outlined text-lg">
                                search
                            </span>

                            Search
                        </button>
                    </div>
                </form>

                <!-- Vehicle Table -->
                <div class="bg-white rounded-2xl shadow-sm border border-gray-200 overflow-hidden">

                    <!-- Table Header -->
                    <div class="px-6 py-4 border-b border-gray-100">

                        <h2 class="font-bold text-gray-800">
                            Vehicle Inventory
                        </h2>

                        <p class="text-xs text-gray-500">
                            List of registered fleet vehicles
                        </p>
                    </div>

                    <!-- Table -->
                    <table class="w-full text-left border-collapse" data-sortable-table="true">

                        <thead class="bg-gray-50 text-gray-600 text-xs uppercase tracking-wider">

                            <tr>
                                <th class="p-4 font-semibold">No.</th>
                                <th class="p-4 font-semibold" data-sortable-type="text">License Plate</th>
                                <th class="p-4 font-semibold" data-sortable-type="text">Type</th>
                                <th class="p-4 font-semibold" data-sortable-type="number">Capacity</th>
                                <th class="p-4 font-semibold" data-sortable-type="text">Status</th>
                                <th class="p-4 font-semibold text-right">Actions</th>
                            </tr>

                        </thead>

                        <tbody class="divide-y divide-gray-100">

                            <!-- Vehicle Rows -->
                            <c:forEach var="v" items="${vehicles}" varStatus="loop">

                                <tr class="hover:bg-gray-50">

                                    <!-- Number -->
                                    <td class="p-4 text-sm text-gray-500">
                                        ${loop.index + 1}
                                    </td>

                                    <!-- Plate -->
                                    <td class="p-4 font-semibold text-gray-800">
                                        ${v.licensePlate}
                                    </td>

                                    <!-- Type -->
                                    <td class="p-4 text-sm text-gray-700">
                                        ${v.type}
                                    </td>

                                    <!-- Capacity -->
                                    <td class="p-4 text-sm text-gray-700">
                                        ${v.capacity} seats
                                    </td>

                                    <!-- Status -->
                                    <td class="p-4">

                                        <span class="px-3 py-1 rounded-full text-xs font-bold
                                              ${v.status == 'AVAILABLE' ? 'bg-green-100 text-green-700' :
                                                v.status == 'MAINTENANCE' ? 'bg-yellow-100 text-yellow-700' :
                                                'bg-red-100 text-red-700'}">

                                            ${v.status}

                                        </span>
                                    </td>

                                    <!-- Actions -->
                                    <td class="p-4 text-right">
                                        <div class="flex justify-end gap-3">
                                            <a href="${pageContext.request.contextPath}/VehicleController?action=edit&id=${v.id}"
                                               class="inline-flex items-center gap-2 rounded-full border border-blue-200 bg-blue-50 px-4 py-2 text-sm font-semibold text-blue-700 shadow-sm transition-all hover:-translate-y-0.5 hover:bg-blue-100 hover:shadow-md focus:outline-none focus:ring-2 focus:ring-blue-300 focus:ring-offset-2">
                                                <span class="material-symbols-outlined text-[18px]">
                                                    edit
                                                </span>
                                                Edit
                                            </a>

                                            <form action="${pageContext.request.contextPath}/VehicleController"
                                                  method="POST"
                                                  onsubmit="return confirm('Delete this vehicle?');">
                                                <input type="hidden" name="action" value="delete">
                                                <input type="hidden" name="id" value="${v.id}">

                                                <button type="submit"
                                                        class="inline-flex items-center gap-2 rounded-full border border-rose-200 bg-rose-50 px-4 py-2 text-sm font-semibold text-rose-700 shadow-sm transition-all hover:-translate-y-0.5 hover:bg-rose-100 hover:shadow-md focus:outline-none focus:ring-2 focus:ring-rose-300 focus:ring-offset-2">
                                                    <span class="material-symbols-outlined text-[18px]">
                                                        delete
                                                    </span>
                                                    Delete
                                                </button>
                                            </form>
                                        </div>
                                    </td>

                                </tr>

                            </c:forEach>

                            <!-- Empty -->
                            <c:if test="${empty vehicles}">
                                <tr>

                                    <td colspan="6"
                                        class="p-10 text-center text-gray-400">

                                        No vehicles found.

                                    </td>

                                </tr>
                            </c:if>

                        </tbody>

                    </table>

                </div>

            </div>

        </main>
        <script src="${pageContext.request.contextPath}/assets/js/table-sort.js"></script>

    </body>

</html>
