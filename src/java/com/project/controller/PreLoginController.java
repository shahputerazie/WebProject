package com.project.controller;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/PreLoginController")
public class PreLoginController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.sendRedirect(request.getContextPath() + "/pages/login/preLogin.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String loginType = request.getParameter("loginType");

        if (loginType == null || loginType.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/pages/login/preLogin.jsp?error=missing");
            return;
        }

        if (loginType.equals("staff")) {
            response.sendRedirect(request.getContextPath() + "/pages/login/login.jsp?loginType=staff");
        } else if (loginType.equals("others")) {
            response.sendRedirect(request.getContextPath() + "/pages/login/login.jsp?loginType=others");
        } else {
            response.sendRedirect(request.getContextPath() + "/pages/login/preLogin.jsp?error=invalid");
        }
    }
}