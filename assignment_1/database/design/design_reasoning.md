# Database Design Reasoning for Experience Share App

## Core Design Principle
I went with a relational model in Third Normal Form (3NF) since I need to handle group travel organization, individual booking responsibilities, and volume-based discounts. SQL Server made sense here given the requirements.

## Entity Structure and Relationships

### Provider and Guest Entities
For Provider I'm storing the business partners with their Name, Address, Phone, and CVR (that's the Danish business registration number the assignment requires). Pretty standard stuff.

The Guest table is for platform users - got Name, Age (with a CHECK constraint for 18+), Phone, and PersonalID (UNIQUE constraint on this one). Had to enforce the adult-only requirement from the specs, hence the age check.

### Experience and Pricing
Each Experience is tied to a Provider through a foreign key with CASCADE DELETE. Price is DECIMAL(10,2) because the assignment specifically wants Transact-SQL compatibility. Added a CHECK constraint so Price can't go negative. Description is nullable since not every experience needs one.

### Group Event Architecture
SharedExperience is where I model the group events that users organize (this was Star's main requirement). Each one has a Name, Date, and OrganizerID that points back to the Guest table.

Now here's where it gets interesting - SharedExperienceItem works as a junction table between SharedExperience and Experience. I put a composite UNIQUE on (SharedExperienceID, ExperienceID) so you can't accidentally add the same experience twice to an event.

The Booking table is what actually connects a Guest to an experience in a shared event. It references SharedExperienceItem and has its own UNIQUE constraint on (GuestID, SharedExperienceItemID) to prevent double bookings. BookingDate defaults to GETDATE() for tracking when bookings happen.

### Discount Implementation
Noah wanted volume discounts, so I built the Discount table with MinGuests and DiscountPercentage fields (both have CHECK constraints). A provider can have multiple discount tiers - like 10% off for 10+ guests, 20% for 50+, that kind of thing.

## Key Design Decisions

### Three-Level Booking Structure
I could have just linked guests directly to experiences, but that wouldn't give me the context I need. The SharedExperience to SharedExperienceItem to Booking flow lets me answer queries like "how many guests booked this specific experience in this specific event" (queries 4-6 need this). Plus it handles Star's requirement about group travel where individuals book their own stuff.

### Referential Integrity
I'm using CASCADE DELETE on the foreign keys to keep things clean. When you delete a provider, their experiences and related bookings go too. Prevents orphaned records from cluttering things up.

### Indexing Strategy
Put indexes on all the foreign key columns since I'm going to be JOINing on them constantly. Primary keys get IDENTITY(1,1) which gives me clustered indexes automatically.

## Query Support Verification

Here's how the schema handles each required query:
1. Provider data: straight SELECT from Provider
2. Experience list: SELECT from Experience table
3. Shared experiences by date: SELECT from SharedExperience, ORDER BY Date DESC
4. Guests per shared experience: JOIN from Booking through SharedExperienceItem to SharedExperience
5. Experiences in a shared experience: JOIN through SharedExperienceItem
6. Guests for a specific experience in a shared experience: same JOIN chain as #4 but with a filter
7. Price statistics: aggregate functions on Experience.Price
8. Guest counts and sales: COUNT and SUM with LEFT JOINs
9. Discount thresholds: JOIN Provider with Discount
10. Which discounts apply: bit more complex but the indexed relationships handle it

## Normalization Compliance

Got the schema to 3NF:
First normal form - all fields have atomic values.
Second normal form - no partial dependencies floating around.
Third normal form - no transitive dependencies either.

I calculate things like total sales at query time instead of storing them. Prevents update anomalies.

## Conclusion

This setup covers what Zoe needs (provider and guest data), Noah's volume discount feature, and Star's group organization with individual bookings. The normalized structure keeps data integrity solid while giving me the query performance I need for all 10 required operations. Should scale reasonably well too.