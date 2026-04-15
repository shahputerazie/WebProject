<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html class="light" lang="en">
    <head>
        <meta charset="utf-8"/>
        <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
        <title>Staff | Manage Fleet</title>
        <script src="https://cdn.tailwindcss.com?plugins=forms"></script>
        <link href="https://fonts.googleapis.com/css2?family=Manrope:wght@400;600;700;800&display=swap" rel="stylesheet"/>
        <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined" rel="stylesheet"/>
    </head>
    <body class="bg-gray-50 font-sans">
        <jsp:include page="/partials/sidebar.jsp"><jsp:param name="active" value="fleet" /></jsp:include>
            <main class="pl-64 min-h-screen">
            <jsp:include page="/partials/navbar.jsp" />
            <div class="p-8 mt-16">
                <div class="flex justify-between items-center mb-6">
                    <div>
                        <h1 class="text-2xl font-bold text-gray-800">Vehicle Inventory</h1>
                        <p class="text-gray-500">Manage campus fleet units and availability.</p>
                    </div>
                    <a href="addVehicle.jsp" class="bg-blue-600 text-white px-4 py-2 rounded-lg flex items-center gap-2 hover:bg-blue-700 transition">
                        <span class="material-symbols-outlined text-sm">add</span> Add Vehicle
                    </a>
                </div>

                <div class="bg-white rounded-xl shadow-sm border border-gray-100 overflow-hidden">
                    <table class="w-full text-left border-collapse">
                        <thead class="bg-gray-50 text-gray-600 text-sm uppercase">
                            <tr>
                                <th class="p-4 border-b">Plate Number</th>
                                <th class="p-4 border-b">Type</th>
                                <th class="p-4 border-b">Capacity</th>
                                <th class="p-4 border-b">Status</th>
                                <th class="p-4 border-b text-right">Actions</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-gray-100">
                            <c:forEach var="vehicle" items="${vehicleList}">
                                <tr class="hover:bg-gray-50">
                                    <td class="p-4 font-semibold text-blue-600">${vehicle.licensePlate}</td>
                                    <td class="p-4 text-sm text-gray-700">${vehicle.type}</td>
                                    <td class="p-4 text-sm text-gray-700">${vehicle.capacity} Pax</td>
                                    <td class="p-4">
                                        <span class="px-3 py-1 rounded-full text-[11px] font-bold 
                                              ${vehicle.status == 'AVAILABLE' ? 'bg-green-100 text-green-700' : 'bg-orange-100 text-orange-700'}">
                                            ${vehicle.status}
                                        </span>
                                    </td>
                                    <td class="p-4 text-right flex justify-end gap-3 text-gray-400">
                                        <a href="editVehicle.jsp?id=${vehicle.id}" class="material-symbols-outlined hover:text-blue-600">edit_square</a>
                                        <button class="material-symbols-outlined hover:text-red-500">delete</button>
                                    </td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty vehicleList}">
                                <tr>
                                    <td colspan="5" class="p-12 text-center text-gray-400">
                                        <span class="material-symbols-outlined text-4xl block mb-2">directions_car</span>
                                        No vehicles found. Start by adding one.
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