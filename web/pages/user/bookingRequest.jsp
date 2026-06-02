<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List,com.project.model.BookingRequest" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%
    List<BookingRequest> bookingList = (List<BookingRequest>) request.getAttribute("bookings");
    int pendingCount = 0;
    int approvedCount = 0;
    int completedCount = 0;
    int rejectedCount = 0;
    int cancelledCount = 0;
    if (bookingList != null) {
        for (BookingRequest b : bookingList) {
            if (b.getStatus() == BookingRequest.Status.PENDING) pendingCount++;
            else if (b.getStatus() == BookingRequest.Status.APPROVED) approvedCount++;
            else if (b.getStatus() == BookingRequest.Status.COMPLETED) completedCount++;
            else if (b.getStatus() == BookingRequest.Status.REJECTED) rejectedCount++;
            else if (b.getStatus() == BookingRequest.Status.CANCELLED) cancelledCount++;
        }
    }
%>
<!DOCTYPE html>
<html class="light" lang="en">
<head>
    <meta charset="utf-8"/>
    <meta content="width=device-width, initial-scale=1.0" name="viewport"/>
    <title>Campus Vehicle Booking | Request Management</title>
    <script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
    <link href="https://fonts.googleapis.com/css2?family=Manrope:wght@500;700;800&family=Plus+Jakarta+Sans:wght@400;500;600;700&display=swap" rel="stylesheet"/>
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap" rel="stylesheet"/>
    <style>
        :root {
            --umt-navy: #042b61;
            --umt-blue: #1363c6;
            --umt-gold: #f7b718;
        }
        body { font-family: "Plus Jakarta Sans", sans-serif; }
        .headline { font-family: "Manrope", sans-serif; }
        .code-pill { font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, "Liberation Mono", "Courier New", monospace; }
    </style>
</head>
<body class="bg-slate-50 text-slate-900">
    <jsp:include page="/partials/sidebar.jsp"><jsp:param name="active" value="booking" /></jsp:include>

    <main class="pl-0 md:pl-64 min-h-screen">
        <jsp:include page="/partials/navbar.jsp" />

        <div class="pt-24 px-4 md:px-8 pb-10 space-y-6">
            <section class="flex flex-col gap-2">
                <h1 class="headline text-3xl font-extrabold tracking-tight">Booking Request Management</h1>
                <p class="text-slate-500">Create, track, edit, and cancel requests while status is still pending.</p>
            </section>

            <c:if test="${not empty sessionScope.message}">
                <div class="p-4 rounded-xl border flex items-center gap-3 ${sessionScope.messageType == 'success' ? 'bg-green-50 border-green-200 text-green-700' : 'bg-red-50 border-red-200 text-red-700'}">
                    <span class="material-symbols-outlined">${sessionScope.messageType == 'success' ? 'check_circle' : 'error'}</span>
                    <p class="font-medium">${sessionScope.message}</p>
                </div>
                <% session.removeAttribute("message"); session.removeAttribute("messageType"); %>
            </c:if>

            <section class="grid grid-cols-2 lg:grid-cols-5 gap-3 md:gap-4">
                <div class="rounded-2xl border border-amber-200 bg-amber-50 p-4">
                    <p class="text-xs font-bold uppercase text-amber-700">Pending</p>
                    <p class="text-2xl font-extrabold text-amber-800"><%= pendingCount %></p>
                </div>
                <div class="rounded-2xl border border-green-200 bg-green-50 p-4">
                    <p class="text-xs font-bold uppercase text-green-700">Approved</p>
                    <p class="text-2xl font-extrabold text-green-800"><%= approvedCount %></p>
                </div>
                <div class="rounded-2xl border border-emerald-200 bg-emerald-50 p-4">
                    <p class="text-xs font-bold uppercase text-emerald-700">Completed</p>
                    <p class="text-2xl font-extrabold text-emerald-800"><%= completedCount %></p>
                </div>
                <div class="rounded-2xl border border-red-200 bg-red-50 p-4">
                    <p class="text-xs font-bold uppercase text-red-700">Rejected</p>
                    <p class="text-2xl font-extrabold text-red-800"><%= rejectedCount %></p>
                </div>
                <div class="rounded-2xl border border-slate-200 bg-slate-100 p-4">
                    <p class="text-xs font-bold uppercase text-slate-600">Cancelled</p>
                    <p class="text-2xl font-extrabold text-slate-700"><%= cancelledCount %></p>
                </div>
            </section>

            <section class="grid grid-cols-1 xl:grid-cols-12 gap-6">
                <div class="xl:col-span-7 bg-white rounded-2xl border border-slate-200 shadow-sm p-5 md:p-6">
                    <div class="mb-4">
                        <h2 class="headline text-xl font-extrabold">Create Request</h2>
                        <p class="text-sm text-slate-500">Step 1: Trip details, Step 2: Vehicle preference, Step 3: Purpose</p>
                    </div>

                    <form id="bookingRequestForm" action="${pageContext.request.contextPath}/BookingController" method="POST" class="space-y-5">
                        <div>
                            <p class="text-xs font-bold uppercase tracking-wider text-slate-500 mb-3">Step 1 · Trip Details</p>
                            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                                <label class="block">
                                    <span class="text-sm font-semibold text-slate-700">Trip Date</span>
                                    <input type="date" name="tripDate" id="tripDate" required class="mt-1 w-full rounded-xl border-slate-300 focus:ring-[var(--umt-blue)]"/>
                                </label>
                                <label class="block">
                                    <span class="text-sm font-semibold text-slate-700">Return Date</span>
                                    <input type="date" name="returnDate" id="returnDate" required class="mt-1 w-full rounded-xl border-slate-300 focus:ring-[var(--umt-blue)]"/>
                                </label>
                                <label class="block md:col-span-2">
                                    <span class="text-sm font-semibold text-slate-700">Destination</span>
                                    <input type="text" name="destination" required placeholder="Example: Kuala Nerus District Office" class="mt-1 w-full rounded-xl border-slate-300 focus:ring-[var(--umt-blue)]"/>
                                </label>
                            </div>
                        </div>

                        <div>
                            <p class="text-xs font-bold uppercase tracking-wider text-slate-500 mb-3">Step 2 · Vehicle Preference</p>
                            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                                <label class="block">
                                    <span class="text-sm font-semibold text-slate-700">Passenger Count</span>
                                    <input type="number" name="passengerCount" min="1" required class="mt-1 w-full rounded-xl border-slate-300 focus:ring-[var(--umt-blue)]"/>
                                    <p class="text-xs text-slate-400 mt-1">Minimum 1 passenger.</p>
                                </label>
                                <label class="block">
                                    <span class="text-sm font-semibold text-slate-700">Vehicle Type</span>
                                    <select name="vehicleType" required class="mt-1 w-full rounded-xl border-slate-300 focus:ring-[var(--umt-blue)]">
                                        <option value="VAN">Van</option>
                                        <option value="MPV">MPV</option>
                                        <option value="BUS">Bus</option>
                                        <option value="FOUR_BY_FOUR">4x4 / SUV</option>
                                    </select>
                                </label>
                            </div>
                        </div>

                        <div>
                            <p class="text-xs font-bold uppercase tracking-wider text-slate-500 mb-3">Step 3 · Purpose</p>
                            <label class="block">
                                <span class="text-sm font-semibold text-slate-700">Purpose of Trip</span>
                                <textarea name="purpose" id="purpose" rows="4" maxlength="500" required class="mt-1 w-full rounded-xl border-slate-300 focus:ring-[var(--umt-blue)]"></textarea>
                                <div class="flex justify-between text-xs text-slate-400 mt-1">
                                    <span>Briefly explain official activity.</span>
                                    <span id="purposeCount">0 / 500</span>
                                </div>
                            </label>
                        </div>

                        <div class="flex flex-col-reverse sm:flex-row sm:justify-end gap-3 pt-2 sticky bottom-0 bg-white">
                            <button type="reset" class="px-6 py-2.5 rounded-xl border border-slate-300 text-slate-700 hover:bg-slate-50">Reset</button>
                            <button type="submit" class="px-6 py-2.5 rounded-xl text-white font-semibold" style="background: linear-gradient(120deg, var(--umt-navy), var(--umt-blue));">Submit Request</button>
                        </div>
                    </form>
                </div>

                <div class="xl:col-span-5 bg-white rounded-2xl border border-slate-200 shadow-sm p-5 md:p-6">
                    <h2 class="headline text-xl font-extrabold mb-4">My Request Timeline</h2>
                    <div class="space-y-3 max-h-[520px] overflow-y-auto pr-1">
                        <c:forEach var="b" items="${bookings}" varStatus="loop">
                            <c:if test="${loop.index < 6}">
                                <div class="rounded-xl border p-3 ${b.status == 'PENDING' ? 'border-amber-200 bg-amber-50' : b.status == 'APPROVED' ? 'border-green-200 bg-green-50' : b.status == 'COMPLETED' ? 'border-emerald-200 bg-emerald-50' : b.status == 'REJECTED' ? 'border-red-200 bg-red-50' : 'border-slate-200 bg-slate-50'}">
                                    <div class="flex items-center justify-between gap-3">
                                        <span class="code-pill text-xs font-bold px-2 py-1 rounded-lg bg-white/70 border border-slate-200">${b.requestCode != null ? b.requestCode : 'BK-'.concat(b.id)}</span>
                                        <span class="text-[11px] font-bold px-2 py-1 rounded-full ${b.status == 'PENDING' ? 'bg-amber-100 text-amber-800' : b.status == 'APPROVED' ? 'bg-green-100 text-green-800' : b.status == 'COMPLETED' ? 'bg-emerald-100 text-emerald-800' : b.status == 'REJECTED' ? 'bg-red-100 text-red-700' : 'bg-slate-200 text-slate-700'}">${b.status}</span>
                                    </div>
                                    <p class="text-sm font-semibold text-slate-800 mt-2">${b.destination}</p>
                                    <p class="text-xs text-slate-500 mt-1">${b.tripDate} to ${b.returnDate}</p>
                                </div>
                            </c:if>
                        </c:forEach>
                        <c:if test="${empty bookings}">
                            <div class="rounded-xl border border-dashed border-slate-300 bg-slate-50 p-6 text-center">
                                <p class="font-semibold text-slate-700">No bookings yet</p>
                                <p class="text-sm text-slate-500 mt-1">Create your first request using the form.</p>
                            </div>
                        </c:if>
                    </div>
                </div>
            </section>

            <section class="bg-white rounded-2xl border border-slate-200 shadow-sm p-5 md:p-6 space-y-4">
                <div class="flex flex-col lg:flex-row lg:items-center lg:justify-between gap-3">
                    <h2 class="headline text-xl font-extrabold">Booking History</h2>
                    <div class="flex flex-wrap gap-2" id="quickFilters">
                        <button type="button" class="qf px-3 py-1.5 rounded-full text-xs font-bold border border-slate-300 bg-slate-900 text-white" data-status="ALL">All</button>
                        <button type="button" class="qf px-3 py-1.5 rounded-full text-xs font-bold border border-amber-300 text-amber-700" data-status="PENDING">Pending</button>
                        <button type="button" class="qf px-3 py-1.5 rounded-full text-xs font-bold border border-red-300 text-red-700" data-status="ACTION">Action Needed</button>
                    </div>
                </div>

                <div class="grid grid-cols-1 md:grid-cols-4 gap-3">
                    <input id="searchInput" type="text" placeholder="Search code or destination" class="rounded-xl border-slate-300 md:col-span-2"/>
                    <select id="statusFilter" class="rounded-xl border-slate-300">
                        <option value="ALL">All Status</option>
                        <option value="PENDING">Pending</option>
                        <option value="APPROVED">Approved</option>
                        <option value="COMPLETED">Completed</option>
                        <option value="REJECTED">Rejected</option>
                        <option value="CANCELLED">Cancelled</option>
                    </select>
                    <div class="grid grid-cols-2 gap-2">
                        <input id="fromDate" type="date" class="rounded-xl border-slate-300"/>
                        <input id="toDate" type="date" class="rounded-xl border-slate-300"/>
                    </div>
                </div>

                <div class="hidden md:block overflow-x-auto border border-slate-200 rounded-xl">
                    <table class="w-full text-left">
                        <thead class="bg-slate-50 border-b border-slate-200">
                            <tr>
                                <th class="px-4 py-3 text-xs font-bold uppercase text-slate-500">Request</th>
                                <th class="px-4 py-3 text-xs font-bold uppercase text-slate-500">Date</th>
                                <th class="px-4 py-3 text-xs font-bold uppercase text-slate-500">Destination</th>
                                <th class="px-4 py-3 text-xs font-bold uppercase text-slate-500">Status</th>
                                <th class="px-4 py-3 text-xs font-bold uppercase text-slate-500 text-right">Actions</th>
                            </tr>
                        </thead>
                        <tbody id="historyRows" class="divide-y divide-slate-100">
                        <c:forEach var="b" items="${bookings}">
                            <tr class="history-row hover:bg-slate-50"
                                data-code="${b.requestCode != null ? b.requestCode : 'BK-'.concat(b.id)}"
                                data-destination="${b.destination}"
                                data-status="${b.status}"
                                data-trip="${b.tripDate}"
                                data-return="${b.returnDate}"
                                data-id="${b.id}">
                                <td class="px-4 py-3"><span class="code-pill text-xs font-bold px-2 py-1 rounded-lg bg-blue-50 text-blue-700 border border-blue-100">${b.requestCode != null ? b.requestCode : 'BK-'.concat(b.id)}</span></td>
                                <td class="px-4 py-3 text-sm text-slate-600">${b.tripDate}</td>
                                <td class="px-4 py-3 text-sm font-medium">${b.destination}</td>
                                <td class="px-4 py-3">
                                    <span class="px-2.5 py-1 rounded-full text-xs font-bold ${b.status == 'PENDING' ? 'bg-amber-100 text-amber-700' : b.status == 'APPROVED' ? 'bg-green-100 text-green-700' : b.status == 'COMPLETED' ? 'bg-emerald-100 text-emerald-700' : b.status == 'REJECTED' ? 'bg-red-100 text-red-700' : 'bg-slate-200 text-slate-700'}">${b.status}</span>
                                </td>
                                <td class="px-4 py-3 text-right space-x-2 whitespace-nowrap">
                                    <button type="button"
                                            class="quick-view inline-flex items-center rounded-lg border border-slate-300 bg-white px-3 py-1.5 text-xs font-bold text-slate-700 hover:bg-slate-50"
                                            data-code="${b.requestCode != null ? b.requestCode : 'BK-'.concat(b.id)}" data-destination="${b.destination}" data-trip="${b.tripDate}" data-return="${b.returnDate}" data-status="${b.status}">
                                        Quick View
                                    </button>
                                    <a href="${pageContext.request.contextPath}/BookingController?action=detail&id=${b.id}"
                                       class="inline-flex items-center rounded-lg bg-blue-600 px-3 py-1.5 text-xs font-bold text-white hover:bg-blue-700">
                                        ${b.status == 'PENDING' ? 'Edit' : 'View'}
                                    </a>
                                    <c:if test="${b.status == 'PENDING'}">
                                        <button type="button"
                                                class="cancel-btn inline-flex items-center rounded-lg bg-red-600 px-3 py-1.5 text-xs font-bold text-white hover:bg-red-700"
                                                data-id="${b.id}" data-code="${b.requestCode != null ? b.requestCode : 'BK-'.concat(b.id)}">
                                            Cancel
                                        </button>
                                    </c:if>
                                </td>
                            </tr>
                        </c:forEach>
                        </tbody>
                    </table>
                </div>

                <div id="historyCards" class="md:hidden space-y-3">
                    <c:forEach var="b" items="${bookings}">
                        <div class="history-card rounded-xl border border-slate-200 p-4"
                             data-code="${b.requestCode != null ? b.requestCode : 'BK-'.concat(b.id)}"
                             data-destination="${b.destination}"
                             data-status="${b.status}"
                             data-trip="${b.tripDate}">
                            <div class="flex justify-between items-center gap-2">
                                <span class="code-pill text-xs font-bold px-2 py-1 rounded-lg bg-blue-50 text-blue-700 border border-blue-100">${b.requestCode != null ? b.requestCode : 'BK-'.concat(b.id)}</span>
                                <span class="px-2.5 py-1 rounded-full text-xs font-bold ${b.status == 'PENDING' ? 'bg-amber-100 text-amber-700' : b.status == 'APPROVED' ? 'bg-green-100 text-green-700' : b.status == 'COMPLETED' ? 'bg-emerald-100 text-emerald-700' : b.status == 'REJECTED' ? 'bg-red-100 text-red-700' : 'bg-slate-200 text-slate-700'}">${b.status}</span>
                            </div>
                            <p class="font-semibold text-slate-800 mt-2">${b.destination}</p>
                            <p class="text-xs text-slate-500">${b.tripDate} to ${b.returnDate}</p>
                            <div class="mt-3 flex gap-2">
                                <a href="${pageContext.request.contextPath}/BookingController?action=detail&id=${b.id}" class="text-blue-600 text-sm font-semibold">${b.status == 'PENDING' ? 'Edit' : 'View'}</a>
                                <c:if test="${b.status == 'PENDING'}">
                                    <button type="button" class="cancel-btn text-red-600 text-sm font-semibold" data-id="${b.id}" data-code="${b.requestCode != null ? b.requestCode : 'BK-'.concat(b.id)}">Cancel</button>
                                </c:if>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </section>
        </div>
    </main>

    <div id="cancelModal" class="hidden fixed inset-0 bg-black/50 z-[999] items-center justify-center p-4">
        <div class="bg-white rounded-2xl w-full max-w-md p-6">
            <h3 class="headline text-xl font-extrabold text-slate-900">Cancel Booking</h3>
            <p class="text-sm text-slate-500 mt-2">Are you sure you want to cancel <span id="cancelCode" class="font-bold text-slate-800"></span>?</p>
            <form id="cancelForm" action="${pageContext.request.contextPath}/BookingController" method="POST" class="mt-5 flex justify-end gap-2">
                <input type="hidden" name="action" value="cancel"/>
                <input type="hidden" name="id" id="cancelId"/>
                <button type="button" id="cancelClose" class="px-4 py-2 rounded-lg border border-slate-300">Back</button>
                <button type="submit" class="px-4 py-2 rounded-lg bg-red-600 text-white font-semibold">Confirm Cancel</button>
            </form>
        </div>
    </div>

    <div id="quickDrawer" class="hidden fixed top-0 right-0 h-full w-full sm:w-[380px] bg-white shadow-2xl z-[998] border-l border-slate-200">
        <div class="p-5 border-b border-slate-200 flex justify-between items-center">
            <h3 class="headline text-lg font-extrabold">Request Detail</h3>
            <button id="drawerClose" type="button" class="text-slate-500">✕</button>
        </div>
        <div class="p-5 space-y-3 text-sm">
            <div><p class="text-slate-500">Request Code</p><p id="dCode" class="font-bold"></p></div>
            <div><p class="text-slate-500">Destination</p><p id="dDestination" class="font-bold"></p></div>
            <div><p class="text-slate-500">Trip Date</p><p id="dTrip" class="font-bold"></p></div>
            <div><p class="text-slate-500">Return Date</p><p id="dReturn" class="font-bold"></p></div>
            <div><p class="text-slate-500">Status</p><p id="dStatus" class="font-bold"></p></div>
        </div>
    </div>

    <script>
        const tripDateInput = document.getElementById('tripDate');
        const returnDateInput = document.getElementById('returnDate');
        const today = new Date().toISOString().split('T')[0];
        tripDateInput.setAttribute('min', today);
        tripDateInput.addEventListener('change', () => {
            returnDateInput.setAttribute('min', tripDateInput.value);
        });

        const purpose = document.getElementById('purpose');
        const purposeCount = document.getElementById('purposeCount');
        purpose.addEventListener('input', () => {
            purposeCount.textContent = `${purpose.value.length} / 500`;
        });

        const rows = Array.from(document.querySelectorAll('.history-row'));
        const cards = Array.from(document.querySelectorAll('.history-card'));
        const statusFilter = document.getElementById('statusFilter');
        const searchInput = document.getElementById('searchInput');
        const fromDate = document.getElementById('fromDate');
        const toDate = document.getElementById('toDate');
        const quickButtons = Array.from(document.querySelectorAll('.qf'));

        function statusMatches(target, value) {
            if (value === 'ALL') return true;
            if (value === 'ACTION') return target === 'PENDING' || target === 'REJECTED';
            return target === value;
        }

        function applyFilters(quick = null) {
            const query = searchInput.value.trim().toLowerCase();
            const status = quick || statusFilter.value;
            const from = fromDate.value;
            const to = toDate.value;

            rows.forEach((row) => {
                const code = (row.dataset.code || '').toLowerCase();
                const destination = (row.dataset.destination || '').toLowerCase();
                const s = row.dataset.status || '';
                const trip = row.dataset.trip || '';

                const queryOK = !query || code.includes(query) || destination.includes(query);
                const statusOK = statusMatches(s, status);
                const fromOK = !from || trip >= from;
                const toOK = !to || trip <= to;
                row.style.display = queryOK && statusOK && fromOK && toOK ? '' : 'none';
            });

            cards.forEach((card) => {
                const code = (card.dataset.code || '').toLowerCase();
                const destination = (card.dataset.destination || '').toLowerCase();
                const s = card.dataset.status || '';
                const trip = card.dataset.trip || '';

                const queryOK = !query || code.includes(query) || destination.includes(query);
                const statusOK = statusMatches(s, status);
                const fromOK = !from || trip >= from;
                const toOK = !to || trip <= to;
                card.style.display = queryOK && statusOK && fromOK && toOK ? '' : 'none';
            });
        }

        [statusFilter, searchInput, fromDate, toDate].forEach((el) => el.addEventListener('input', () => applyFilters()));
        quickButtons.forEach((btn) => {
            btn.addEventListener('click', () => {
                quickButtons.forEach((b) => {
                    b.classList.remove('bg-slate-900', 'text-white');
                    b.classList.add('text-slate-700');
                });
                btn.classList.add('bg-slate-900', 'text-white');
                applyFilters(btn.dataset.status);
            });
        });

        const cancelModal = document.getElementById('cancelModal');
        const cancelClose = document.getElementById('cancelClose');
        const cancelCode = document.getElementById('cancelCode');
        const cancelId = document.getElementById('cancelId');
        document.querySelectorAll('.cancel-btn').forEach((btn) => {
            btn.addEventListener('click', () => {
                cancelCode.textContent = btn.dataset.code;
                cancelId.value = btn.dataset.id;
                cancelModal.classList.remove('hidden');
                cancelModal.classList.add('flex');
            });
        });
        cancelClose.addEventListener('click', () => {
            cancelModal.classList.add('hidden');
            cancelModal.classList.remove('flex');
        });

        const drawer = document.getElementById('quickDrawer');
        const drawerClose = document.getElementById('drawerClose');
        document.querySelectorAll('.quick-view').forEach((btn) => {
            btn.addEventListener('click', () => {
                document.getElementById('dCode').textContent = btn.dataset.code;
                document.getElementById('dDestination').textContent = btn.dataset.destination;
                document.getElementById('dTrip').textContent = btn.dataset.trip;
                document.getElementById('dReturn').textContent = btn.dataset.return;
                document.getElementById('dStatus').textContent = btn.dataset.status;
                drawer.classList.remove('hidden');
            });
        });
        drawerClose.addEventListener('click', () => drawer.classList.add('hidden'));
    </script>
</body>
</html>
