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

            System.out.println("Trying to insert vehicle: " + v.getLicensePlate());

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            System.out.println("ADD VEHICLE ERROR: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    public List<Vehicle> getAllVehicles() {
        List<Vehicle> list = new ArrayList<>();
        String sql = "SELECT * FROM vehicles ORDER BY id DESC";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(new Vehicle(rs.getInt("id"), rs.getString("license_plate"),
                        rs.getString("type"), rs.getInt("capacity"), rs.getString("status")));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Vehicle> getVehiclesByStatus(String status) {
        List<Vehicle> list = new ArrayList<>();
        String sql = "SELECT * FROM vehicles WHERE status = ? ORDER BY id DESC";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(new Vehicle(rs.getInt("id"), rs.getString("license_plate"),
                        rs.getString("type"), rs.getInt("capacity"), rs.getString("status")));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Vehicle> getAvailableVehiclesByType(String type) {
        List<Vehicle> list = new ArrayList<>();
        String sql = "SELECT * FROM vehicles WHERE status = 'AVAILABLE' AND type = ? ORDER BY license_plate ASC";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, type);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(new Vehicle(rs.getInt("id"), rs.getString("license_plate"),
                            rs.getString("type"), rs.getInt("capacity"), rs.getString("status")));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public int countAvailableVehiclesByType(String type) {
        String sql = "SELECT COUNT(*) AS total FROM vehicles WHERE status = 'AVAILABLE' AND type = ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, type);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("total");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    public Vehicle getVehicleById(int id) {
        String sql = "SELECT * FROM vehicles WHERE id = ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return new Vehicle(rs.getInt("id"), rs.getString("license_plate"),
                        rs.getString("type"), rs.getInt("capacity"), rs.getString("status"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean updateVehicle(Vehicle v) {
        String sql = "UPDATE vehicles SET license_plate=?, type=?, capacity=?, status=? WHERE id=?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, v.getLicensePlate());
            ps.setString(2, v.getType());
            ps.setInt(3, v.getCapacity());
            ps.setString(4, v.getStatus());
            ps.setInt(5, v.getId());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean deleteVehicle(int id) {
        String sql = "DELETE FROM vehicles WHERE id = ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public List<Vehicle> searchVehicles(String keyword, String type, String status) {
        List<Vehicle> list = new ArrayList<>();

        String sql = "SELECT * FROM vehicles WHERE license_plate LIKE ? "
                + "AND (? = '' OR type = ?) "
                + "AND (? = '' OR status = ?) "
                + "ORDER BY id DESC";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, "%" + keyword + "%");
            ps.setString(2, type);
            ps.setString(3, type);
            ps.setString(4, status);
            ps.setString(5, status);

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                list.add(new Vehicle(
                        rs.getInt("id"),
                        rs.getString("license_plate"),
                        rs.getString("type"),
                        rs.getInt("capacity"),
                        rs.getString("status")
                ));
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }
}
