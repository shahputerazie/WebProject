<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="utf-8"/>
        <title>Staff | Add Vehicle</title>
        <script src="https://cdn.tailwindcss.com?plugins=forms"></script>
        <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined" rel="stylesheet"/>
    </head>
    <body class="bg-gray-50">
        <jsp:include page="/partials/sidebar.jsp"><jsp:param name="active" value="fleet" /></jsp:include>
            <main class="pl-64">
            <jsp:include page="/partials/navbar.jsp" />
            <div class="p-8 mt-16 max-w-3xl">
                <h1 class="text-2xl font-bold text-gray-800 mb-6">Register New Fleet Unit</h1>
                <form action="${pageContext.request.contextPath}/VehicleController" method="POST" class="bg-white p-8 rounded-xl shadow-sm border border-gray-100 space-y-5">
                    <input type="hidden" name="action" value="create">

                    <div class="grid grid-cols-2 gap-6">
                        <div class="col-span-1">
                            <label class="block text-sm font-medium text-gray-700 mb-1">License Plate</label>
                            <input type="text" name="licensePlate" placeholder="e.g. VAA 1234" required 
                                   class="w-full rounded-lg border-gray-300 focus:ring-blue-500">
                        </div>
                        <div class="col-span-1">
                            <label class="block text-sm font-medium text-gray-700 mb-1">Vehicle Type</label>
                            <select name="type" class="w-full rounded-lg border-gray-300">
                                <option value="Bus">Bus</option>
                                <option value="Van">Van</option>
                                <option value="SUV">SUV</option>
                            </select>
                        </div>
                        <div class="col-span-1">
                            <label class="block text-sm font-medium text-gray-700 mb-1">Max Capacity</label>
                            <input type="number" name="capacity" min="1" required 
                                   class="w-full rounded-lg border-gray-300">
                        </div>
                    </div>

                    <div class="flex justify-end gap-3 pt-4">
                        <a href="fleetList.jsp" class="px-5 py-2 text-gray-500 hover:text-gray-700 font-medium">Cancel</a>
                        <button type="submit" class="bg-blue-600 text-white px-6 py-2 rounded-lg font-bold hover:bg-blue-700 shadow-md">Save Vehicle</button>
                    </div>
                </form>
            </div>
        </main>
    </body>
</html>