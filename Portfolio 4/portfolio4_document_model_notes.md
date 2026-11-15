# Portfolio 4 — NoSQL and Advanced Data Models

I used MongoDB to model completed visits for the simulated outpatient clinic. The `clinic_nosql.completed_visits` collection stores one document per visit. Each document records the visit ID, appointment ID, visit type, and date, with patient and clinician identifiers and names embedded in two nested objects.

Embedding lets the visit-history query return the clinician and patient details together with the visit in a single collection read. The trade-off is that names repeat across documents. In this design, the embedded names can represent the details at the time of the visit. If reports must show current names, they need to retrieve the current record or refresh the embedded values.

| Test | Observed result | Evidence |
|---|---|---|
| Insert three fictional visits | MongoDB acknowledged the insert and returned `visit-001`, `visit-002`, and `visit-003`. | `01_visits_inserted.png` |
| Find and sort Patient B's completed visits | Filtering by `patient.patient_id = 2` and sorting by `visit_date` returned `visit-001` (Initial consultation) and `visit-002` (Follow-up), in date order. | `02_patient_b_visit_history.png` |

This was a separate synthetic MongoDB dataset. The appointment IDs are sample fields for the document model and were not validated against PostgreSQL. The PostgreSQL database remains the source for the booking and concurrency tests in the earlier portfolios.
