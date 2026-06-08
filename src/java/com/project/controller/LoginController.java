package com.project.controller;

import com.project.dao.UserDAO;
import com.project.model.User;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/LoginController")
public class LoginController extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String email = request.getParameter("email");
        String password = request.getParameter("password");
        email = (email != null) ? email.trim().toLowerCase() : null;

        UserDAO dao = new UserDAO();
        User user = dao.login(email, password);

        if (user == null) {
            response.sendRedirect(request.getContextPath()
                    + "/pages/login/login.jsp?error=invalid");
            return;
        }

        String role = user.getRole();
        role = (role != null) ? role.trim().toUpperCase() : null;

        HttpSession oldSession = request.getSession(false);
        if (oldSession != null) {
            oldSession.invalidate();
        }
        HttpSession session = request.getSession(true);

        session.setAttribute("user", user);
        session.setAttribute("userId", user.getUserId());
        session.setAttribute("userName", user.getName());
        session.setAttribute("email", user.getEmail());
        session.setAttribute("role", role);

        if ("ADMIN".equals(role)) {
            response.sendRedirect(request.getContextPath() + "/pages/admin/dashboard.jsp");
        } else if ("STAFF".equals(role)) {
            response.sendRedirect(request.getContextPath() + "/pages/staff/dashboard.jsp");
        } else {
            response.sendRedirect(request.getContextPath() + "/pages/user/userDashboard.jsp");
        }
    }
}
