<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="utf-8"/>
        <title>Staff | Edit Vehicle</title>
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

            <div class="p-8 mt-16 max-w-3xl">
                <div class="mb-6">
                    <a href="${pageContext.request.contextPath}/VehicleController?action=list" class="text-blue-600 flex items-center gap-1 text-sm font-semibold">
                        <span class="material-symbols-outlined text-sm">arrow_back</span> Back to Inventory
                    </a>
                </div>

                <h1 class="text-2xl font-bold text-gray-800 mb-6">Update Vehicle Info</h1>

                <form action="${pageContext.request.contextPath}/VehicleController" method="POST" class="bg-white p-8 rounded-xl shadow-sm border border-gray-100">
                    <input type="hidden" name="action" value="update">
                    <input type="hidden" name="id" value="${vehicle.id}">

                    <div class="mb-8 p-4 bg-blue-50 rounded-xl border border-blue-100 flex items-center gap-4">
                        <div class="bg-blue-600 text-white p-2 rounded-lg">
                            <span class="material-symbols-outlined">directions_car</span>
                        </div>
                        <div>
                            <p class="text-xs text-blue-600 font-bold uppercase tracking-wider">Currently Editing</p>
                            <p class="text-lg font-bold text-gray-800">${vehicle.licensePlate}</p>
                        </div>
                    </div>

                    <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                        <div>
                            <label class="block text-sm font-semibold text-gray-700 mb-2">License Plate</label>
                            <input type="text" name="licensePlate" value="${vehicle.licensePlate}" 
                                   class="w-full rounded-xl border-gray-300 focus:ring-2 focus:ring-blue-500" required>
                        </div>

                        <div>
                            <label class="block text-sm font-semibold text-gray-700 mb-2">Vehicle Type</label>
                            <select name="type" class="w-full rounded-xl border-gray-300 focus:ring-2 focus:ring-blue-500">
                                <option value="Bus" ${vehicle.type == 'Bus' ? 'selected' : ''}>Bus</option>
                                <option value="Van" ${vehicle.type == 'Van' ? 'selected' : ''}>Van</option>
                                <option value="SUV" ${vehicle.type == 'SUV' ? 'selected' : ''}>SUV</option>
                                <option value="Sedan" ${vehicle.type == 'Sedan' ? 'selected' : ''}>Sedan</option>
                            </select>
                        </div>

                        <div>
                            <label class="block text-sm font-semibold text-gray-700 mb-2">Capacity</label>
                            <input type="number" name="capacity" value="${vehicle.capacity}" 
                                   class="w-full rounded-xl border-gray-300 focus:ring-2 focus:ring-blue-500" required>
                        </div>

                        <div>
                            <label class="block text-sm font-semibold text-gray-700 mb-2">Operational Status</label>
                            <select name="status" class="w-full rounded-xl border-gray-300 focus:ring-2 focus:ring-blue-500">
                                <option value="AVAILABLE" ${vehicle.status == 'AVAILABLE' ? 'selected' : ''}>Available</option>
                                <option value="MAINTENANCE" ${vehicle.status == 'MAINTENANCE' ? 'selected' : ''}>Maintenance</option>
                                <option value="UNAVAILABLE" ${vehicle.status == 'UNAVAILABLE' ? 'selected' : ''}>Unavailable</option>
                            </select>
                        </div>
                    </div>

                    <div class="flex justify-end gap-3 mt-8 pt-6 border-t border-gray-50">
                        <a href="${pageContext.request.contextPath}/VehicleController?action=list" 
                           class="px-6 py-2 rounded-lg font-bold text-gray-500 hover:bg-gray-100 transition-colors">
                            Cancel
                        </a>
                        <button type="submit" class="bg-blue-600 text-white px-8 py-2 rounded-lg font-bold shadow-lg shadow-blue-100 hover:bg-blue-700 transition-all">
                            Save Changes
                        </button>
                    </div>
                </form>
            </div>
        </main>
    </body>
</html>