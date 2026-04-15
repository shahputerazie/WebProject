<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="utf-8"/>
        <title>Staff | Edit Vehicle</title>
        <script src="https://cdn.tailwindcss.com?plugins=forms"></script>
        <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined" rel="stylesheet"/>
    </head>
    <body class="bg-gray-50">
        <jsp:include page="/partials/sidebar.jsp"><jsp:param name="active" value="fleet" /></jsp:include>
            <main class="pl-64">
            <jsp:include page="/partials/navbar.jsp" />
            <div class="p-8 mt-16 max-w-3xl">
                <h1 class="text-2xl font-bold text-gray-800 mb-6">Update Vehicle Info</h1>
                <form action="${pageContext.request.contextPath}/VehicleController" method="POST" class="bg-white p-8 rounded-xl shadow-sm border border-gray-100">
                    <input type="hidden" name="action" value="update">
                    <input type="hidden" name="id" value="${param.id}">

                    <div class="mb-6 p-4 bg-blue-50 rounded-lg border border-blue-100">
                        <p class="text-xs text-blue-600 font-bold uppercase mb-1">Currently Editing</p>
                        <p class="text-lg font-bold text-gray-800">${param.plate != null ? param.plate : 'Select Vehicle'}</p>
                    </div>

                    <div class="space-y-4">
                        <label class="block">
                            <span class="text-sm font-medium text-gray-700">Operational Status</span>
                            <select name="status" class="mt-1 w-full rounded-lg border-gray-300 text-gray-700">
                                <option value="AVAILABLE">Available</option>
                                <option value="MAINTENANCE">Maintenance</option>
                                <option value="UNAVAILABLE">Unavailable</option>
                            </select>
                        </label>
                    </div>

                    <div class="flex justify-end gap-3 mt-8">
                        <button type="submit" class="bg-blue-600 text-white px-8 py-2 rounded-lg font-bold shadow-lg hover:bg-blue-700">Update Status</button>
                    </div>
                </form>
            </div>
        </main>
    </body>
</html>