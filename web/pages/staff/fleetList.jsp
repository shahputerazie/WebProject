<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>Staff | Manage Fleet</title>

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

                <!-- HEADER -->
                <div class="flex justify-between items-center mb-6">

                    <div>
                        <h1 class="text-2xl font-bold text-gray-800">Vehicle Inventory</h1>
                        <p class="text-gray-500">Manage campus fleet units</p>
                    </div>

                    <!-- ADD BUTTON (FIXED) -->
                    <a href="addVehicle.jsp"
                       class="bg-blue-600 text-white px-4 py-2 rounded-lg flex items-center gap-2 hover:bg-blue-700">
                        <span class="material-symbols-outlined text-sm">add</span>
                        Add Vehicle
                    </a>

                </div>

                <!-- SUCCESS -->
                <c:if test="${param.success == 'true'}">
                    <div class="bg-green-100 text-green-700 p-3 rounded mb-4">
                        Vehicle added successfully!
                    </div>
                </c:if>

                <!-- TABLE -->
                <div class="bg-white rounded-xl shadow border overflow-hidden">

                    <table class="w-full text-left">

                        <thead class="bg-gray-50 text-sm text-gray-600 uppercase">
                            <tr>
                                <th class="p-4">Plate</th>
                                <th class="p-4">Type</th>
                                <th class="p-4">Capacity</th>
                                <th class="p-4">Status</th>
                                <th class="p-4 text-right">Actions</th>
                            </tr>
                        </thead>

                        <tbody>

                            <c:forEach var="vehicle" items="${vehicleList}">

                                <tr class="border-t hover:bg-gray-50">

                                    <td class="p-4 font-semibold text-blue-600">
                                        ${vehicle.licensePlate}
                                    </td>

                                    <td class="p-4">
                                        ${vehicle.type}
                                    </td>

                                    <td class="p-4">
                                        ${vehicle.capacity}
                                    </td>

                                    <td class="p-4">
                                        ${vehicle.status}
                                    </td>

                                    <!-- ACTION BUTTONS -->
                                    <td class="p-4 text-right flex justify-end gap-3">

                                        <!-- EDIT -->
                                        <a href="editVehicle.jsp?id=${vehicle.id}"
                                           class="material-symbols-outlined text-gray-500 hover:text-blue-600">
                                            edit_square
                                        </a>

                                        <!-- DELETE (UI only for now) -->
                                        <button onclick="return confirm('Delete this vehicle?')"
                                                class="material-symbols-outlined text-gray-500 hover:text-red-500">
                                            delete
                                        </button>

                                    </td>

                                </tr>

                            </c:forEach>

                            <!-- EMPTY -->
                            <c:if test="${empty vehicleList}">
                                <tr>
                                    <td colspan="5" class="p-10 text-center text-gray-400">
                                        No vehicles found.
                                        <br><br>
                                        <a href="addVehicle.jsp" class="text-blue-600 font-semibold">
                                            Add your first vehicle
                                        </a>
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