-- Seed data for Campus Vehicle Booking project
-- Run this after schema.sql

USE campus_vehicle_booking;

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
  ('BK-20260401-001', 1001, '2026-04-22', '2026-04-22', 'UMT Main Campus', 6, 'VAN', 'Faculty meeting transport', 'PENDING'),
  ('BK-20260401-002', 1002, '2026-04-24', '2026-04-25', 'Kuala Nerus District Office', 10, 'MPV', 'Student leadership program', 'APPROVED'),
  ('BK-20260401-003', 1003, '2026-04-26', '2026-04-27', 'Kuala Terengganu City Hall', 18, 'BUS', 'Community outreach event', 'PENDING'),
  ('BK-20260401-004', 1001, '2026-04-18', '2026-04-18', 'UMT Marine Lab', 4, 'FOUR_BY_FOUR', 'Equipment site visit', 'CANCELLED'),
  ('BK-20260401-005', 1004, '2026-04-29', '2026-05-01', 'Universiti Malaya, Kuala Lumpur', 20, 'BUS', 'Inter-university competition', 'APPROVED'),
  ('BK-20260401-006', 1005, '2026-05-03', '2026-05-04', 'Kenyir Field Station', 7, 'VAN', 'Research sampling trip', 'REJECTED'),
  ('BK-20260401-007', 1002, '2026-05-06', '2026-05-06', 'Terengganu State Library', 5, 'MPV', 'Academic resources visit', 'PENDING'),
  ('BK-20260401-008', 1006, '2026-05-10', '2026-05-11', 'Sultan Mahmud Airport', 8, 'VAN', 'Guest lecturer pickup', 'APPROVED');
