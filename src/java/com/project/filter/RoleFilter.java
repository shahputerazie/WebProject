package com.project.filter;

import java.io.IOException;
import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.*;

@WebFilter(urlPatterns = {"/pages/admin/*", "/pages/user/*", "/pages/staff/*", "/BookingController", "/VehicleController"})
public class RoleFilter implements Filter {

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;

        HttpSession session = request.getSession(false);
        String role = (session != null && session.getAttribute("role") instanceof String)
                ? ((String) session.getAttribute("role")).trim().toUpperCase()
                : null;

        String path = request.getServletPath();
        boolean allowed = false;

        if (path.startsWith("/pages/admin/")) {
            // Allow staff to access the approval dashboard page only.
            if (path.endsWith("/adminDashboard.jsp")) {
                allowed = "ADMIN".equals(role) || "STAFF".equals(role);
            } else {
                allowed = "ADMIN".equals(role);
            }
        } else if ("/admin/decisions".equals(path)) {
            allowed = "ADMIN".equals(role) || "STAFF".equals(role);
        } else if (path.startsWith("/pages/staff/") || "/VehicleController".equals(path)) {
            allowed = "ADMIN".equals(role) || "STAFF".equals(role);
        } else if (path.startsWith("/pages/user/") || "/BookingController".equals(path)) {
            allowed = "STUDENT".equals(role) || "LECTURER".equals(role);
        }

        if (!allowed) {
            response.sendRedirect(request.getContextPath() + "/pages/login/login.jsp?error=unauthorized");
            return;
        }

        chain.doFilter(req, res);
    }
}
