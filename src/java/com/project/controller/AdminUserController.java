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

        if (session == null || session.getAttribute("roleId") == null) {
            return false;
        }

        int roleId = (int) session.getAttribute("roleId");
        return roleId == 3;
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
            int roleId = Integer.parseInt(request.getParameter("roleId"));
            boolean isActive = Boolean.parseBoolean(request.getParameter("isActive"));
            success = dao.updateRoleAndStatus(userId, roleId, isActive);

        } else if ("deactivate".equals(action)) {
            success = dao.deactivateUser(userId);

        } else if ("activate".equals(action)) {
            int roleId = Integer.parseInt(request.getParameter("roleId"));
            success = dao.updateRoleAndStatus(userId, roleId, true);
        }

        if (success) {
            response.sendRedirect(request.getContextPath() + "/AdminUserController?status=success");
        } else {
            response.sendRedirect(request.getContextPath() + "/AdminUserController?status=error");
        }
    }
}