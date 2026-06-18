package com.project.model;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.math.BigDecimal;

public class BookingRequest {

    public enum VehicleType {
        SEDAN, SUV
    }

    public enum Status {
        PENDING, APPROVED, REJECTED, COMPLETED, CANCELLED
    }

    private Long id;
    private String requestCode;
    private Long userId;
    private LocalDate tripDate;
    private LocalDate returnDate;
    private LocalTime returnTime;
    private String destination;
    private int passengerCount;
    private VehicleType vehicleType;
    private String purpose;
    private String licenseImagePath;
    private BigDecimal dailyRentalFee;
    private BigDecimal lateFeePerHour;
    private BigDecimal estimatedRentalFee;
    private Long assignedVehicleId;
    private Status status;
    private String rejectionReason;
    private String bookerName;
    private String bookerEmail;
    private String bookerPhone;
    private String bookerRole;
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

    public LocalTime getReturnTime() {
        return returnTime;
    }

    public void setReturnTime(LocalTime returnTime) {
        this.returnTime = returnTime;
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

    public String getLicenseImagePath() {
        return licenseImagePath;
    }

    public void setLicenseImagePath(String licenseImagePath) {
        this.licenseImagePath = licenseImagePath;
    }

    public BigDecimal getDailyRentalFee() {
        return dailyRentalFee;
    }

    public void setDailyRentalFee(BigDecimal dailyRentalFee) {
        this.dailyRentalFee = dailyRentalFee;
    }

    public BigDecimal getLateFeePerHour() {
        return lateFeePerHour;
    }

    public void setLateFeePerHour(BigDecimal lateFeePerHour) {
        this.lateFeePerHour = lateFeePerHour;
    }

    public BigDecimal getEstimatedRentalFee() {
        return estimatedRentalFee;
    }

    public void setEstimatedRentalFee(BigDecimal estimatedRentalFee) {
        this.estimatedRentalFee = estimatedRentalFee;
    }

    public Long getAssignedVehicleId() {
        return assignedVehicleId;
    }

    public void setAssignedVehicleId(Long assignedVehicleId) {
        this.assignedVehicleId = assignedVehicleId;
    }

    public Status getStatus() {
        return status;
    }

    public void setStatus(Status status) {
        this.status = status;
    }

    public String getRejectionReason() {
        return rejectionReason;
    }

    public void setRejectionReason(String rejectionReason) {
        this.rejectionReason = rejectionReason;
    }

    public String getBookerName() {
        return bookerName;
    }

    public void setBookerName(String bookerName) {
        this.bookerName = bookerName;
    }

    public String getBookerEmail() {
        return bookerEmail;
    }

    public void setBookerEmail(String bookerEmail) {
        this.bookerEmail = bookerEmail;
    }

    public String getBookerPhone() {
        return bookerPhone;
    }

    public void setBookerPhone(String bookerPhone) {
        this.bookerPhone = bookerPhone;
    }

    public String getBookerRole() {
        return bookerRole;
    }

    public void setBookerRole(String bookerRole) {
        this.bookerRole = bookerRole;
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
