package com.project.dao;

import com.project.model.Vehicle;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class VehicleDAO {

    public boolean addVehicle(Vehicle v) {

        String sql = "INSERT INTO vehicles (license_plate, type, capacity, status) VALUES (?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, v.getLicensePlate());
            ps.setString(2, v.getType());
            ps.setInt(3, v.getCapacity());
            ps.setString(4, v.getStatus());

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public List<Vehicle> getAllVehicles() {

        List<Vehicle> list = new ArrayList<>();

        String sql = "SELECT * FROM vehicles ORDER BY id DESC";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {

                Vehicle v = new Vehicle(
                        rs.getInt("id"),
                        rs.getString("license_plate"),
                        rs.getString("type"),
                        rs.getInt("capacity"),
                        rs.getString("status")
                );

                list.add(v);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }
}
