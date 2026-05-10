package com.project.model;

import java.io.Serializable;

public class User implements Serializable {

    // Attributes aligned with DB Schema
    private String userId;      // PK (Supports S75034)
    private String name;
    private String email;
    private String passwordHash;
    private int roleId;         // FK to Role
    private String phone;
    private boolean isActive;

    // Default Constructor
    public User() {
    }

    // Fixed Parameterized Constructor: userId changed from int to String
    public User(String userId, String name, String email, String passwordHash, int roleId, String phone, boolean isActive) {
        this.userId = userId;
        this.name = name;
        this.email = email;
        this.passwordHash = passwordHash;
        this.roleId = roleId;
        this.phone = phone;
        this.isActive = isActive;
    }

    // Fixed Getters and Setters for userId
    public String getUserId() {
        return userId;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    // Unified Password methods to work with your DAO
    public String getPasswordHash() {
        return passwordHash;
    }

    public void setPasswordHash(String passwordHash) {
        this.passwordHash = passwordHash;
    }
    
    // Alias for getPasswordHash to satisfy UserDAO.java
    public String getPassword() {
        return passwordHash;
    }

    // Alias for setPasswordHash to satisfy UserDAO.java
    public void setPassword(String password) {
        this.passwordHash = password;
    }

    public int getRoleId() {
        return roleId;
    }

    public void setRoleId(int roleId) {
        this.roleId = roleId;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public boolean isActive() {
        return isActive;
    }

    public void setActive(boolean isActive) {
        this.isActive = isActive;
    }

    // Custom logic methods
    public boolean validatePassword(String password) {
        return this.passwordHash != null && this.passwordHash.equals(password);
    }

    public void updateProfile() {
        System.out.println("Updating profile for: " + this.name);
    }
}