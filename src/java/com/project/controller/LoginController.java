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

        UserDAO dao = new UserDAO();
        User user = dao.login(email, password);

        if (user != null) {
            HttpSession session = request.getSession();

            session.setAttribute("user", user);
            session.setAttribute("userId", user.getUserId());
            session.setAttribute("userName", user.getName());
            session.setAttribute("email", user.getEmail());
            session.setAttribute("roleId", user.getRoleId());

            if (user.getRoleId() == 3) {
                response.sendRedirect(request.getContextPath() + "/pages/admin/adminDashboard.jsp");
            } else {
                response.sendRedirect(request.getContextPath() + "/pages/user/userDashboard.jsp");
            }

        } else {
            response.sendRedirect(request.getContextPath() + "/pages/login/login.jsp?error=invalid");
        }
    }
}
