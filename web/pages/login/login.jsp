<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Login | University Vehicle Booking</title>
    <script src="https://cdn.tailwindcss.com?plugins=forms"></script>
    <link href="https://fonts.googleapis.com/css2?family=Manrope:wght@500;700;800&family=Plus+Jakarta+Sans:wght@400;600;700&display=swap" rel="stylesheet"/>
    <style>
        :root {
            --umt-navy: #042b61;
            --umt-blue: #1363c6;
            --umt-gold: #f7b718;
            --mist: #f4f7fc;
        }
        body {
            font-family: "Plus Jakarta Sans", sans-serif;
            background:
                radial-gradient(circle at 8% 12%, rgba(19, 99, 198, 0.15), transparent 35%),
                radial-gradient(circle at 92% 85%, rgba(247, 183, 24, 0.20), transparent 30%),
                linear-gradient(135deg, #eef4ff 0%, var(--mist) 45%, #ffffff 100%);
        }
        .headline {
            font-family: "Manrope", sans-serif;
        }
        .panel {
            animation: enterUp .45s ease-out both;
        }
        @keyframes enterUp {
            from { opacity: 0; transform: translateY(14px) scale(0.99); }
            to { opacity: 1; transform: translateY(0) scale(1); }
        }
    </style>
</head>
<body class="min-h-screen flex items-center justify-center px-4 py-10">

<div class="panel w-full max-w-md">
    <div class="bg-white/90 backdrop-blur rounded-3xl border border-slate-200 shadow-xl shadow-blue-900/10 p-8 sm:p-9">
        <div class="text-center mb-8">
            <img src="${pageContext.request.contextPath}/assets/images/Logo_Rasmi_UMT.png"
                 alt="Universiti Malaysia Terengganu logo"
                 class="mx-auto w-24 h-auto mb-4">
            <p class="text-xs font-semibold tracking-[0.18em] text-slate-500 uppercase">Universiti Malaysia Terengganu</p>
            <h1 class="headline text-3xl font-extrabold text-slate-900 mt-2">Campus Vehicle Booking</h1>
            <p class="text-slate-500 mt-2 text-sm">Sign in with your registered account</p>
        </div>

        <c:if test="${param.error != null}">
            <div class="bg-rose-50 text-rose-700 p-3 rounded-xl mb-5 text-sm border border-rose-200">
                Invalid email or password. Please try again.
            </div>
        </c:if>

        <form action="${pageContext.request.contextPath}/LoginController" method="POST" class="space-y-5">
            <div>
                <label class="block text-sm font-semibold mb-2 text-slate-800">University Email</label>
                <input type="email" name="email"
                       class="w-full rounded-xl border-slate-300 focus:border-[var(--umt-blue)] focus:ring-[var(--umt-blue)]"
                       placeholder="name@umt.edu.my" required>
            </div>

            <div>
                <label class="block text-sm font-semibold mb-2 text-slate-800">Password</label>
                <input type="password" name="password"
                       class="w-full rounded-xl border-slate-300 focus:border-[var(--umt-blue)] focus:ring-[var(--umt-blue)]"
                       placeholder="Enter your password" required>
            </div>

            <button type="submit"
                    class="w-full text-white py-3 rounded-xl font-bold transition-all duration-200 hover:-translate-y-0.5"
                    style="background: linear-gradient(120deg, var(--umt-navy), var(--umt-blue)); box-shadow: 0 10px 20px rgba(4, 43, 97, 0.18);">
                Sign In
            </button>
        </form>

        <p class="text-[11px] text-center text-slate-400 mt-6">
            © 2026 Universiti Malaysia Terengganu
        </p>
    </div>
</div>

</body>
</html>
