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
  CONSTRAINT chk_vehicles_capacity CHECK (capacity > 0),
  CONSTRAINT chk_vehicles_type CHECK (type IN ('SEDAN', 'SUV'))
);

CREATE TABLE IF NOT EXISTS bookings (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  request_code VARCHAR(30) DEFAULT NULL,
  user_id INT UNSIGNED NOT NULL,
  trip_date DATE NOT NULL,
  return_date DATE NOT NULL,
  return_time TIME NOT NULL DEFAULT '17:00:00',
  destination VARCHAR(255) NOT NULL,
  passenger_count INT NOT NULL,
  vehicle_type ENUM('SEDAN', 'SUV') NOT NULL,
  purpose TEXT NOT NULL,
  license_image_path VARCHAR(255) DEFAULT NULL,
  daily_rental_fee DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  late_fee_per_hour DECIMAL(10,2) NOT NULL DEFAULT 25.00,
  estimated_rental_fee DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  assigned_vehicle_id INT DEFAULT NULL,
  status ENUM('PENDING', 'APPROVED', 'REJECTED', 'COMPLETED', 'CANCELLED') NOT NULL DEFAULT 'PENDING',
  rejection_reason TEXT DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_bookings_request_code (request_code),
  KEY idx_bookings_user_id (user_id),
  KEY idx_bookings_user_created_at (user_id, created_at, id),
  KEY idx_bookings_user_status (user_id, status),
  KEY idx_bookings_assigned_vehicle_id (assigned_vehicle_id),
  KEY idx_bookings_status (status),
  KEY idx_bookings_created_at (created_at),
  CONSTRAINT fk_bookings_user
    FOREIGN KEY (user_id) REFERENCES users(userId)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT fk_bookings_assigned_vehicle
    FOREIGN KEY (assigned_vehicle_id) REFERENCES vehicles(id)
    ON DELETE SET NULL
    ON UPDATE CASCADE,
  CONSTRAINT chk_bookings_passenger_count CHECK (passenger_count > 0),
  CONSTRAINT chk_bookings_return_after_trip CHECK (return_date >= trip_date),
  CONSTRAINT chk_bookings_return_time_window CHECK (return_time >= '08:00:00' AND return_time <= '22:00:00'),
  CONSTRAINT chk_bookings_fees_non_negative CHECK (
    daily_rental_fee >= 0 AND late_fee_per_hour >= 0 AND estimated_rental_fee >= 0
  )
);

CREATE TABLE IF NOT EXISTS payments (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  booking_id BIGINT UNSIGNED NOT NULL,
  payer_user_id INT UNSIGNED NOT NULL,
  payment_method ENUM('CARD', 'ONLINE_BANKING', 'EWALLET') NOT NULL,
  amount_paid DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  payment_status ENUM('PENDING', 'PAID', 'FAILED', 'REFUNDED') NOT NULL DEFAULT 'PENDING',
  transaction_reference VARCHAR(50) NOT NULL,
  payer_name VARCHAR(120) NOT NULL,
  payer_email VARCHAR(190) NOT NULL,
  billing_address TEXT DEFAULT NULL,
  paid_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_payments_booking_id (booking_id),
  UNIQUE KEY uk_payments_transaction_reference (transaction_reference),
  KEY idx_payments_payer_user_id (payer_user_id),
  KEY idx_payments_status (payment_status),
  KEY idx_payments_paid_at (paid_at),
  CONSTRAINT fk_payments_booking
    FOREIGN KEY (booking_id) REFERENCES bookings(id)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT fk_payments_payer_user
    FOREIGN KEY (payer_user_id) REFERENCES users(userId)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,
  CONSTRAINT chk_payments_amount_non_negative CHECK (amount_paid >= 0)
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

-- Sample data
-- Insert reference users first so subsequent seed rows can safely resolve foreign keys.
INSERT IGNORE INTO users (name, email, passwordHash, role, phone, isActive)
VALUES
  ('System Admin', 'admin@umt.edu.my', '240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', 'ADMIN', NULL, 1),
  ('Transport Staff', 'staff@umt.edu.my', '10176e7b7b24d317acfcf8d2064cfd2f24e154f7b5a96603077d5ef813d6a6b6', 'STAFF', NULL, 1),
  ('Default Student', 'student@umt.edu.my', '703b0a3d6ad75b649a28adde7d83c6251da457549263bc7ff45ec709b0a8448b', 'STUDENT', NULL, 1),
  ('Campus Lecturer', 'lecturer@umt.edu.my', '703b0a3d6ad75b649a28adde7d83c6251da457549263bc7ff45ec709b0a8448b', 'LECTURER', NULL, 1);

INSERT IGNORE INTO vehicles (license_plate, type, capacity, status)
VALUES
  ('TBY1234', 'SEDAN', 4, 'UNAVAILABLE'),
  ('TBY5678', 'SUV', 7, 'AVAILABLE'),
  ('TBY9012', 'SEDAN', 4, 'AVAILABLE'),
  ('TBY3456', 'SUV', 7, 'AVAILABLE');

INSERT IGNORE INTO bookings (
  request_code, user_id, trip_date, return_date, return_time, destination, passenger_count,
  vehicle_type, purpose, license_image_path, daily_rental_fee, late_fee_per_hour, estimated_rental_fee,
  assigned_vehicle_id, status
)
SELECT
  'BR-20260609-090500-101',
  u.userId,
  '2026-06-12',
  '2026-06-14',
  '22:00:00',
  'Kuala Terengganu City Center',
  4,
  'SEDAN',
  'Official student society visit',
  '/assets/uploads/licenses/sample-matrix-card-1.jpg',
  80.00,
  25.00,
  240.00,
  v.id,
  'APPROVED'
FROM users u
JOIN vehicles v ON v.license_plate = 'TBY1234'
WHERE u.email = 'student@umt.edu.my'
LIMIT 1;

INSERT IGNORE INTO bookings (
  request_code, user_id, trip_date, return_date, return_time, destination, passenger_count,
  vehicle_type, purpose, license_image_path, daily_rental_fee, late_fee_per_hour, estimated_rental_fee,
  assigned_vehicle_id, status
)
SELECT
  'BR-20260609-091000-102',
  u.userId,
  '2026-06-18',
  '2026-06-19',
  '22:00:00',
  'Besut District Office',
  7,
  'SUV',
  'Faculty trip',
  '/assets/uploads/licenses/sample-matrix-card-2.jpg',
  130.00,
  25.00,
  260.00,
  NULL,
  'PENDING'
FROM users u
WHERE u.email = 'student@umt.edu.my'
LIMIT 1;

INSERT IGNORE INTO bookings (
  request_code, user_id, trip_date, return_date, return_time, destination, passenger_count,
  vehicle_type, purpose, license_image_path, daily_rental_fee, late_fee_per_hour, estimated_rental_fee,
  assigned_vehicle_id, status
)
SELECT
  'BR-20260609-091500-103',
  u.userId,
  '2026-05-01',
  '2026-05-02',
  '22:00:00',
  'Dungun Field Visit',
  4,
  'SEDAN',
  'Completed department fieldwork',
  '/assets/uploads/licenses/sample-matrix-card-3.jpg',
  80.00,
  25.00,
  160.00,
  v.id,
  'COMPLETED'
FROM users u
JOIN vehicles v ON v.license_plate = 'TBY9012'
WHERE u.email = 'student@umt.edu.my'
LIMIT 1;

INSERT IGNORE INTO bookings (
  request_code, user_id, trip_date, return_date, return_time, destination, passenger_count,
  vehicle_type, purpose, license_image_path, daily_rental_fee, late_fee_per_hour, estimated_rental_fee,
  assigned_vehicle_id, status, rejection_reason
)
SELECT
  'BR-20260609-092000-104',
  u.userId,
  '2026-06-20',
  '2026-06-20',
  '18:00:00',
  'Marang District Office',
  3,
  'SUV',
  'Lecture committee visit',
  '/assets/uploads/licenses/sample-matrix-card-4.jpg',
  130.00,
  25.00,
  130.00,
  NULL,
  'REJECTED',
  'Insufficient supporting documents'
FROM users u
WHERE u.email = 'lecturer@umt.edu.my'
LIMIT 1;

INSERT IGNORE INTO bookings (
  request_code, user_id, trip_date, return_date, return_time, destination, passenger_count,
  vehicle_type, purpose, license_image_path, daily_rental_fee, late_fee_per_hour, estimated_rental_fee,
  assigned_vehicle_id, status
)
SELECT
  'BR-20260609-092500-105',
  u.userId,
  '2026-06-22',
  '2026-06-23',
  '20:00:00',
  'Kenyir Lake Research Site',
  5,
  'SUV',
  'Student research trip',
  '/assets/uploads/licenses/sample-matrix-card-5.jpg',
  130.00,
  25.00,
  260.00,
  NULL,
  'CANCELLED'
FROM users u
WHERE u.email = 'student@umt.edu.my'
LIMIT 1;

INSERT IGNORE INTO handover_records (booking_id, admin_id, pass_code)
SELECT b.id, a.userId, 'PASS-DEMO-001'
FROM bookings b
JOIN users a ON a.email = 'staff@umt.edu.my'
WHERE b.request_code = 'BR-20260609-090500-101'
LIMIT 1;

INSERT IGNORE INTO handover_records (booking_id, admin_id, pass_code)
SELECT b.id, a.userId, 'PASS-DEMO-002'
FROM bookings b
JOIN users a ON a.email = 'staff@umt.edu.my'
WHERE b.request_code = 'BR-20260609-091500-103'
LIMIT 1;

INSERT IGNORE INTO payments (
  booking_id, payer_user_id, payment_method, amount_paid, payment_status, transaction_reference,
  payer_name, payer_email, billing_address, paid_at
)
SELECT
  b.id,
  u.userId,
  'CARD',
  b.estimated_rental_fee,
  'PAID',
  'TXN-DEMO-0001',
  u.name,
  u.email,
  'University Malaysia Terengganu, Kuala Nerus, Terengganu',
  NOW()
FROM bookings b
JOIN users u ON u.email = 'student@umt.edu.my'
WHERE b.request_code = 'BR-20260609-090500-101'
LIMIT 1;

INSERT IGNORE INTO payments (
  booking_id, payer_user_id, payment_method, amount_paid, payment_status, transaction_reference,
  payer_name, payer_email, billing_address, paid_at
)
SELECT
  b.id,
  u.userId,
  'ONLINE_BANKING',
  b.estimated_rental_fee,
  'PAID',
  'TXN-DEMO-0002',
  u.name,
  u.email,
  'University Malaysia Terengganu, Kuala Nerus, Terengganu',
  NOW()
FROM bookings b
JOIN users u ON u.email = 'student@umt.edu.my'
WHERE b.request_code = 'BR-20260609-091500-103'
LIMIT 1;

INSERT IGNORE INTO payments (
  booking_id, payer_user_id, payment_method, amount_paid, payment_status, transaction_reference,
  payer_name, payer_email, billing_address, paid_at
)
SELECT
  b.id,
  u.userId,
  'EWALLET',
  0.00,
  'PENDING',
  'TXN-DEMO-0003',
  u.name,
  u.email,
  'University Malaysia Terengganu, Kuala Nerus, Terengganu',
  NULL
FROM bookings b
JOIN users u ON u.email = 'student@umt.edu.my'
WHERE b.request_code = 'BR-20260609-091000-102'
LIMIT 1;

-- Legacy migration helpers
-- Use these if you already have an older database that still contains the previous vehicle labels.
UPDATE vehicles
SET type = CASE
  WHEN UPPER(type) IN ('COMPACT_CAR', 'NORMAL_CAR', 'SEDAN', 'VAN') THEN 'SEDAN'
  WHEN UPPER(type) IN ('MPV', 'LARGE_CAR', 'SUV', 'BUS', 'FOUR_BY_FOUR') THEN 'SUV'
  ELSE type
END
WHERE UPPER(type) IN ('COMPACT_CAR', 'NORMAL_CAR', 'SEDAN', 'VAN', 'MPV', 'LARGE_CAR', 'SUV', 'BUS', 'FOUR_BY_FOUR');

UPDATE bookings
SET vehicle_type = CASE
  WHEN UPPER(vehicle_type) IN ('COMPACT_CAR', 'NORMAL_CAR', 'SEDAN', 'VAN') THEN 'SEDAN'
  WHEN UPPER(vehicle_type) IN ('MPV', 'LARGE_CAR', 'SUV', 'BUS', 'FOUR_BY_FOUR') THEN 'SUV'
  ELSE vehicle_type
END
WHERE UPPER(vehicle_type) IN ('COMPACT_CAR', 'NORMAL_CAR', 'SEDAN', 'VAN', 'MPV', 'LARGE_CAR', 'SUV', 'BUS', 'FOUR_BY_FOUR');
