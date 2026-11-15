-- Run in clinic_portfolio after Portfolio 1, with clinician 1 and patient 1 present.
-- Run the numbered blocks separately. Run the data load once only.
-- Capture the baseline before creating idx_slot_clinician_start.

-- 1. Generate 20,000 fictional bookings.
WITH new_slots AS (
    INSERT INTO appointment_slot (clinician_id, starts_at, ends_at)
    SELECT 1, slot_start, slot_start + INTERVAL '30 minutes'
    FROM (
        SELECT (
            TIMESTAMP '2030-01-01 09:00:00'
            + day_offset * INTERVAL '1 day'
            + slot_offset * INTERVAL '30 minutes'
        ) AT TIME ZONE 'America/Edmonton' AS slot_start
        FROM generate_series(0, 1999) AS days(day_offset)
        CROSS JOIN generate_series(0, 9) AS slots(slot_offset)
    ) AS schedule
    RETURNING slot_id
),
new_bookings AS (
    INSERT INTO appointment (patient_id, slot_id)
    SELECT 1, slot_id
    FROM new_slots
    RETURNING appointment_id
)
SELECT COUNT(*) AS test_bookings_created
FROM new_bookings;

-- 2. Update planner statistics, then capture the before-index plan.
ANALYZE appointment_slot;
ANALYZE appointment;

EXPLAIN (ANALYZE, BUFFERS)
SELECT a.appointment_id, a.patient_id, s.starts_at, a.status
FROM appointment_slot AS s
JOIN appointment AS a ON a.slot_id = s.slot_id
WHERE s.clinician_id = 1
  AND s.starts_at >= TIMESTAMPTZ '2030-01-01 00:00:00-07'
  AND s.starts_at <  TIMESTAMPTZ '2030-01-08 00:00:00-07'
ORDER BY s.starts_at;

-- 3. Create the index.
CREATE INDEX idx_slot_clinician_start
    ON appointment_slot (clinician_id, starts_at);

-- 4. Capture the after-index plan using the same query.
EXPLAIN (ANALYZE, BUFFERS)
SELECT a.appointment_id, a.patient_id, s.starts_at, a.status
FROM appointment_slot AS s
JOIN appointment AS a ON a.slot_id = s.slot_id
WHERE s.clinician_id = 1
  AND s.starts_at >= TIMESTAMPTZ '2030-01-01 00:00:00-07'
  AND s.starts_at <  TIMESTAMPTZ '2030-01-08 00:00:00-07'
ORDER BY s.starts_at;

-- 5. Display the 70 matching appointments.
SELECT a.appointment_id, a.patient_id, s.starts_at, a.status
FROM appointment_slot AS s
JOIN appointment AS a ON a.slot_id = s.slot_id
WHERE s.clinician_id = 1
  AND s.starts_at >= TIMESTAMPTZ '2030-01-01 00:00:00-07'
  AND s.starts_at <  TIMESTAMPTZ '2030-01-08 00:00:00-07'
ORDER BY s.starts_at;
