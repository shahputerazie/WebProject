<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="com.project.model.BookingRequest,com.project.dao.BookingDAO,java.time.format.DateTimeFormatter" %>
<%@ page import="java.math.BigDecimal" %>
<%!
    private String esc(String value) {
        if (value == null) {
            return "";
        }
        return value.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#x27;");
    }

    private String money(BigDecimal value) {
        if (value == null) {
            return "0.00";
        }
        return value.setScale(2, java.math.RoundingMode.HALF_UP).toPlainString();
    }

    private String formatDate(java.time.LocalDate value) {
        if (value == null) {
            return "-";
        }
        return value.format(DateTimeFormatter.ofPattern("dd/MM/yyyy"));
    }

    private boolean blank(String value) {
        return value == null || value.trim().isEmpty();
    }
%>
<%
    Object rawUserId = session == null ? null : session.getAttribute("userId");
    Long currentUserId = null;
    if (rawUserId instanceof Number) {
        long parsed = ((Number) rawUserId).longValue();
        currentUserId = parsed > 0 ? parsed : null;
    } else if (rawUserId != null) {
        try {
            long parsed = Long.parseLong(rawUserId.toString().trim());
            currentUserId = parsed > 0 ? parsed : null;
        } catch (NumberFormatException ignored) {
            currentUserId = null;
        }
    }

    Object roleObj = session == null ? null : session.getAttribute("role");
    String role = (roleObj instanceof String) ? ((String) roleObj).trim().toUpperCase() : "";
    if (!"STUDENT".equals(role) && !"LECTURER".equals(role)) {
        response.sendRedirect(request.getContextPath() + "/pages/login/login.jsp?error=unauthorized");
        return;
    }

    String idParam = request.getParameter("id");
    long bookingId;
    try {
        bookingId = Long.parseLong(idParam);
    } catch (Exception ex) {
        response.sendRedirect(request.getContextPath() + "/BookingController");
        return;
    }

    BookingRequest booking = currentUserId == null
            ? null
            : new BookingDAO().getBookingByIdAndUserId(bookingId, currentUserId);
    if (booking == null) {
        response.sendRedirect(request.getContextPath() + "/BookingController");
        return;
    }

    boolean paymentEligible = booking.getStatus() == BookingRequest.Status.APPROVED;
    boolean submitted = "POST".equalsIgnoreCase(request.getMethod());

    String paymentMethod = request.getParameter("paymentMethod");
    String payerName = request.getParameter("payerName");
    String payerEmail = request.getParameter("payerEmail");
    String cardNumber = request.getParameter("cardNumber");
    String cardExpiry = request.getParameter("cardExpiry");
    String cardCvv = request.getParameter("cardCvv");
    String billingAddress = request.getParameter("billingAddress");

    boolean hasErrors = submitted && (
            !paymentEligible ||
            blank(paymentMethod) ||
            blank(payerName) ||
            blank(payerEmail) ||
            blank(cardNumber) ||
            blank(cardExpiry) ||
            blank(cardCvv));

    String successMessage = null;
    String errorMessage = null;
    String receiptReference = null;
    if (submitted) {
        if (!paymentEligible) {
            errorMessage = "Payment is only available after the request is approved.";
        } else if (hasErrors) {
            errorMessage = "Please complete all required payment fields.";
        } else {
            receiptReference = "PMT-" + booking.getId() + "-" + System.currentTimeMillis();
            successMessage = "Payment submitted successfully. Receipt reference: " + receiptReference + ".";
        }
    }

    String requestCode = booking.getRequestCode() != null && !booking.getRequestCode().trim().isEmpty()
            ? booking.getRequestCode()
            : "BK-" + booking.getId();
    String statusLabel = booking.getStatus() == null ? "Unknown" : booking.getStatus().name();
    String statusDisplay = statusLabel.substring(0, 1) + statusLabel.substring(1).toLowerCase();
    String amountDue = money(booking.getEstimatedRentalFee());
    String dailyFee = money(booking.getDailyRentalFee());
    String lateFee = money(booking.getLateFeePerHour());
    String tripDate = formatDate(booking.getTripDate());
    String returnDate = formatDate(booking.getReturnDate());
    String vehicleType = booking.getVehicleType() == null ? "-" : (booking.getVehicleType() == BookingRequest.VehicleType.SEDAN ? "Sedan" : "SUV");
%>
<!DOCTYPE html>
<html class="light" lang="en">
    <head>
        <meta charset="utf-8"/>
        <meta content="width=device-width, initial-scale=1.0" name="viewport"/>
        <title>Campus Vehicle Booking System | Payment</title>
        <script src="https://cdn.tailwindcss.com?plugins=forms,container-queries"></script>
        <script src="${pageContext.request.contextPath}/assets/js/tailwind.config.js"></script>
        <link href="https://fonts.googleapis.com/css2?family=Manrope:wght@400;600;700;800&family=Inter:wght@400;500;600&display=swap" rel="stylesheet"/>
        <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap" rel="stylesheet"/>
        <link href="${pageContext.request.contextPath}/assets/css/fleet-management.css" rel="stylesheet"/>
    </head>
    <body class="bg-surface text-on-surface font-body selection:bg-secondary-container">
        <jsp:include page="/partials/sidebar.jsp">
            <jsp:param name="active" value="booking" />
        </jsp:include>

        <main class="pl-64 min-h-screen">
            <jsp:include page="/partials/navbar.jsp" />

            <div class="pt-24 px-8 pb-12 space-y-6">
                <section class="flex flex-col lg:flex-row lg:items-end lg:justify-between gap-4">
                    <div>
                        <p class="text-xs uppercase tracking-[0.24em] font-semibold text-on-surface-variant">User module</p>
                        <h1 class="font-headline font-extrabold text-3xl tracking-tight text-on-surface mt-2">Make Payment</h1>
                        <p class="text-on-surface-variant mt-2">
                            Request <span class="font-semibold text-primary"><%= esc(requestCode) %></span>
                            - Status: <span class="font-semibold"><%= esc(statusDisplay) %></span>
                        </p>
                    </div>
                    <div class="flex flex-wrap gap-3">
                        <a href="${pageContext.request.contextPath}/BookingController?action=detail&id=<%= booking.getId() %>" class="px-4 py-2 rounded-md border border-outline-variant/30 text-sm font-semibold hover:bg-surface-container-high">
                            Back to Detail
                        </a>
                    </div>
                </section>

                <% if (successMessage != null) { %>
                <div class="rounded-2xl border border-emerald-200 bg-emerald-50 text-emerald-800 px-4 py-3 text-sm font-medium">
                    <strong class="block mb-1">Success</strong>
                    <div><%= esc(successMessage) %></div>
                </div>
                <% } else if (errorMessage != null) { %>
                <div class="rounded-2xl border border-red-200 bg-red-50 text-red-700 px-4 py-3 text-sm font-medium">
                    <strong class="block mb-1">Attention</strong>
                    <div><%= esc(errorMessage) %></div>
                </div>
                <% } %>

                <div class="grid grid-cols-1 xl:grid-cols-[minmax(0,1.1fr)_360px] gap-6 items-start">
                    <section class="bg-surface-container-lowest rounded-2xl border border-outline-variant/10 overflow-hidden shadow-sm">
                        <div class="px-6 py-5 border-b border-outline-variant/10">
                            <h2 class="font-headline font-bold text-xl">Payment Information</h2>
                            <p class="text-sm text-on-surface-variant mt-1">
                                Complete the form below to submit payment for this approved booking request.
                            </p>
                        </div>

                        <div class="p-6 space-y-5">
                            <% if (!paymentEligible) { %>
                            <div class="rounded-2xl border border-amber-200 bg-amber-50 p-4 text-sm text-amber-900">
                                Payment is only available for approved bookings. This request is currently
                                <span class="font-semibold"><%= esc(statusDisplay) %></span>.
                            </div>
                            <% } %>

                            <form action="${pageContext.request.contextPath}/pages/user/payment.jsp?id=<%= booking.getId() %>" method="POST" class="space-y-5">
                                <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                                    <div class="rounded-2xl border border-outline-variant/10 bg-surface-container-low p-4">
                                        <p class="text-[11px] uppercase tracking-[0.18em] text-on-surface-variant">Booking ID</p>
                                        <p class="mt-1 text-lg font-bold text-on-surface"><%= esc(requestCode) %></p>
                                    </div>
                                    <div class="rounded-2xl border border-outline-variant/10 bg-surface-container-low p-4">
                                        <p class="text-[11px] uppercase tracking-[0.18em] text-on-surface-variant">Amount Due</p>
                                        <p class="mt-1 text-lg font-bold text-primary">RM <%= amountDue %></p>
                                    </div>
                                </div>

                                <div class="rounded-2xl border border-outline-variant/10 bg-surface-container-low p-4">
                                    <p class="text-sm font-semibold text-on-surface">Payment Method</p>
                                    <div class="grid grid-cols-1 md:grid-cols-3 gap-3 mt-4">
                                        <label class="flex items-start gap-3 rounded-2xl border border-outline-variant/20 bg-white p-4 cursor-pointer has-[:checked]:border-primary has-[:checked]:bg-primary/5">
                                            <input type="radio" name="paymentMethod" value="CARD" <%= submitted && "CARD".equals(paymentMethod) ? "checked" : (!submitted ? "checked" : "") %> class="mt-1 text-primary focus:ring-primary" <%= paymentEligible ? "" : "disabled" %>/>
                                            <span>
                                                <span class="block font-semibold text-on-surface">Card</span>
                                                <span class="block text-sm text-on-surface-variant mt-1">Visa or MasterCard</span>
                                            </span>
                                        </label>
                                        <label class="flex items-start gap-3 rounded-2xl border border-outline-variant/20 bg-white p-4 cursor-pointer has-[:checked]:border-primary has-[:checked]:bg-primary/5">
                                            <input type="radio" name="paymentMethod" value="ONLINE_BANKING" <%= "ONLINE_BANKING".equals(paymentMethod) ? "checked" : "" %> class="mt-1 text-primary focus:ring-primary" <%= paymentEligible ? "" : "disabled" %>/>
                                            <span>
                                                <span class="block font-semibold text-on-surface">Online Banking</span>
                                                <span class="block text-sm text-on-surface-variant mt-1">FPX / bank transfer</span>
                                            </span>
                                        </label>
                                        <label class="flex items-start gap-3 rounded-2xl border border-outline-variant/20 bg-white p-4 cursor-pointer has-[:checked]:border-primary has-[:checked]:bg-primary/5">
                                            <input type="radio" name="paymentMethod" value="EWALLET" <%= "EWALLET".equals(paymentMethod) ? "checked" : "" %> class="mt-1 text-primary focus:ring-primary" <%= paymentEligible ? "" : "disabled" %>/>
                                            <span>
                                                <span class="block font-semibold text-on-surface">E-Wallet</span>
                                                <span class="block text-sm text-on-surface-variant mt-1">Touch 'n Go, Boost, or similar</span>
                                            </span>
                                        </label>
                                    </div>
                                </div>

                                <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                                    <label class="block">
                                        <span class="text-sm font-semibold text-on-surface-variant">Payer Name</span>
                                        <input type="text" name="payerName" value="<%= esc(payerName) %>" required class="mt-1 w-full rounded-xl border border-outline-variant/30 bg-surface-container-low px-4 py-3 text-sm focus:ring-1 focus:ring-surface-tint <%= paymentEligible ? "" : "opacity-70" %>" <%= paymentEligible ? "" : "disabled" %>/>
                                    </label>
                                    <label class="block">
                                        <span class="text-sm font-semibold text-on-surface-variant">Payer Email</span>
                                        <input type="email" name="payerEmail" value="<%= esc(payerEmail) %>" required class="mt-1 w-full rounded-xl border border-outline-variant/30 bg-surface-container-low px-4 py-3 text-sm focus:ring-1 focus:ring-surface-tint <%= paymentEligible ? "" : "opacity-70" %>" <%= paymentEligible ? "" : "disabled" %>/>
                                    </label>
                                </div>

                                <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                                    <label class="block">
                                        <span class="text-sm font-semibold text-on-surface-variant">Card Number</span>
                                        <input type="text" name="cardNumber" value="<%= esc(cardNumber) %>" placeholder="1234 5678 9012 3456" required class="mt-1 w-full rounded-xl border border-outline-variant/30 bg-surface-container-low px-4 py-3 text-sm focus:ring-1 focus:ring-surface-tint <%= paymentEligible ? "" : "opacity-70" %>" <%= paymentEligible ? "" : "disabled" %>/>
                                    </label>
                                    <div class="grid grid-cols-2 gap-4">
                                        <label class="block">
                                            <span class="text-sm font-semibold text-on-surface-variant">Expiry</span>
                                            <input type="text" name="cardExpiry" value="<%= esc(cardExpiry) %>" placeholder="MM/YY" required class="mt-1 w-full rounded-xl border border-outline-variant/30 bg-surface-container-low px-4 py-3 text-sm focus:ring-1 focus:ring-surface-tint <%= paymentEligible ? "" : "opacity-70" %>" <%= paymentEligible ? "" : "disabled" %>/>
                                        </label>
                                        <label class="block">
                                            <span class="text-sm font-semibold text-on-surface-variant">CVV</span>
                                            <input type="password" name="cardCvv" value="<%= esc(cardCvv) %>" placeholder="123" maxlength="4" required class="mt-1 w-full rounded-xl border border-outline-variant/30 bg-surface-container-low px-4 py-3 text-sm focus:ring-1 focus:ring-surface-tint <%= paymentEligible ? "" : "opacity-70" %>" <%= paymentEligible ? "" : "disabled" %>/>
                                        </label>
                                    </div>
                                </div>

                                <label class="block">
                                    <span class="text-sm font-semibold text-on-surface-variant">Billing Address</span>
                                    <textarea name="billingAddress" rows="4" placeholder="Optional billing address" class="mt-1 w-full rounded-xl border border-outline-variant/30 bg-surface-container-low px-4 py-3 text-sm focus:ring-1 focus:ring-surface-tint <%= paymentEligible ? "" : "opacity-70" %>" <%= paymentEligible ? "" : "disabled" %>><%= esc(billingAddress) %></textarea>
                                </label>

                                <div class="flex flex-col-reverse md:flex-row md:items-center md:justify-between gap-3 pt-2">
                                    <div class="text-sm text-on-surface-variant">
                                        Amount due:
                                        <span class="font-semibold text-on-surface">RM <%= amountDue %></span>
                                    </div>
                                    <div class="flex flex-col sm:flex-row gap-3">
                                        <a href="${pageContext.request.contextPath}/BookingController?action=detail&id=<%= booking.getId() %>" class="px-5 py-3 rounded-xl border border-outline-variant/30 text-on-surface-variant font-semibold hover:bg-surface-container-high transition-colors text-center">
                                            Cancel
                                        </a>
                                        <% if (paymentEligible) { %>
                                        <button type="submit" class="px-5 py-3 rounded-xl bg-gradient-to-r from-primary to-surface-tint text-white font-semibold shadow-sm">
                                            Submit Payment
                                        </button>
                                        <% } else { %>
                                        <button type="button" disabled class="px-5 py-3 rounded-xl bg-surface-container-high text-on-surface-variant font-semibold opacity-70 cursor-not-allowed">
                                            Payment Unavailable
                                        </button>
                                        <% } %>
                                    </div>
                                </div>
                            </form>
                        </div>
                    </section>

                    <aside class="space-y-6">
                        <section class="bg-surface-container-lowest rounded-2xl border border-outline-variant/10 p-5 shadow-sm">
                            <h2 class="font-headline font-bold text-lg">Payment Summary</h2>
                            <p class="text-sm text-on-surface-variant mt-1">Review the booking details before confirming payment.</p>

                            <div class="space-y-3 mt-4">
                                <div class="rounded-xl border border-outline-variant/10 bg-surface-container-low p-4">
                                    <p class="text-[11px] uppercase tracking-[0.18em] text-on-surface-variant">Trip Dates</p>
                                    <p class="mt-1 font-semibold text-on-surface"><%= esc(tripDate) %> - <%= esc(returnDate) %></p>
                                </div>
                                <div class="rounded-xl border border-outline-variant/10 bg-surface-container-low p-4">
                                    <p class="text-[11px] uppercase tracking-[0.18em] text-on-surface-variant">Destination</p>
                                    <p class="mt-1 font-semibold text-on-surface"><%= esc(booking.getDestination()) %></p>
                                </div>
                                <div class="rounded-xl border border-outline-variant/10 bg-surface-container-low p-4">
                                    <p class="text-[11px] uppercase tracking-[0.18em] text-on-surface-variant">Vehicle Type</p>
                                    <p class="mt-1 font-semibold text-on-surface"><%= esc(vehicleType) %></p>
                                </div>
                                <div class="rounded-xl border border-outline-variant/10 bg-surface-container-low p-4">
                                    <p class="text-[11px] uppercase tracking-[0.18em] text-on-surface-variant">Daily Rental Fee</p>
                                    <p class="mt-1 font-semibold text-on-surface">RM <%= dailyFee %></p>
                                </div>
                                <div class="rounded-xl border border-outline-variant/10 bg-surface-container-low p-4">
                                    <p class="text-[11px] uppercase tracking-[0.18em] text-on-surface-variant">Late Fee Per Hour</p>
                                    <p class="mt-1 font-semibold text-on-surface">RM <%= lateFee %></p>
                                </div>
                            </div>

                            <div class="mt-4 rounded-2xl bg-primary/5 border border-primary/10 p-4">
                                <p class="text-[11px] uppercase tracking-[0.18em] text-on-surface-variant">Total Due</p>
                                <p class="mt-1 text-3xl font-extrabold text-primary">RM <%= amountDue %></p>
                            </div>
                        </section>

                        <section class="bg-surface-container-lowest rounded-2xl border border-outline-variant/10 p-5 shadow-sm">
                            <h2 class="font-headline font-bold text-lg">Accepted Methods</h2>
                            <div class="space-y-3 mt-4 text-sm text-on-surface-variant">
                                <div class="rounded-xl border border-outline-variant/10 bg-surface-container-low p-4">
                                    Credit or debit card
                                </div>
                                <div class="rounded-xl border border-outline-variant/10 bg-surface-container-low p-4">
                                    Online banking transfer
                                </div>
                                <div class="rounded-xl border border-outline-variant/10 bg-surface-container-low p-4">
                                    E-wallet payment
                                </div>
                            </div>
                        </section>
                    </aside>
                </div>
            </div>
        </main>
    </body>
</html>
