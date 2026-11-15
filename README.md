# MIT 8103 — Advanced Database Portfolio

**Author**  
Babatope Oluwadamilare Adebiyi

This portfolio uses a simulated outpatient clinic to demonstrate database design, query optimisation, transaction handling, NoSQL modelling, and distributed database design. All clinic data are fictional.

## Portfolio contents

1. [Portfolio 1 — Database Design and Modelling](./Portfolio%201/)  
   PostgreSQL schema and ER diagram for clinician schedules, appointment bookings, and completed visits.

2. [Portfolio 2 — Query Processing and Optimisation](./Portfolio%202/)  
   Before-and-after execution plans for a weekly appointment query using 20,000 synthetic test bookings.

3. [Portfolio 3 — Transactions and Concurrency](./Portfolio%203/)  
   Commit and rollback tests, plus a two-session test showing how PostgreSQL prevents double-booking.

4. [Portfolio 4 — NoSQL and Advanced Data Models](./Portfolio%204/)  
   A MongoDB document model for completed visits, with sample inserts and a patient visit-history query.

5. [Portfolio 5 — Distributed and Cloud Database Design](./Portfolio%205/)  
   A proposed PostgreSQL primary and read-replica architecture, with a diagram and discussion of replica lag and failover.

For the two-session concurrency test, see Portfolio 3’s transaction notes and screenshots 03–07, which show the competing booking waiting, being rejected, and leaving one confirmed booking.
