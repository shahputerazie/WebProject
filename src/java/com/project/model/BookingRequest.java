package com.project.model;

import java.time.LocalDate;
import java.time.LocalDateTime;

public class BookingRequest {

    public enum VehicleType {
        VAN, MPV, BUS, FOUR_BY_FOUR
    }

    public enum Status {
        PENDING, APPROVED, REJECTED, CANCELLED
    }

    private Long id;
    private String requestCode;
    private Long userId;
    private LocalDate tripDate;
    private LocalDate returnDate;
    private String destination;
    private int passengerCount;
    private VehicleType vehicleType;
    private String purpose;
    private Status status;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    public BookingRequest() {
    }

    public BookingRequest(LocalDate tripDate, LocalDate returnDate, String destination, int passengerCount,
            VehicleType vehicleType, String purpose, Status status) {
        this.tripDate = tripDate;
        this.returnDate = returnDate;
        this.destination = destination;
        this.passengerCount = passengerCount;
        this.vehicleType = vehicleType;
        this.purpose = purpose;
        this.status = status;
    }

    public BookingRequest(Long id, String requestCode, Long userId, LocalDate tripDate, LocalDate returnDate,
            String destination, int passengerCount, VehicleType vehicleType, String purpose,
            Status status, LocalDateTime createdAt, LocalDateTime updatedAt) {
        this.id = id;
        this.requestCode = requestCode;
        this.userId = userId;
        this.tripDate = tripDate;
        this.returnDate = returnDate;
        this.destination = destination;
        this.passengerCount = passengerCount;
        this.vehicleType = vehicleType;
        this.purpose = purpose;
        this.status = status;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getRequestCode() {
        return requestCode;
    }

    public void setRequestCode(String requestCode) {
        this.requestCode = requestCode;
    }

    public Long getUserId() {
        return userId;
    }

    public void setUserId(Long userId) {
        this.userId = userId;
    }

    public LocalDate getTripDate() {
        return tripDate;
    }

    public void setTripDate(LocalDate tripDate) {
        this.tripDate = tripDate;
    }

    public LocalDate getReturnDate() {
        return returnDate;
    }

    public void setReturnDate(LocalDate returnDate) {
        this.returnDate = returnDate;
    }

    public String getDestination() {
        return destination;
    }

    public void setDestination(String destination) {
        this.destination = destination;
    }

    public int getPassengerCount() {
        return passengerCount;
    }

    public void setPassengerCount(int passengerCount) {
        this.passengerCount = passengerCount;
    }

    public VehicleType getVehicleType() {
        return vehicleType;
    }

    public void setVehicleType(VehicleType vehicleType) {
        this.vehicleType = vehicleType;
    }

    public String getPurpose() {
        return purpose;
    }

    public void setPurpose(String purpose) {
        this.purpose = purpose;
    }

    public Status getStatus() {
        return status;
    }

    public void setStatus(Status status) {
        this.status = status;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }
}
