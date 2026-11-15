# Portfolio 1 — Database Design and Modelling

## Case study

The case study is a simulated outpatient clinic. Receptionists use the database to find available slots, book appointments, and record cancellations. Clinicians use it to view their schedules and record completed visits. Clinic managers use appointment and visit records to review booking activity. All patient and clinician details in this exercise are fictional.

The main design requirement was to let the clinic reuse a slot after a cancellation while keeping the original appointment in its history. The system therefore stores the clinician’s time slot and the patient’s booking as separate records.

## Tables and relationships

- **Patient (`patient`).** The primary key is `patient_id`. A patient can have several appointments. The patient's name is stored once in the patient record.
- **Clinician (`clinician`).** The primary key is `clinician_id`. A clinician can offer several slots. The clinician's name and specialty are stored in this table.
- **Appointment slot (`appointment_slot`).** The primary key is `slot_id`. The `clinician_id` foreign key identifies the clinician offering the slot. Each slot has a start time and an end time. Several appointment records can refer to the same slot over its booking history.
- **Appointment (`appointment`).** The primary key is `appointment_id`. The `patient_id` and `slot_id` foreign keys identify who booked the appointment and which slot they booked. The status records whether the appointment is booked, cancelled, or completed.
- **Visit (`visit`).** The primary key is `visit_id`. Each visit belongs to one completed appointment. The `appointment_id` is unique in this table, so an appointment can have at most one visit.

## Rules enforced in PostgreSQL

- **A slot must end after it starts.** A check constraint rejects an end time that is equal to or earlier than the start time.
- **Every appointment has a valid status.** A check constraint limits the allowed values to `booked`, `cancelled`, and `completed`. A new appointment defaults to `booked`.
- **A slot can have at most one uncancelled appointment.** A partial unique index applies to booked and completed appointments. When a booking is cancelled, its record remains in the history and the slot can be booked again.
- **Only a completed appointment can have a visit.** A composite foreign key checks the appointment ID and its status together. The generated `required_appointment_status` column supplies the value `completed` for this check. It is an implementation detail in the SQL schema.

## Verification in pgAdmin

I booked Patient A into slot 1, cancelled the appointment, and booked Patient B into the same slot. After marking Patient B’s appointment as completed, I created visit 1. The booking-history query returned both appointments for slot 1. Patient A’s booking was cancelled and had no visit ID. Patient B’s booking was completed and linked to visit 1.

I also tested two actions that the database should reject.

- Recording a visit for Patient A’s cancelled appointment triggered the foreign-key rule that requires a completed appointment.
- Attempting another booking in slot 1 triggered the partial unique index because Patient B’s completed appointment already occupied that slot.

The booking history and both rejected operations are shown in evidence screenshots 06–08.

## Normalisation

The logical model follows third normal form under the stated clinic rules. Each table stores facts about the entity identified by its key. For example, the clinician’s name and specialty depend on `clinician_id`, and the scheduled start and end times depend on `slot_id`. Appointment records reference the patient and slot through foreign keys, so the same names and schedule details do not have to be copied into each booking.

This separation also helps keep updates consistent. Correcting a clinician’s name takes one update in `clinician`. Appointments can still retrieve the corrected name through their linked slots, and the booking history remains intact.