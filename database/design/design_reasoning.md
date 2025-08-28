# Database Design Reasoning

## Design Decisions and Rationale

### Entity Design

**Provider Entity**
- Stores businesses offering services (hotels, airlines, tour operators)
- CVR field ensures unique business identification in Denmark
- Separate from Experience to allow one provider to offer multiple services

**Guest Entity**
- Represents individual users who can organize or join shared experiences
- Age constraint (>=18) ensures legal capacity for bookings
- PersonalID ensures unique identification and prevents duplicate accounts

**Experience Entity**
- Individual services offered by providers (hotel nights, flights, tours)
- Price stored as DECIMAL(10,2) per assignment requirements
- Many-to-one relationship with Provider allows price variations for same provider

**SharedExperience Entity**
- Represents group trips/events that combine multiple experiences
- OrganizerID links to Guest who created the shared experience
- Date field tracks when the shared experience occurs

### Relationship Design

**SharedExperienceItem (Junction Table)**
- Resolves M:N relationship between SharedExperience and Experience
- Allows flexible combination of experiences in shared trips
- Unique constraint prevents duplicate experience additions

**Booking (Junction Table)**
- Resolves M:N relationship between Guest and SharedExperienceItem
- Tracks which guests book which experiences within a shared experience
- Allows selective participation (guests can book some but not all experiences)
- BookingDate for audit trail

**Discount Entity**
- Linked to Provider for volume-based pricing
- Supports multiple discount tiers per provider
- Enables viral marketing through group size incentives

### Key Design Choices

1. **Normalized Structure**: Follows 3NF to minimize redundancy and ensure data integrity

2. **Flexible Booking Model**: Guests book individual experiences within shared experiences rather than entire packages, supporting the "individual responsibility" requirement

3. **Scalable Discount System**: Separate Discount table allows providers to define multiple discount tiers without modifying Experience prices

4. **Audit Capability**: BookingDate in Booking table provides transaction history

5. **Referential Integrity**: Foreign key constraints with appropriate CASCADE options maintain data consistency

### Query Optimization

- Indexes on all foreign keys for efficient joins
- Clustered indexes on primary keys for fast lookups
- Covering indexes for common query patterns

This design supports all required queries efficiently while maintaining flexibility for future enhancements.