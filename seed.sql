-- Seed data for Campus Vehicle Booking project
-- Run this after schema.sql

USE campus_vehicle_booking;


-- Passwords used below before SHA-256 hashing:
-- admin123, student123, lecturer123, staff123
INSERT INTO users (name, email, passwordHash, role, phone, isActive) VALUES
  ('Admin', 'admin@umt.edu.my', '240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', 'ADMIN', '012-9000001', 1),
  ('Student', 'student@umt.edu.my', '703b0a3d6ad75b649a28adde7d83c6251da457549263bc7ff45ec709b0a8448b', 'STUDENT', '012-1111111', 1),
  ('Lecturer', 'lecturer@umt.edu.my', 'a4c3fcb625ccf255765afd5e3548839e8a2de6c587d7125dfba735dda69dbe22', 'LECTURER', '012-3333333', 1),
  ('Staff', 'staff@umt.edu.my', '10176e7b7b24d317acfcf8d2064cfd2f24e154f7b5a96603077d5ef813d6a6b6', 'STAFF', '012-4444444', 1);

INSERT INTO vehicles (license_plate, type, capacity, status) VALUES
  ('TBA1001', 'VAN', 8, 'AVAILABLE'),
  ('TBB2002', 'MPV', 6, 'AVAILABLE'),
  ('TBC3003', 'BUS', 30, 'MAINTENANCE'),
  ('TBD4004', 'FOUR_BY_FOUR', 5, 'AVAILABLE'),
  ('TBE5005', 'VAN', 10, 'UNAVAILABLE');

INSERT INTO bookings (
  request_code,
  user_id,
  trip_date,
  return_date,
  destination,
  passenger_count,
  vehicle_type,
  purpose,
  status
) VALUES
  ('BK-20260501-001', 1, '2026-05-22', '2026-05-22', 'UMT Main Campus', 6, 'VAN', 'Faculty meeting transport', 'PENDING'),
  ('BK-20260501-002', 2, '2026-05-24', '2026-05-25', 'Kuala Nerus District Office', 10, 'MPV', 'Student leadership program', 'APPROVED'),
  ('BK-20260501-003', 3, '2026-05-26', '2026-05-27', 'Kuala Terengganu City Hall', 18, 'BUS', 'Community outreach event', 'PENDING'),
  ('BK-20260501-004', 1, '2026-05-18', '2026-05-18', 'UMT Marine Lab', 4, 'FOUR_BY_FOUR', 'Equipment site visit', 'CANCELLED'),
  ('BK-20260501-005', 4, '2026-05-29', '2026-06-01', 'Universiti Malaya, Kuala Lumpur', 20, 'BUS', 'Inter-university competition', 'APPROVED'),
  ('BK-20260501-006', 2, '2026-06-03', '2026-06-04', 'Kenyir Field Station', 7, 'VAN', 'Research sampling trip', 'REJECTED'),
  ('BK-20260501-007', 2, '2026-06-06', '2026-06-06', 'Terengganu State Library', 5, 'MPV', 'Academic resources visit', 'PENDING'),
  ('BK-20260501-008', 3, '2026-06-10', '2026-06-11', 'Sultan Mahmud Airport', 8, 'VAN', 'Guest lecturer pickup', 'COMPLETED');

INSERT INTO handover_records (booking_id, admin_id, pass_code) VALUES
  (2, 1, 'PASS-APRV0002'),
  (5, 1, 'PASS-APRV0005'),
  (8, 1, 'PASS-APRV0008');
