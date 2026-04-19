package com.project.model;

import java.io.Serializable;

public class User implements Serializable {

    // Attributes from the Data Model Class Diagram [cite: 114, 116, 117, 122, 123, 120, 124]
    private int userId;           // PK
    private String name;
    private String email;          // Unique
    private String passwordHash;
    private int roleId;            // FK to Role
    private String phone;
    private boolean isActive;

    // Default Constructor
    public User() {
    }

    // Parameterized Constructor for easier instantiation
    public User(int userId, String name, String email, String passwordHash, int roleId, String phone, boolean isActive) {
        this.userId = userId;
        this.name = name;
        this.email = email;
        this.passwordHash = passwordHash;
        this.roleId = roleId;
        this.phone = phone;
        this.isActive = isActive;
    }

    // Getters and Setters [cite: 111]
    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
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

    public String getPasswordHash() {
        return passwordHash;
    }

    public void setPasswordHash(String passwordHash) {
        this.passwordHash = passwordHash;
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

    public boolean isIsActive() {
        return isActive;
    }

    public void setIsActive(boolean isActive) {
        this.isActive = isActive;
    }

    /**
     * Requirement: validatePassword(p: String): Boolean [cite: 121] In a real
     * application, you would compare the provided string with the hash.
     */
    public boolean validatePassword(String password) {
        // Basic implementation: replace with BCrypt or MD5 check as per your security needs
        return this.passwordHash != null && this.passwordHash.equals(password);
    }

    /**
     * Requirement: updateProfile() [cite: 126] This can be used to encapsulate
     * profile update logic if needed.
     */
    public void updateProfile() {
        // Logic for internal state updates before saving to DAO
        System.out.println("Updating profile for: " + this.name);
    }
}
