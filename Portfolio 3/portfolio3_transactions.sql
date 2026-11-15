-- MIT 8103 Portfolio 3: Transactions and Concurrency
-- Run numbered blocks separately in the indicated Query Tool tabs.
-- Reproduce in a fresh practice database with the Portfolio 1 schema,
-- an existing clinician (ID 1) and two patients (IDs 1 and 2).
-- The slot IDs below match the original run. Substitute the actual IDs
-- returned by block 1 if recreating these tests in another database.

-- 1. Setup: create test slots once. The earliest slot is for COMMIT,
-- the middle slot is for ROLLBACK, and the latest is for concurrency.
INSERT INTO appointment_slot (clinician_id, starts_at, ends_at)
VALUES
    (1, '2029-12-03 09:00:00-07', '2029-12-03 09:30:00-07'),
    (1, '2029-12-03 10:00:00-07', '2029-12-03 10:30:00-07'),
    (1, '2029-12-03 11:00:00-07', '2029-12-03 11:30:00-07')
RETURNING slot_id, starts_at AT TIME ZONE 'America/Edmonton' AS clinic_start;

-- 2. COMMIT test: expect one booking after COMMIT.
BEGIN;
INSERT INTO appointment (patient_id, slot_id) VALUES (1, 20002);
COMMIT;

SELECT appointment_id, patient_id, slot_id, status
FROM appointment
WHERE slot_id = 20002;

-- 3. ROLLBACK test: expect zero bookings after ROLLBACK.
BEGIN;
INSERT INTO appointment (patient_id, slot_id) VALUES (1, 20003);
ROLLBACK;

SELECT COUNT(*) AS bookings_after_rollback
FROM appointment
WHERE slot_id = 20003;

-- 4. Session A: insert and leave the transaction open.
BEGIN ISOLATION LEVEL READ COMMITTED;

INSERT INTO appointment (patient_id, slot_id)
VALUES (1, 20004)
RETURNING appointment_id, patient_id, slot_id, status;

-- 5. Session B: use a separate connection with autocommit enabled.
-- Expect zero visible bookings while Session A is uncommitted.
SELECT COUNT(*) AS bookings_visible_in_session_b
FROM appointment
WHERE slot_id = 20004;

-- 6. Session B: run this separately. It should wait for Session A.
INSERT INTO appointment (patient_id, slot_id)
VALUES (2, 20004);

-- 7. Session A: commit while Session B is waiting.
-- Session B's insert should then fail with SQLSTATE 23505.
COMMIT;

-- 8. Session B: expect one row for patient 1.
SELECT appointment_id, patient_id, slot_id, status
FROM appointment
WHERE slot_id = 20004;
