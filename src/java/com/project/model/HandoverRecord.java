package com.project.model;

import java.time.LocalDateTime;

public class HandoverRecord {
    private Long id;
    private Long bookingId;
    private String adminId;
    private String passCode;
    private LocalDateTime generatedAt;

    public HandoverRecord() {}

    public HandoverRecord(Long bookingId, String adminId, String passCode) {
        this.bookingId = bookingId;
        this.adminId = adminId;
        this.passCode = passCode;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    
    public Long getBookingId() { return bookingId; }
    public void setBookingId(Long bookingId) { this.bookingId = bookingId; }
    
    public String getAdminId() { return adminId; }
    public void setAdminId(String adminId) { this.adminId = adminId; }
    
    public String getPassCode() { return passCode; }
    public void setPassCode(String passCode) { this.passCode = passCode; }
    
    public LocalDateTime getGeneratedAt() { return generatedAt; }
    public void setGeneratedAt(LocalDateTime generatedAt) { this.generatedAt = generatedAt; }
}