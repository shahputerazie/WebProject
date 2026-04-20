<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!DOCTYPE html>
<html class="light" lang="en">
    <head>
        <meta charset="utf-8"/>
        <meta content="width=device-width, initial-scale=1.0" name="viewport"/>
        <title>Campus Vehicle Booking | Request Management</title>
        <script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
        <link href="https://fonts.googleapis.com/css2?family=Manrope:wght@400;600;700;800&family=Inter:wght@400;500;600&display=swap" rel="stylesheet"/>
        <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap" rel="stylesheet"/>
    </head>
    <body class="bg-slate-50 text-slate-900 font-body">
        <jsp:include page="/partials/sidebar.jsp"><jsp:param name="active" value="booking" /></jsp:include>

            <main class="pl-64 min-h-screen">
            <jsp:include page="/partials/navbar.jsp" />

            <div class="pt-24 px-8 pb-12 space-y-8">
                <c:if test="${not empty sessionScope.message}">
                    <div class="p-4 rounded-xl border flex items-center gap-3 ${sessionScope.messageType == 'success' ? 'bg-green-50 border-green-200 text-green-700' : 'bg-red-50 border-red-200 text-red-700'}">
                        <span class="material-symbols-outlined">
                            ${sessionScope.messageType == 'success' ? 'check_circle' : 'error'}
                        </span>
                        <p class="font-medium">${sessionScope.message}</p>
                    </div>
                    <% session.removeAttribute("message");
                        session.removeAttribute("messageType");%>
                </c:if>

                <section>
                    <h1 class="font-bold text-3xl tracking-tight">Booking Request Management</h1>
                    <p class="text-slate-500 mt-1">Submit and track your vehicle requests for Module 2.</p>
                </section>

                <section class="grid grid-cols-1 md:grid-cols-4 gap-4">
                    <div class="bg-white p-6 rounded-xl border border-slate-200 shadow-sm">
                        <p class="text-xs uppercase tracking-widest text-slate-500 mb-2">Total Requests</p>
                        <p class="text-3xl font-bold text-blue-600">${fn:length(bookings)}</p>
                    </div>
                </section>

                <section class="grid grid-cols-1 gap-8">
                    <div class="bg-white rounded-2xl p-6 border border-slate-200 shadow-sm">
                        <h2 class="font-bold text-xl mb-5">Submit Booking Request</h2>

                        <form id="bookingRequestForm" action="${pageContext.request.contextPath}/BookingController" method="POST" class="grid grid-cols-1 md:grid-cols-2 gap-4">
                            <label class="block">
                                <span class="text-sm font-medium text-slate-700">Trip Date</span>
                                <input type="date" name="tripDate" id="tripDate" required class="mt-1 w-full rounded-lg border-slate-200 focus:ring-blue-500"/>
                            </label>
                            <label class="block">
                                <span class="text-sm font-medium text-slate-700">Return Date</span>
                                <input type="date" name="returnDate" id="returnDate" required class="mt-1 w-full rounded-lg border-slate-200 focus:ring-blue-500"/>
                            </label>
                            <label class="block md:col-span-2">
                                <span class="text-sm font-medium text-slate-700">Destination</span>
                                <input type="text" name="destination" required placeholder="City Hall, etc." class="mt-1 w-full rounded-lg border-slate-200 focus:ring-blue-500"/>
                            </label>
                            <label class="block">
                                <span class="text-sm font-medium text-slate-700">Passenger Count</span>
                                <input type="number" name="passengerCount" min="1" required class="mt-1 w-full rounded-lg border-slate-200 focus:ring-blue-500"/>
                            </label>
                            <label class="block">
                                <span class="text-sm font-medium text-slate-700">Vehicle Type</span>
                                <select name="vehicleType" required class="mt-1 w-full rounded-lg border-slate-200 focus:ring-blue-500">
                                    <option value="VAN">Van</option>
                                    <option value="MPV">MPV</option>
                                    <option value="BUS">Bus</option>
                                    <option value="FOUR_BY_FOUR">4x4 / SUV</option>
                                </select>
                            </label>
                            <label class="block md:col-span-2">
                                <span class="text-sm font-medium text-slate-700">Purpose of Trip</span>
                                <textarea name="purpose" rows="3" required class="mt-1 w-full rounded-lg border-slate-200 focus:ring-blue-500"></textarea>
                            </label>
                            <div class="md:col-span-2 flex justify-end gap-3 pt-4">
                                <button type="reset" class="px-6 py-2 rounded-lg border text-slate-600 hover:bg-slate-50 transition-all">Reset</button>
                                <button type="submit" class="px-6 py-2 rounded-lg bg-blue-600 text-white font-semibold hover:bg-blue-700 shadow-md transition-all">Submit Request</button>
                            </div>
                        </form>
                    </div>
                </section>

                <section class="bg-white rounded-2xl border border-slate-200 shadow-sm overflow-hidden">
                    <table class="w-full text-left">
                        <thead class="bg-slate-50 border-b border-slate-200">
                            <tr>
                                <th class="px-6 py-4 text-xs font-semibold uppercase text-slate-500">ID</th>
                                <th class="px-6 py-4 text-xs font-semibold uppercase text-slate-500">Date</th>
                                <th class="px-6 py-4 text-xs font-semibold uppercase text-slate-500">Destination</th>
                                <th class="px-6 py-4 text-xs font-semibold uppercase text-slate-500">Status</th>
                                <th class="px-6 py-4 text-xs font-semibold uppercase text-slate-500 text-right">Action</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-slate-100">
                        <c:forEach var="b" items="${bookings}">
                            <tr class="hover:bg-slate-50 transition-colors">
                                <td class="px-6 py-4 font-bold text-blue-600">${b.requestCode != null ? b.requestCode : 'BK-'.concat(b.id)}</td>
                                <td class="px-6 py-4 text-sm">${b.tripDate}</td>
                                <td class="px-6 py-4 text-sm">${b.destination}</td>
                                <td class="px-6 py-4">
                                    <span class="px-3 py-1 rounded-full text-xs font-bold 
                                          ${b.status == 'PENDING' ? 'bg-amber-100 text-amber-700' : 
                                            b.status == 'APPROVED' ? 'bg-green-100 text-green-700' : 'bg-red-100 text-red-700'}">
                                              ${b.status}
                                          </span>
                                    </td>
                                    <td class="px-6 py-4 text-right">
                                        <a href="${pageContext.request.contextPath}/BookingController?action=detail&id=${b.id}" 
                                           class="text-blue-600 hover:underline font-semibold text-sm">
                                            ${b.status == 'PENDING' ? 'Modify' : 'View'}
                                        </a>
                                    </td>
                                </tr>
                            </c:forEach>
                            </tbody>
                        </table>
                    </section>
                </div>
            </main>

            <script>
                // PREVENT TRIP DATE IN THE PAST
                const tripDateInput = document.getElementById('tripDate');
                const returnDateInput = document.getElementById('returnDate');
                const today = new Date().toISOString().split('T');
                tripDateInput.setAttribute('min', today);

                tripDateInput.addEventListener('change', () => {
                    returnDateInput.setAttribute('min', tripDateInput.value);
                });
            </script>
        </body>
    </html>