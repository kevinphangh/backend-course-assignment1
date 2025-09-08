# Database Design Reasoning for Local Food Delivery App

## Design Overview

I designed a relational database for SQL Server 2022 using Transact-SQL that models the local food delivery system. My schema consists of 9 tables: three core entity tables (Cook, Cyclist, Customer), four operational tables (Portion, Order, Trip, Rating), and two junction tables (OrderItem, TripStop) for many-to-many relationships.

## Core Design Decisions

### Entity Separation
I created separate tables for Cook, Cyclist, and Customer rather than a unified User table because each has distinct required attributes per Zoe's requirements: cooks need kitchen address and personal ID, cyclists need bike type, and customers need payment options (Card or MobilePay). This avoids null fields and enforces business rules through NOT NULL constraints.

### Time-Based Availability (Noah's Requirement)
I implemented the Portion table with TIME datatypes for AvailableFrom and AvailableUntil as mandated by the assignment. TIME represents recurring daily windows (like "11:30-12:30 every day") rather than specific moments, perfectly matching Noah's need to specify when dishes are available during his restaurant breaks. A check constraint ensures AvailableUntil > AvailableFrom.

### Order and Delivery Structure
The Order-OrderItem relationship allows customers to order from multiple cooks in one transaction (as shown in the requirements example with Noah's and Helle's kitchens). I store the price in OrderItem to preserve historical pricing even when portion prices change.

The Trip-TripStop structure handles Star's requirement for multiple delivery locations. The StopOrder field maintains sequence, StopType distinguishes pickups from deliveries, and this design supports her scenario of five deliveries in one neighborhood. The 30-minute delivery range mentioned by Zoe is handled at the application level using address data.

### Rating System
I implemented separate nullable FoodRating and DeliveryRating fields (1-5 stars) with nullable foreign keys to Cook and Cyclist. This allows rating food without delivery or vice versa, with a check constraint ensuring at least one rating exists per record.

## Data Integrity and Performance

### Constraints and Keys
- All tables use IDENTITY(1,1) primary keys for auto-incrementing IDs
- NOT NULL on all fields Zoe specified as required (addresses, phones, IDs)
- UNIQUE on personal IDs to prevent duplicate registrations
- Cascading deletes from Cook→Portion and Customer→Order, but not from Portion→OrderItem to preserve order history

### Indexing Strategy
I created indexes on all foreign keys to optimize joins, particularly for common queries like finding portions by cook, orders by customer, and trips by cyclist. Additional indexes on Cook.Name and Cyclist.Name support the required WHERE clauses.

## Temporal Design
I use TIME for recurring availability windows and DATETIME for historical events:
- TIME: Portion availability (daily recurring)
- DATETIME: Orders, trips, ratings (specific moments in history)

This allows queries like "What's available now?" while maintaining complete historical records for Star's monthly reporting needs (Query 6).

## Conclusion

My design directly maps each stakeholder requirement to database features: TIME datatypes for Noah's availability, nullable ratings for Zoe's quality tracking, TripStop for Star's multi-delivery routes, and comprehensive indexing for performance. The schema uses SQL Server 2022 features appropriately while maintaining referential integrity and supporting all seven required queries.