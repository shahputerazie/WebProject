-- Schema for Campus Vehicle Booking project
-- Run in MySQL 8+

CREATE DATABASE IF NOT EXISTS campus_vehicle_booking
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE campus_vehicle_booking;

CREATE TABLE IF NOT EXISTS bookings (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  request_code VARCHAR(30) DEFAULT NULL,
  user_id BIGINT UNSIGNED NOT NULL,
  trip_date DATE NOT NULL,
  return_date DATE NOT NULL,
  destination VARCHAR(255) NOT NULL,
  passenger_count INT NOT NULL,
  vehicle_type ENUM('VAN', 'MPV', 'BUS', 'FOUR_BY_FOUR') NOT NULL,
  purpose TEXT NOT NULL,
  status ENUM('PENDING', 'APPROVED', 'REJECTED', 'CANCELLED') NOT NULL DEFAULT 'PENDING',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_bookings_request_code (request_code),
  KEY idx_bookings_user_id (user_id),
  KEY idx_bookings_status (status),
  KEY idx_bookings_created_at (created_at),
  CONSTRAINT chk_bookings_passenger_count CHECK (passenger_count > 0),
  CONSTRAINT chk_bookings_return_after_trip CHECK (return_date >= trip_date)
);
