<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

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

                <!-- Header -->
                <div class="mb-8">
                    <h1 class="text-2xl font-bold text-gray-800">Register New Fleet Unit</h1>
                    <p class="text-gray-500 text-sm">
                        Fill in the details below to add a vehicle.
                    </p>
                </div>

                <!-- Error -->
                <c:if test="${param.error != null}">
                    <div class="bg-red-100 text-red-700 p-4 rounded-lg mb-4">
                        Failed to add vehicle. Please try again.
                    </div>
                </c:if>

                <!-- FORM -->
                <form action="VehicleController" method="POST"
                      class="bg-white p-8 rounded-2xl shadow-sm border space-y-6">

                    <!-- IMPORTANT -->
                    <input type="hidden" name="action" value="create">

                    <div class="grid grid-cols-2 gap-6">

                        <div>
                            <label class="block text-sm font-semibold mb-2">License Plate</label>
                            <input type="text" name="licensePlate"
                                   class="w-full rounded-xl border-gray-300 focus:ring-2 focus:ring-blue-500"
                                   placeholder="e.g. VAA 1234"
                                   required>
                        </div>

                        <div>
                            <label class="block text-sm font-semibold mb-2">Type</label>
                            <select name="type"
                                    class="w-full rounded-xl border-gray-300 focus:ring-2 focus:ring-blue-500"
                                    required>
                                <option value="Bus">Bus</option>
                                <option value="Van">Van</option>
                                <option value="SUV">SUV</option>
                                <option value="Sedan">Sedan</option>
                            </select>
                        </div>

                        <div>
                            <label class="block text-sm font-semibold mb-2">Capacity</label>
                            <input type="number" name="capacity"
                                   class="w-full rounded-xl border-gray-300 focus:ring-2 focus:ring-blue-500"
                                   required>
                        </div>

                        <div>
                            <label class="block text-sm font-semibold mb-2">Status</label>
                            <select name="status"
                                    class="w-full rounded-xl border-gray-300 focus:ring-2 focus:ring-blue-500">
                                <option value="AVAILABLE">AVAILABLE</option>
                                <option value="MAINTENANCE">MAINTENANCE</option>
                                <option value="UNAVAILABLE">UNAVAILABLE</option>
                            </select>
                        </div>

                    </div>

                    <!-- BUTTONS (FIXED) -->
                    <div class="flex justify-end gap-4 pt-6 border-t">

                        <!-- CANCEL (WORKING FIX) -->
                        <a href="VehicleController?action=list"
                           class="px-5 py-2 rounded-xl bg-gray-200 text-gray-700 hover:bg-gray-300">
                            Cancel
                        </a>

                        <!-- SUBMIT BUTTON (WORKING) -->
                        <button type="submit"
                                class="bg-blue-600 text-white px-6 py-2 rounded-xl hover:bg-blue-700 flex items-center gap-2">
                            <span class="material-symbols-outlined text-sm">save</span>
                            Save Vehicle
                        </button>

                    </div>

                </form>

            </div>
        </main>

    </body>
</html>