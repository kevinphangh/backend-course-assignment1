# Database Design Reasoning for Experience Share App

## Core Design Principle
The database uses a relational model in Third Normal Form (3NF) to support group travel organization, individual booking responsibilities, and volume-based discounts.

## Entity Structure and Relationships

### Provider and Guest Entities
*   **Provider:** Stores business partners. Fields include Name, Address, Phone, and CVR (the Danish business registration number), as required.
*   **Guest:** Represents platform users. Fields include Name, Age (with a `CHECK` constraint for ≥18), Phone, and PersonalID (with a `UNIQUE` constraint). The age constraint enforces the application's adult-only requirement.

### Experience and Pricing
*   **Experience:** Links to a `Provider` via a foreign key with `CASCADE DELETE`. The `Price` field is `DECIMAL(10,2)` per assignment requirements for Transact-SQL. A `CHECK` constraint ensures `Price` is non-negative. `Description` is the only nullable field.

### Group Event Architecture
*   **SharedExperience:** Models group events organized by users, fulfilling Star's requirement. It contains Name, Date, and an `OrganizerID` foreign key referencing the `Guest` table.
*   **SharedExperienceItem:** A junction table enabling the many-to-many relationship between `SharedExperience` and `Experience`. A composite `UNIQUE` constraint on `(SharedExperienceID, ExperienceID)` prevents adding the same experience to an event multiple times.
*   **Booking:** Connects a `Guest` to an experience within a shared event by referencing `SharedExperienceItem`. A `UNIQUE` constraint on `(GuestID, SharedExperienceItemID)` prevents duplicate bookings. The `BookingDate` field defaults to `GETDATE()` for timestamping.

### Discount Implementation
*   **Discount:** Implements Noah's volume discount requirement. It contains `MinGuests` and `DiscountPercentage` fields, both with `CHECK` constraints. Allowing multiple discount rows per provider enables tiered pricing (e.g., 10% for 10 guests, 20% for 50).

## Key Design Decisions

### Three-Level Booking Structure
The `SharedExperience` → `SharedExperienceItem` → `Booking` structure is used instead of a direct Guest-Experience link. This model captures the necessary context for queries 4-6 (e.g., guests per experience *within a specific event*) and fulfills Star's requirement for group travel with individual booking responsibility.

### Referential Integrity
`CASCADE DELETE` is used on foreign keys to maintain referential integrity and prevent orphaned records. For example, deleting a provider also removes their associated experiences and bookings.

### Indexing Strategy
Indexes are created on all foreign key columns to optimize `JOIN` performance for the required queries. Primary keys use `IDENTITY(1,1)` to create clustered indexes.

## Query Support Verification

The schema directly supports all required queries:
1.  **Provider data:** `SELECT` from the `Provider` table.
2.  **Experience list:** `SELECT` from the `Experience` table.
3.  **Shared experiences by date:** `SELECT` from `SharedExperience` with `ORDER BY Date DESC`.
4.  **Guests per shared experience:** `JOIN` through `Booking` → `SharedExperienceItem` → `SharedExperience`.
5.  **Experiences in shared experience:** `JOIN` through `SharedExperienceItem`.
6.  **Guests per specific experience in a shared experience:** Full `JOIN` chain with a filter.
7.  **Price statistics:** Aggregate functions on `Experience.Price`.
8.  **Guest counts and sales:** `COUNT` and `SUM` aggregates with `LEFT JOINs`.
9.  **Discount thresholds:** `JOIN` between `Provider` and `Discount`.
10. **Applicable discounts:** Complex query utilizing the indexed relationships.

## Normalization Compliance

The schema achieves 3NF:
*   **1NF:** All fields contain atomic values.
*   **2NF:** No partial dependencies exist.
*   **3NF:** No transitive dependencies exist.

Calculated values (e.g., total sales) are computed at query time to prevent update anomalies.

## Conclusion

This design implements the requirements from Zoe (provider/guest data), Noah (volume discounts), and Star (group organization with individual bookings). The normalized structure ensures data integrity and supports the query performance needed for all specified operations.