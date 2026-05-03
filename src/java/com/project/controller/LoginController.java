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
        String loginType = request.getParameter("loginType"); // staff / others

        if (loginType == null || loginType.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/pages/login/preLogin.jsp");
            return;
        }

        UserDAO dao = new UserDAO();
        User user = dao.login(email, password);

        if (user == null) {
            response.sendRedirect(request.getContextPath()
                    + "/pages/login/login.jsp?loginType=" + loginType + "&error=invalid");
            return;
        }

        int roleId = user.getRoleId();

        // STAFF/ADMIN login page only allows admin role
        if ("staff".equals(loginType) && roleId != 3) {
            response.sendRedirect(request.getContextPath()
                    + "/pages/login/login.jsp?loginType=staff&error=invalidrole");
            return;
        }

        // OTHERS login page only allows student/lecturer
        if ("others".equals(loginType) && roleId == 3) {
            response.sendRedirect(request.getContextPath()
                    + "/pages/login/login.jsp?loginType=others&error=invalidrole");
            return;
        }

        HttpSession session = request.getSession();

        session.setAttribute("user", user);
        session.setAttribute("userId", user.getUserId());
        session.setAttribute("userName", user.getName());
        session.setAttribute("email", user.getEmail());
        session.setAttribute("roleId", roleId);

        if (roleId == 3) {
            response.sendRedirect(request.getContextPath() + "/pages/admin/adminDashboard.jsp");
        } else {
            response.sendRedirect(request.getContextPath() + "/pages/user/userDashboard.jsp");
        }
    }
}