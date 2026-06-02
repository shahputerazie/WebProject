package com.project.controller;

import com.project.dao.UserDAO;
import com.project.model.User;
import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/AdminUserController")
public class AdminUserController extends HttpServlet {

    private boolean isAdmin(HttpServletRequest request) {
        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("role") == null) {
            return false;
        }

        String role = (String) session.getAttribute("role");
        return "ADMIN".equals(role);
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!isAdmin(request)) {
            response.sendRedirect(request.getContextPath() + "/pages/login/login.jsp");
            return;
        }

        UserDAO dao = new UserDAO();
        List<User> users = dao.getAllUsers();

        request.setAttribute("users", users);
        request.getRequestDispatcher("/pages/login/admin-user-management.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!isAdmin(request)) {
            response.sendRedirect(request.getContextPath() + "/pages/login/login.jsp");
            return;
        }

        String action = request.getParameter("action");
        String userId = request.getParameter("userId");

        UserDAO dao = new UserDAO();
        boolean success = false;

        if ("modifyRole".equals(action)) {
            String role = request.getParameter("role");
            if (!isAllowedRole(role)) {
                response.sendRedirect(request.getContextPath() + "/AdminUserController?status=error");
                return;
            }
            boolean isActive = Boolean.parseBoolean(request.getParameter("isActive"));
            success = dao.updateRoleAndStatus(userId, role, isActive);

        } else if ("deactivate".equals(action)) {
            success = dao.deactivateUser(userId);

        } else if ("activate".equals(action)) {
            String role = request.getParameter("role");
            if (!isAllowedRole(role)) {
                response.sendRedirect(request.getContextPath() + "/AdminUserController?status=error");
                return;
            }
            success = dao.updateRoleAndStatus(userId, role, true);
        }

        if (success) {
            response.sendRedirect(request.getContextPath() + "/AdminUserController?status=success");
        } else {
            response.sendRedirect(request.getContextPath() + "/AdminUserController?status=error");
        }
    }

    private boolean isAllowedRole(String role) {
        if (role == null) {
            return false;
        }
        String normalized = role.trim().toUpperCase();
        return "ADMIN".equals(normalized)
                || "STAFF".equals(normalized)
                || "STUDENT".equals(normalized)
                || "LECTURER".equals(normalized);
    }
}
