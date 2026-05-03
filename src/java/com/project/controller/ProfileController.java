package com.project.controller;

import com.project.dao.UserDAO;
import com.project.model.User;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/ProfileController")
public class ProfileController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/pages/login/login.jsp");
            return;
        }

        String userId = (String) session.getAttribute("userId");

        UserDAO dao = new UserDAO();
        User user = dao.getUserById(userId);

        request.setAttribute("user", user);
        request.getRequestDispatcher("/pages/login/profile.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session == null || session.getAttribute("userId") == null) {
            response.sendRedirect(request.getContextPath() + "/pages/login/login.jsp");
            return;
        }

        String userId = (String) session.getAttribute("userId");
        String name = request.getParameter("name");
        String phone = request.getParameter("phone");
        String newPassword = request.getParameter("newPassword");

        UserDAO dao = new UserDAO();

        User user = dao.getUserById(userId);
        user.setName(name);
        user.setPhone(phone);

        boolean profileUpdated = dao.updateProfile(user);

        if (newPassword != null && !newPassword.trim().isEmpty()) {
            dao.changePassword(userId, newPassword);
        }

        User updatedUser = dao.getUserById(userId);
        session.setAttribute("user", updatedUser);
        session.setAttribute("userName", updatedUser.getName());

        if (profileUpdated) {
            response.sendRedirect(request.getContextPath() + "/ProfileController?status=updated");
        } else {
            response.sendRedirect(request.getContextPath() + "/ProfileController?status=error");
        }
    }
}
