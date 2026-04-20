<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>Staff | Add Vehicle</title>

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

            <div class="p-8 mt-16 max-w-4xl">

                <div class="mb-8">
                    <h1 class="text-2xl font-bold text-gray-800">Register New Fleet Unit</h1>
                    <p class="text-gray-500 text-sm">
                        Fill in the details below to add a vehicle to the campus inventory.
                    </p>
                </div>

                <c:if test="${not empty param.error}">
                    <div class="bg-red-50 border-l-4 border-red-500 text-red-700 p-4 rounded-lg mb-6 flex items-center gap-3">
                        <span class="material-symbols-outlined">error</span>
                        <p class="text-sm font-medium">Failed to add vehicle. Please check your inputs and try again.</p>
                    </div>
                </c:if>

                <form action="${pageContext.request.contextPath}/VehicleController" method="POST"
                      class="bg-white p-8 rounded-2xl shadow-sm border space-y-6">

                    <input type="hidden" name="action" value="create">

                    <div class="grid grid-cols-1 md:grid-cols-2 gap-6">

                        <div>
                            <label class="block text-sm font-semibold text-gray-700 mb-2">License Plate</label>
                            <input type="text" name="licensePlate"
                                   class="w-full rounded-xl border-gray-300 focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                                   placeholder="e.g. VAA 1234"
                                   required>
                        </div>

                        <div>
                            <label class="block text-sm font-semibold text-gray-700 mb-2">Vehicle Type</label>
                            <select name="type"
                                    class="w-full rounded-xl border-gray-300 focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                                    required>
                                <option value="Bus">Bus</option>
                                <option value="Van">Van</option>
                                <option value="SUV">SUV</option>
                                <option value="Sedan">Sedan</option>
                            </select>
                        </div>

                        <div>
                            <label class="block text-sm font-semibold text-gray-700 mb-2">Seating Capacity</label>
                            <input type="number" name="capacity" min="1"
                                   class="w-full rounded-xl border-gray-300 focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                                   placeholder="e.g. 40"
                                   required>
                        </div>

                        <div>
                            <label class="block text-sm font-semibold text-gray-700 mb-2">Current Status</label>
                            <select name="status"
                                    class="w-full rounded-xl border-gray-300 focus:ring-2 focus:ring-blue-500 focus:border-blue-500">
                                <option value="AVAILABLE">AVAILABLE</option>
                                <option value="MAINTENANCE">MAINTENANCE</option>
                                <option value="UNAVAILABLE">UNAVAILABLE</option>
                            </select>
                        </div>

                    </div>

                    <div class="flex justify-end gap-4 pt-6 border-t border-gray-100">

                        <a href="${pageContext.request.contextPath}/VehicleController?action=list"
                           class="px-6 py-2.5 rounded-xl bg-gray-100 text-gray-600 font-semibold hover:bg-gray-200 transition-colors">
                            Cancel
                        </a>

                        <button type="submit"
                                class="bg-blue-600 text-white px-8 py-2.5 rounded-xl font-semibold hover:bg-blue-700 flex items-center gap-2 shadow-lg shadow-blue-200 transition-all">
                            <span class="material-symbols-outlined text-lg">save</span>
                            Save Vehicle
                        </button>

                    </div>

                </form>

            </div>
        </main>

    </body>
</html>