// Portfolio 4 — MongoDB completed visits
// Run the insert once in an empty completed_visits collection.

const visits = db.getSiblingDB("clinic_nosql").getCollection("completed_visits");

visits.insertMany([
  {
    _id: "visit-001",
    appointment_id: 2,
    patient: { patient_id: 2, name: "Patient B" },
    clinician: { clinician_id: 1, name: "Dr. Sam Reed" },
    visit_type: "Initial consultation",
    visit_date: ISODate("2026-12-01T16:00:00Z")
  },
  {
    _id: "visit-002",
    appointment_id: 101,
    patient: { patient_id: 2, name: "Patient B" },
    clinician: { clinician_id: 1, name: "Dr. Sam Reed" },
    visit_type: "Follow-up",
    visit_date: ISODate("2026-12-15T16:00:00Z")
  },
  {
    _id: "visit-003",
    appointment_id: 102,
    patient: { patient_id: 3, name: "Patient C" },
    clinician: { clinician_id: 1, name: "Dr. Sam Reed" },
    visit_type: "Initial consultation",
    visit_date: ISODate("2026-12-16T17:00:00Z")
  }
]);

printjson(visits.find({ "patient.patient_id": 2 }).sort({ visit_date: 1 }).toArray());