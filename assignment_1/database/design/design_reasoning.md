# Database Design Reasoning for Local Food Delivery App

## My Design Approach

When I analyzed the requirements from Zoe, Noah, Star, and Knuth, I realized I needed to design a system that connects three user types: cooks who prepare food, cyclists who deliver it, and customers who order it. I approached this by first identifying the entities from their stories, then determining how these entities relate to each other.

## Core Entity Decisions

I identified nine entities that form the backbone of my database design. I chose to create separate tables for Cook, Cyclist, and Customer rather than a single User table because each has different attributes and business rules. For example, cooks need to store their kitchen address and personal ID for food safety regulations, cyclists need to track their bike type for delivery logistics, and customers need payment options. This separation makes the system clearer and avoids null fields that would occur in a unified user table.

## Handling Food Availability

The challenge was implementing Noah's requirement about time-based availability. I created the Portion entity to represent dishes that cooks make available during time windows. I used the SQL Server TIME datatype for AvailableFrom and AvailableUntil fields because the assignment requires this, and it captures the concept of daily recurring availability windows. Each portion links to one cook through a foreign key, establishing ownership of who prepared what food.

I added a check constraint to ensure AvailableUntil is always after AvailableFrom, which prevents data entry errors where someone might set an invalid time range. The quantity field tracks how many portions are available, which decreases as customers place orders.

## Order Processing Design

I designed the order system with flexibility in mind. An Order belongs to one customer but can contain items from multiple cooks, which I handle through the OrderItem table. This many-to-many relationship between orders and portions allows customers to order pasta from Noah's kitchen and lemonade from Helle's kitchen in the same transaction, as shown in the requirements example.

I stored the price in OrderItem rather than just referencing the Portion price because prices might change over time, but we need to preserve the price that the customer paid. This decision ensures financial records remain accurate.

## Delivery Trip Modeling

For Star's requirements about tracking deliveries, I created a trip system. Each Trip connects one cyclist to one order, recording start time, end time, and earnings. The complexity comes with the TripStop entity, which I designed to handle multiple pickup and delivery locations in a single trip.

I used a StopOrder field to maintain the sequence of stops, and a StopType field to distinguish between pickups and deliveries. This design allows for Star's scenario where she made five deliveries in one neighborhood. The system can track the route with timestamps at each stop, which helps calculate delivery efficiency and cyclist performance.

## Rating System Architecture

I implemented the rating system as a separate entity that can evaluate both food quality and delivery service independently. A customer might love the food but have issues with delivery, or vice versa, so I created separate FoodRating and DeliveryRating fields. Both use check constraints to ensure ratings stay between 1 and 5 stars.

The Rating table has foreign keys to both Cook and Cyclist, which provides flexibility. Some orders might only rate the food, others only the delivery, and some both. I added a check constraint to ensure at least one rating exists, preventing rating records without content.

## Data Integrity Measures

Throughout my design, I prioritized data integrity. I used NOT NULL constraints on fields like addresses, phone numbers, and personal IDs because Zoe stated these are required from all partners. I added UNIQUE constraints on personal IDs to prevent duplicate registrations.

I implemented cascading deletes. When a cook is removed, their portions should also be deleted, but I chose not to cascade delete orders that reference those portions, as we need to maintain order history for financial records. This decision balances data cleanup with business requirements for record keeping.

## Performance Optimization

I created indexes on all foreign key columns to speed up joins, which are used in this system. For example, finding all portions for a cook, all orders for a customer, or all trips for a cyclist are operations that benefit from these indexes. I also indexed fields used in the WHERE clauses of the required queries, such as Cook.Name and Cyclist.Name.

## Time-Based Design Decisions

The distinction between TIME and DATETIME was important in my design. I use TIME for portion availability because it represents daily recurring windows (like "available from 11:30 to 12:30 every day"). But I use DATETIME for orders, trips, and ratings because these are moments in history that happened once.

This temporal modeling allows the system to answer questions like "What portions are available right now?" by comparing the current time against the TIME fields, while also maintaining historical records with DATETIME fields.

## Scalability Considerations

I designed the schema to scale. The OrderItem and TripStop tables act as junction tables that can handle many-to-many relationships without limiting the system. A cyclist can deliver hundreds of orders, a cook can offer dozens of portions, and a customer can place many orders. The identity columns with INT datatype provide range for millions of records.

## Conclusion

My database design transforms the requirements from the stakeholder interviews into a relational model. Every design decision maps back to a requirement: TIME datatypes for Noah's availability windows, rating fields for Zoe's quality tracking, and trip recording for Star's monthly reporting needs. The design balances normalization with performance considerations, creating a system that can support the local food delivery app's current needs while remaining adaptable.