package com.project.controller;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/LogoutController")
public class LogoutController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Get existing session only
        HttpSession session = request.getSession(false);

        if (session != null) {
            session.invalidate(); // destroy session
        }

        // Redirect to login page
        response.sendRedirect(request.getContextPath() + "/pages/login/login.jsp?logout=success");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        doGet(request, response); // reuse logic
    }
}