package com.project.controller;

import com.project.dao.VehicleDAO;
import com.project.model.Vehicle;
import java.io.IOException;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.http.*;

public class VehicleController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        String role = (session != null && session.getAttribute("role") instanceof String)
                ? ((String) session.getAttribute("role")).trim().toUpperCase() : null;
        if (!("ADMIN".equals(role) || "STAFF".equals(role))) {
            response.sendRedirect(request.getContextPath() + "/pages/login/login.jsp?error=unauthorized");
            return;
        }

        String action = request.getParameter("action");
        VehicleDAO dao = new VehicleDAO();

        if (action == null || action.equals("list")) {

            String keyword = request.getParameter("keyword");
            String type = request.getParameter("type");
            String status = request.getParameter("status");

            if (keyword == null) {
                keyword = "";
            }
            if (type == null) {
                type = "";
            }
            if (status == null) {
                status = "";
            }

            keyword = keyword.trim();
            type = type.trim();
            status = status.trim();

            List<Vehicle> list = dao.searchVehicles(keyword, type, status);

            request.setAttribute("vehicles", list);
            request.getRequestDispatcher("/pages/staff/fleetList.jsp").forward(request, response);

        } else if (action.equals("edit")) {

            int id = Integer.parseInt(request.getParameter("id"));
            request.setAttribute("vehicle", dao.getVehicleById(id));
            request.getRequestDispatcher("/pages/staff/editVehicle.jsp").forward(request, response);

        } else if (action.equals("delete")) {

            dao.deleteVehicle(Integer.parseInt(request.getParameter("id")));
            response.sendRedirect("VehicleController?action=list&deleted=true");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        String role = (session != null && session.getAttribute("role") instanceof String)
                ? ((String) session.getAttribute("role")).trim().toUpperCase() : null;
        if (!("ADMIN".equals(role) || "STAFF".equals(role))) {
            response.sendRedirect(request.getContextPath() + "/pages/login/login.jsp?error=unauthorized");
            return;
        }

        System.out.println("=== VEHICLE CONTROLLER DO POST CALLED ===");
        System.out.println("ACTION = " + request.getParameter("action"));

        String action = request.getParameter("action");
        VehicleDAO dao = new VehicleDAO();

        if ("delete".equals(action)) {
            int id = Integer.parseInt(request.getParameter("id"));
            boolean success = dao.deleteVehicle(id);

            if (success) {
                response.sendRedirect("VehicleController?action=list&success=true");
            } else {
                response.sendRedirect("VehicleController?action=list&error=true");
            }
            return;
        }

        String plate = request.getParameter("licensePlate");
        String type = request.getParameter("type");
        int cap = Integer.parseInt(request.getParameter("capacity"));
        String status = request.getParameter("status");

        boolean success;

        if ("update".equals(action)) {
            int id = Integer.parseInt(request.getParameter("id"));
            success = dao.updateVehicle(new Vehicle(id, plate, type, cap, status));
        } else {
            success = dao.addVehicle(new Vehicle(plate, type, cap, status));
        }

        if (success) {
            response.sendRedirect("VehicleController?action=list&success=true");
        } else {
            response.sendRedirect("pages/staff/addVehicle.jsp?error=true");
        }
    }
}
