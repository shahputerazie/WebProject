package com.project.model;

public class Vehicle {

    private int id;
    private String licensePlate;
    private String type;
    private int capacity;
    private String status;

    // Constructor for creating new vehicles
    public Vehicle(String licensePlate, String type, int capacity, String status) {
        this.licensePlate = licensePlate;
        this.type = type;
        this.capacity = capacity;
        this.status = status;
    }

    // Constructor for existing vehicles (with ID)
    public Vehicle(int id, String licensePlate, String type, int capacity, String status) {
        this.id = id;
        this.licensePlate = licensePlate;
        this.type = type;
        this.capacity = capacity;
        this.status = status;
    }

    // Getters and Setters
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getLicensePlate() {
        return licensePlate;
    }

    public void setLicensePlate(String licensePlate) {
        this.licensePlate = licensePlate;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public int getCapacity() {
        return capacity;
    }

    public void setCapacity(int capacity) {
        this.capacity = capacity;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }
}
