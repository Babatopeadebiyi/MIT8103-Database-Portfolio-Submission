# Portfolio 3 — Transactions and Concurrency

I used three slots in the simulated clinic database to test whether PostgreSQL saves a committed booking, undoes a rolled-back booking, and prevents double-booking across two sessions.

| Test | Observed result | Screenshot |
|---|---|---|
| Commit on slot 20002 | The query after `COMMIT` returned appointment 20004 for patient 1, with status `booked`. | 01 |
| Rollback on slot 20003 | The query after `ROLLBACK` returned a booking count of zero. | 02 |
| Concurrent booking on slot 20004 | Session B waited for Session A, then received duplicate-key error `23505`. The final query returned only appointment 20006 for patient 1. | 03–07 |

Session A inserted a booking in a `READ COMMITTED` transaction and left it open. Session B's first query returned zero bookings for that slot because Session A had not committed. When Session B tried to book the same slot for patient 2, its insert waited. After Session A committed, PostgreSQL rejected the second insert through the partial unique index `one_uncancelled_appointment_per_slot`. Session B could then see the committed booking in its final query.

Read Committed controls which rows a query can see. The unique index enforces the booking rule across concurrent writes. In this test, a slot that appeared empty to Session B was already being booked by Session A.
