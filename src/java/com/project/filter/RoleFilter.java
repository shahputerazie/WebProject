package com.project.filter;

import java.io.IOException;
import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.*;

@WebFilter("/pages/admin/*")
public class RoleFilter implements Filter {

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;

        HttpSession session = request.getSession(false);
        Object roleObj = (session != null) ? session.getAttribute("roleId") : null;

        if (!(roleObj instanceof Integer) || ((Integer) roleObj) != 3) {
            response.sendRedirect(request.getContextPath() + "/pages/login/login.jsp?error=unauthorized");
            return;
        }

        chain.doFilter(req, res);
    }
}