package com.project.dao;

import com.project.model.User;
import com.project.util.PasswordUtil;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class UserDAO {

    // ===================== LOGIN =====================
    public User login(String email, String password) {
        User user = null;
        String sql = "SELECT * FROM users WHERE LOWER(email) = LOWER(?) AND isActive = 1";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, email);

            ResultSet rs = ps.executeQuery();

            if (rs.next() && PasswordUtil.matches(password, rs.getString("passwordHash"))) {
                user = mapResultSetToUser(rs);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return user;
    }

    // ===================== REGISTER =====================
    public boolean registerUser(User user) {
        String sql = "INSERT INTO users (name, email, passwordHash, role, phone, isActive) VALUES (?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, user.getName());
            ps.setString(2, user.getEmail());
            ps.setString(3, user.getPasswordHash());
            ps.setString(4, user.getRole());
            ps.setString(5, user.getPhone());
            ps.setBoolean(6, true);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            System.out.println("REGISTER FAILED:");
            System.out.println(e.getMessage());
            e.printStackTrace();
        }

        return false;
    }

    // ===================== CHECK EMAIL =====================
    public boolean emailExists(String email) {
        String sql = "SELECT email FROM users WHERE email = ?";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, email);
            ResultSet rs = ps.executeQuery();

            return rs.next();

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    // ===================== GET USER =====================
    public User getUserById(String userId) {
        User user = null;
        String sql = "SELECT * FROM users WHERE userId = ?";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, userId);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                user = mapResultSetToUser(rs);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return user;
    }

    // ===================== UPDATE PROFILE =====================
    public boolean updateProfile(User user) {
        // ❗ FIXED: remove email (since it's readonly in JSP)
        String sql = "UPDATE users SET name = ?, phone = ? WHERE userId = ?";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, user.getName());
            ps.setString(2, user.getPhone());
            ps.setString(3, user.getUserId());

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    // ===================== CHANGE PASSWORD =====================
    public boolean changePassword(String userId, String newPassword) {
        String sql = "UPDATE users SET passwordHash = ? WHERE userId = ?";
        String hashedPassword = PasswordUtil.hash(newPassword);

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, hashedPassword);
            ps.setString(2, userId);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    // ===================== ADMIN UPDATE =====================
    public boolean updateRoleAndStatus(String userId, String role, boolean isActive) {
        String sql = "UPDATE users SET role = ?, isActive = ? WHERE userId = ?";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, role);
            ps.setBoolean(2, isActive);
            ps.setString(3, userId);

            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    // ===================== DEACTIVATE =====================
    public boolean deactivateUser(String userId) {
        String sql = "UPDATE users SET isActive = 0 WHERE userId = ?";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, userId);
            return ps.executeUpdate() > 0;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }

    // ===================== GET ALL USERS =====================
    public List<User> getAllUsers() {
        List<User> userList = new ArrayList<>();
        String sql = "SELECT * FROM users";

        try (Connection conn = DBConnection.getConnection(); Statement stmt = conn.createStatement(); ResultSet rs = stmt.executeQuery(sql)) {

            while (rs.next()) {
                userList.add(mapResultSetToUser(rs));
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return userList;
    }

    // ===================== MAPPER =====================
    private User mapResultSetToUser(ResultSet rs) throws SQLException {
        User user = new User();

        user.setUserId(rs.getString("userId"));
        user.setName(rs.getString("name"));
        user.setEmail(rs.getString("email"));
        user.setPassword(rs.getString("passwordHash"));
        user.setRole(rs.getString("role"));
        user.setPhone(rs.getString("phone"));
        user.setActive(rs.getBoolean("isActive"));

        return user;
    }
}
