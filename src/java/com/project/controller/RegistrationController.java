package com.project.controller;

import com.project.dao.UserDAO;
import com.project.model.User;

import java.io.IOException;
import java.util.UUID;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/RegistrationController")
public class RegistrationController extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");

        int roleId = Integer.parseInt(request.getParameter("roleId"));

        // Prevent normal users from registering as Admin
        if (roleId == 3) {
            response.sendRedirect(request.getContextPath() + "/pages/login/register.jsp?error=invalidrole");
            return;
        }

        if (!password.equals(confirmPassword)) {
            response.sendRedirect(request.getContextPath() + "/pages/login/register.jsp?error=password");
            return;
        }

        UserDAO dao = new UserDAO();

        if (dao.emailExists(email)) {
            response.sendRedirect(request.getContextPath() + "/pages/login/register.jsp?error=email");
            return;
        }

        User user = new User();
        user.setUserId(UUID.randomUUID().toString());
        user.setName(name);
        user.setEmail(email);
        user.setPhone(phone);
        user.setPassword(password);
        user.setRoleId(roleId);
        user.setActive(true);

        boolean success = dao.registerUser(user);

        if (success) {
            response.sendRedirect(request.getContextPath() + "/pages/login/login.jsp?registered=true");
        } else {
            response.sendRedirect(request.getContextPath() + "/pages/login/register.jsp?error=fail");
        }
    }
}
