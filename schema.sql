-- Schema for Campus Vehicle Booking project
-- Run in MySQL 8+

CREATE DATABASE IF NOT EXISTS campus_vehicle_booking
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE campus_vehicle_booking;

CREATE TABLE IF NOT EXISTS users (
  userId INT UNSIGNED NOT NULL AUTO_INCREMENT,
  name VARCHAR(120) NOT NULL,
  email VARCHAR(190) NOT NULL,
  passwordHash VARCHAR(255) NOT NULL,
  role VARCHAR(30) NOT NULL,
  phone VARCHAR(30) DEFAULT NULL,
  isActive TINYINT(1) NOT NULL DEFAULT 1,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (userId),
  UNIQUE KEY uk_users_email (email),
  KEY idx_users_role (role),
  KEY idx_users_is_active (isActive)
);

CREATE TABLE IF NOT EXISTS bookings (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  request_code VARCHAR(30) DEFAULT NULL,
  user_id INT UNSIGNED NOT NULL,
  trip_date DATE NOT NULL,
  return_date DATE NOT NULL,
  destination VARCHAR(255) NOT NULL,
  passenger_count INT NOT NULL,
  vehicle_type ENUM('VAN', 'MPV', 'BUS', 'FOUR_BY_FOUR') NOT NULL,
  purpose TEXT NOT NULL,
  status ENUM('PENDING', 'APPROVED', 'REJECTED', 'COMPLETED', 'CANCELLED') NOT NULL DEFAULT 'PENDING',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_bookings_request_code (request_code),
  KEY idx_bookings_user_id (user_id),
  KEY idx_bookings_status (status),
  KEY idx_bookings_created_at (created_at),
  CONSTRAINT fk_bookings_user
    FOREIGN KEY (user_id) REFERENCES users(userId)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT chk_bookings_passenger_count CHECK (passenger_count > 0),
  CONSTRAINT chk_bookings_return_after_trip CHECK (return_date >= trip_date)
);

CREATE TABLE IF NOT EXISTS vehicles (
  id INT NOT NULL AUTO_INCREMENT,
  license_plate VARCHAR(30) NOT NULL,
  type VARCHAR(50) NOT NULL,
  capacity INT NOT NULL,
  status VARCHAR(30) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_vehicles_license_plate (license_plate),
  KEY idx_vehicles_status (status),
  CONSTRAINT chk_vehicles_capacity CHECK (capacity > 0)
);

CREATE TABLE IF NOT EXISTS handover_records (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  booking_id BIGINT UNSIGNED NOT NULL,
  admin_id INT UNSIGNED NOT NULL,
  pass_code VARCHAR(30) NOT NULL,
  generated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_handover_records_booking_id (booking_id),
  UNIQUE KEY uk_handover_records_pass_code (pass_code),
  KEY idx_handover_records_admin_id (admin_id),
  CONSTRAINT fk_handover_records_booking
    FOREIGN KEY (booking_id) REFERENCES bookings(id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT fk_handover_records_admin
    FOREIGN KEY (admin_id) REFERENCES users(userId)
    ON DELETE RESTRICT
    ON UPDATE CASCADE
);
