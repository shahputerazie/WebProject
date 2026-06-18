package com.project.controller;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/RoleSwitchController")
public class RoleSwitchController extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendRedirect(request.getContextPath() + "/pages/login/login.jsp");
            return;
        }

        String role = request.getParameter("role");
        String normalizedRole = role == null ? "" : role.trim().toUpperCase();

        String redirectUrl;
        switch (normalizedRole) {
            case "ADMIN":
                session.setAttribute("role", "ADMIN");
                redirectUrl = request.getContextPath() + "/pages/admin/dashboard.jsp";
                break;
            case "STAFF":
                session.setAttribute("role", "STAFF");
                redirectUrl = request.getContextPath() + "/pages/staff/dashboard.jsp";
                break;
            case "LECTURER":
            case "STUDENT":
                session.setAttribute("role", "STUDENT");
                redirectUrl = request.getContextPath() + "/pages/user/userDashboard.jsp";
                break;
            default:
                redirectUrl = request.getContextPath() + "/pages/user/userDashboard.jsp";
                break;
        }

        response.sendRedirect(redirectUrl);
    }
}
