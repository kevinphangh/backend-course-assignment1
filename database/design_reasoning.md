# Database Design Reasoning for Experience Share App

## Core Design Principle
The database implements a seven-table relational model in Third Normal Form (3NF) that enables group travel organization with individual booking responsibilities and volume-based discounts.

## Entity Structure and Relationships

### Provider and Guest Entities
**Provider** stores business partners with four mandatory fields: Name, Address, Phone, and CVR (Danish business registration number). The CVR field ensures compliance with Danish business requirements as specified.

**Guest** represents platform users with Name, Age (CHECK constraint ≥18 for legal responsibility), Phone, and PersonalID (UNIQUE constraint preventing duplicate registrations). The age restriction implements the adult-only requirement mentioned in the informal specifications.

### Experience and Pricing
**Experience** links to exactly one Provider through a foreign key with CASCADE DELETE. The Price field uses DECIMAL(10,2) as explicitly required by the assignment for Transact-SQL monetary representation. The CHECK constraint (Price ≥ 0) prevents data entry errors. Description is the only nullable field in the schema.

### Group Event Architecture
**SharedExperience** contains Name, Date, and OrganizerID (foreign key to Guest). This represents group events like "Trip to Austria" that Star describes in the requirements.

**SharedExperienceItem** is a junction table with a composite unique constraint on (SharedExperienceID, ExperienceID), preventing duplicate experience additions to a shared event. This enables the many-to-many relationship between shared experiences and available experiences.

**Booking** connects guests to specific experiences within a shared experience by referencing SharedExperienceItem, not Experience directly. The unique constraint on (GuestID, SharedExperienceItemID) prevents double bookings. BookingDate uses GETDATE() default for automatic timestamping.

### Discount Implementation
**Discount** implements Noah's volume discount requirement with MinGuests (CHECK > 0) and DiscountPercentage (DECIMAL(5,2) with CHECK 0-100). Multiple rows per provider enable tiered discounts: 10% at 10 guests, 20% at 50 guests.

## Key Design Decisions

### Three-Level Booking Structure
The path SharedExperience → SharedExperienceItem → Booking (rather than direct Guest-Experience links) captures the context required by queries 4-6: which guests booked which experiences within which shared event. This satisfies Star's requirement that guests "travel as a group" while maintaining "individual responsibilities."

### Referential Integrity
CASCADE DELETE on all foreign keys maintains consistency: deleting a provider removes their experiences, related shared experience items, and bookings automatically. This prevents orphaned records.

### Indexing Strategy
Seven indexes on all foreign key columns optimize the JOIN operations required by the 10 mandatory queries. Primary keys use IDENTITY(1,1) for efficient clustered indexes.

## Query Support Verification

The schema directly supports all required queries:
1. Provider data retrieval - direct SELECT from Provider table
2. Experience listing with prices - direct SELECT from Experience table
3. Shared experiences by date - SELECT from SharedExperience with ORDER BY Date DESC
4. Guests per shared experience - JOIN path through Booking → SharedExperienceItem → SharedExperience
5. Experiences in shared experience - JOIN through SharedExperienceItem
6. Guests per specific experience in shared experience - full JOIN chain with experience name filter
7. Price statistics - aggregate functions on Experience.Price
8. Guest counts and sales - COUNT and SUM with LEFT JOINs to include zero bookings
9. Discount thresholds - JOIN Provider with Discount
10. Applicable discounts - complex query with CTEs using the indexed relationships

## Normalization Compliance

The schema achieves 3NF:
- 1NF: All fields contain atomic values, no repeating groups
- 2NF: No partial dependencies (no composite primary keys with partial dependencies)
- 3NF: No transitive dependencies (each non-key field depends only on the primary key)

No denormalization was introduced. Calculated values (total sales, applicable discounts) are computed at query time to prevent update anomalies.

## Conclusion

This design precisely implements the requirements from Zoe (provider/guest data storage), Noah (volume discounts), and Star (group organization with individual bookings). The normalized structure with comprehensive indexing ensures data integrity while supporting efficient query execution for all specified operations.