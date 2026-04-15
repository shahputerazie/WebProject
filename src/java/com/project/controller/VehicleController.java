package com.project.controller;

import com.project.dao.VehicleDAO;
import com.project.model.Vehicle;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/VehicleController")
public class VehicleController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        if (action == null || action.equals("list")) {
            listVehicles(request, response);
        } else {
            response.sendRedirect("fleetList.jsp?error=invalid_action");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        if (action == null) {
            response.sendRedirect("VehicleController?action=list&error=missing_action");
            return;
        }

        switch (action) {
            case "create":
                createVehicle(request, response);
                break;

            default:
                response.sendRedirect("VehicleController?action=list&error=invalid_action");
        }
    }

    // ===================== LIST VEHICLES =====================
    private void listVehicles(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        VehicleDAO dao = new VehicleDAO();
        request.setAttribute("vehicleList", dao.getAllVehicles());

        request.getRequestDispatcher("fleetList.jsp").forward(request, response);
    }

    // ===================== CREATE VEHICLE =====================
    private void createVehicle(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        try {
            String licensePlate = request.getParameter("licensePlate");
            String type = request.getParameter("type");
            int capacity = Integer.parseInt(request.getParameter("capacity"));
            String status = request.getParameter("status");

            Vehicle v = new Vehicle(0, licensePlate, type, capacity, status);

            VehicleDAO dao = new VehicleDAO();
            boolean success = dao.addVehicle(v);

            if (success) {
                response.sendRedirect("VehicleController?action=list&success=true");
            } else {
                response.sendRedirect("addVehicle.jsp?error=db_failed");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("addVehicle.jsp?error=exception");
        }
    }
}
