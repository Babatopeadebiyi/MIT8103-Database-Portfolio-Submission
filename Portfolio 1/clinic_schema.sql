-- MIT 8103 Portfolio 1: Simulated outpatient clinic
-- Run once in a fresh PostgreSQL database. This script creates the schema only.

BEGIN;

CREATE TABLE patient (
    patient_id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    full_name text NOT NULL
);

CREATE TABLE clinician (
    clinician_id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    full_name text NOT NULL,
    specialty text NOT NULL
);

CREATE TABLE appointment_slot (
    slot_id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    clinician_id integer NOT NULL REFERENCES clinician (clinician_id),
    starts_at timestamptz NOT NULL,
    ends_at timestamptz NOT NULL,
    CONSTRAINT slot_end_after_start CHECK (ends_at > starts_at)
);

CREATE TABLE appointment (
    appointment_id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    patient_id integer NOT NULL REFERENCES patient (patient_id),
    slot_id integer NOT NULL REFERENCES appointment_slot (slot_id),
    status text NOT NULL DEFAULT 'booked',
    CONSTRAINT valid_appointment_status
        CHECK (status IN ('booked', 'cancelled', 'completed')),
    -- The visit's composite foreign key references this pair.
    CONSTRAINT appointment_id_status_unique UNIQUE (appointment_id, status)
);

-- Cancelled appointments remain in the booking history.
CREATE UNIQUE INDEX one_uncancelled_appointment_per_slot
    ON appointment (slot_id)
    WHERE status <> 'cancelled';

CREATE TABLE visit (
    visit_id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    appointment_id integer NOT NULL UNIQUE,
    recorded_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    required_appointment_status text
        GENERATED ALWAYS AS ('completed'::text) STORED,
    CONSTRAINT visit_requires_completed_appointment
        FOREIGN KEY (appointment_id, required_appointment_status)
        REFERENCES appointment (appointment_id, status)
);

COMMIT;
