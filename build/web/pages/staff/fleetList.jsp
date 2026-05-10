<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <title>Staff | Manage Fleet & Bookings</title>
        <script src="https://cdn.tailwindcss.com?plugins=forms"></script>
        <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined" rel="stylesheet"/>
    </head>
    <body class="bg-gray-50">
        <jsp:include page="/partials/sidebar.jsp"><jsp:param name="active" value="fleet" /></jsp:include>

            <main class="pl-64">
            <jsp:include page="/partials/navbar.jsp" />

            <div class="p-8 mt-16">
                <div class="flex justify-between items-center mb-6">
                    <div>
                        <h1 class="text-2xl font-bold text-gray-800">Booking Management</h1>
                        <p class="text-sm text-gray-500">Review and manage vehicle requests for Module 2</p>
                    </div>
                    <a href="addVehicle.jsp" class="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg transition-colors flex items-center gap-2">
                        <span class="material-symbols-outlined text-sm">add</span> Add Vehicle
                    </a>
                </div>

                <div class="flex gap-2 mb-6">
                    <a href="${pageContext.request.contextPath}/staff/manage-bookings" class="px-4 py-2 bg-white border rounded-lg text-sm font-medium hover:bg-gray-50 shadow-sm">All Requests</a>
                    <a href="#" class="px-4 py-2 bg-white border rounded-lg text-sm text-yellow-600 font-medium hover:bg-gray-50 shadow-sm">Pending</a>
                    <a href="#" class="px-4 py-2 bg-white border rounded-lg text-sm text-green-600 font-medium hover:bg-gray-50 shadow-sm">Approved</a>
                </div>

                <div class="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden">
                    <table class="w-full text-left border-collapse">
                        <thead class="bg-gray-50 text-gray-600 text-sm uppercase tracking-wider">
                            <tr>
                                <th class="p-4 font-semibold">Request Info</th>
                                <th class="p-4 font-semibold">User</th>
                                <th class="p-4 font-semibold">Trip Dates</th>
                                <th class="p-4 font-semibold">Vehicle Type</th>
                                <th class="p-4 font-semibold">Status</th>
                                <th class="p-4 font-semibold text-right">Decision</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-gray-100">
                            <c:forEach var="b" items="${bookings}">
                                <tr class="hover:bg-gray-50 transition-colors">
                                    <td class="p-4">
                                        <div class="font-bold text-blue-600">${b.requestCode != null ? b.requestCode : 'REQ-ID-'.concat(b.id)}</div>
                                        <div class="text-xs text-gray-400">${b.destination}</div>
                                    </td>
                                    <td class="p-4 text-sm text-gray-700">User ID: ${b.userId}</td>
                                    <td class="p-4 text-sm text-gray-700">
                                        <div class="flex flex-col">
                                            <span>${b.tripDate}</span>
                                            <span class="text-xs text-gray-400">to ${b.returnDate}</span>
                                        </div>
                                    </td>
                                    <td class="p-4 text-sm text-gray-600">${b.vehicleType}</td>
                                    <td class="p-4">
                                        <span class="px-2.5 py-1 rounded-full text-xs font-medium
                                              ${b.status == 'APPROVED' ? 'bg-green-100 text-green-700' : 
                                                b.status == 'REJECTED' ? 'bg-red-100 text-red-700' : 
                                                'bg-yellow-100 text-yellow-700'}">
                                                  ${b.status}
                                              </span>
                                        </td>
                                        <td class="p-4 text-right">
                                            <c:if test="${b.status == 'PENDING'}">
                                                <div class="flex justify-end gap-2">
                                                    <form action="${pageContext.request.contextPath}/staff/manage-bookings" method="POST">
                                                        <input type="hidden" name="bookingId" value="${b.id}">
                                                        <button name="action" value="APPROVE" class="text-green-600 hover:text-green-800 p-1 rounded hover:bg-green-50 transition-colors" title="Approve">
                                                            <span class="material-symbols-outlined">check_circle</span>
                                                        </button>
                                                        <button name="action" value="REJECT" class="text-red-600 hover:text-red-800 p-1 rounded hover:bg-red-50 transition-colors" title="Reject">
                                                            <span class="material-symbols-outlined">cancel</span>
                                                        </button>
                                                    </form>
                                                </div>
                                            </c:if>
                                            <c:if test="${b.status != 'PENDING'}">
                                                <span class="text-xs text-gray-400 italic font-light">Processed</span>
                                            </c:if>
                                        </td>
                                    </tr>
                                </c:forEach>

                                <c:if test="${empty bookings}">
                                    <tr>
                                        <td colspan="6" class="p-8 text-center text-gray-500 italic">
                                            No pending booking requests found.
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