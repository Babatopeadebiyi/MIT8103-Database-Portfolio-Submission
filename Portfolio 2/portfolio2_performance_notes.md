# Portfolio 2 — Query Processing and Optimisation

The test used 20,000 synthetic bookings plus the two bookings from Portfolio 1. The query retrieved one week of appointments for clinician 1. I captured execution plans in PostgreSQL 18 using `EXPLAIN (ANALYZE, BUFFERS)` before and after adding `idx_slot_clinician_start` on `appointment_slot (clinician_id, starts_at)`.

| Measure | Before indexing | After indexing |
|---|---:|---:|
| Matching appointments | 70 | 70 |
| Scan on `appointment_slot` | Sequential scan | Index scan |
| Scan on `appointment` | Sequential scan | Sequential scan |
| Execution time | 3.441 ms | 2.896 ms |

Before indexing, PostgreSQL scanned the slot table and filtered out 19,931 rows. After indexing, it used the clinician and date range as index conditions to find the 70 matching slots. The plan still scanned the 20,002 appointment rows, used a hash join, and sorted the result by start time.

Execution time fell by 0.545 ms, or 15.8%, in the two recorded executions. These are single-run timings on a synthetic dataset, so the percentage describes this comparison. The plan shows exactly where the access method changed.

Evidence: before-index plan (02), after-index plan (03), and the 70-row query result (04).
