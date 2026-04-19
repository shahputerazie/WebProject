<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <title>Staff | Manage Fleet</title>
        <script src="https://cdn.tailwindcss.com?plugins=forms"></script>
        <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined" rel="stylesheet"/>
    </head>
    <body class="bg-gray-50">
        <jsp:include page="/partials/sidebar.jsp"><jsp:param name="active" value="fleet" /></jsp:include>
            <main class="pl-64">
            <jsp:include page="/partials/navbar.jsp" />
            <div class="p-8 mt-16">
                <div class="flex justify-between items-center mb-6">
                    <h1 class="text-2xl font-bold">Vehicle Inventory</h1>
                    <a href="addVehicle.jsp" class="bg-blue-600 text-white px-4 py-2 rounded-lg">+ Add Vehicle</a>
                </div>

                <div class="flex gap-2 mb-6">
                    <a href="${pageContext.request.contextPath}/VehicleController?action=list" class="px-4 py-2 bg-white border rounded-lg text-sm">All</a>
                    <a href="${pageContext.request.contextPath}/VehicleController?action=list&status=AVAILABLE" class="px-4 py-2 bg-white border rounded-lg text-sm text-green-600">Available</a>
                    <a href="${pageContext.request.contextPath}/VehicleController?action=list&status=MAINTENANCE" class="px-4 py-2 bg-white border rounded-lg text-sm text-orange-600">Maintenance</a>
                </div>

                <div class="bg-white rounded-xl shadow border overflow-hidden">
                    <table class="w-full text-left">
                        <thead class="bg-gray-50 text-sm">
                            <tr><th class="p-4">Plate</th><th class="p-4">Type</th><th class="p-4">Capacity</th><th class="p-4">Status</th><th class="p-4 text-right">Actions</th></tr>
                        </thead>
                        <tbody>
                            <c:forEach var="v" items="${vehicleList}">
                                <tr class="border-t">
                                    <td class="p-4 font-bold text-blue-600">${v.licensePlate}</td>
                                    <td class="p-4">${v.type}</td>
                                    <td class="p-4">${v.capacity}</td>
                                    <td class="p-4">${v.status}</td>
                                    <td class="p-4 text-right">
                                        <a href="${pageContext.request.contextPath}/VehicleController?action=edit&id=${v.id}" class="material-symbols-outlined text-gray-400">edit</a>
                                        <a href="${pageContext.request.contextPath}/VehicleController?action=delete&id=${v.id}" class="material-symbols-outlined text-gray-400" onclick="return confirm('Delete?')">delete</a>
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