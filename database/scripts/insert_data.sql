-- Sample data for Experience Share App

-- Clean existing data (reverse dependency order)
DELETE FROM dbo.Booking;
DELETE FROM dbo.SharedExperienceItem;
DELETE FROM dbo.SharedExperience;
DELETE FROM dbo.Discount;
DELETE FROM dbo.Experience;
DELETE FROM dbo.Guest;
DELETE FROM dbo.Provider;
GO

-- Reset identity counters
DBCC CHECKIDENT ('dbo.Provider', RESEED, 0);
DBCC CHECKIDENT ('dbo.Guest', RESEED, 0);
DBCC CHECKIDENT ('dbo.Experience', RESEED, 0);
DBCC CHECKIDENT ('dbo.SharedExperience', RESEED, 0);
DBCC CHECKIDENT ('dbo.SharedExperienceItem', RESEED, 0);
DBCC CHECKIDENT ('dbo.Booking', RESEED, 0);
DBCC CHECKIDENT ('dbo.Discount', RESEED, 0);
GO

-- Providers
INSERT INTO dbo.Provider (Name, Address, Phone, CVR) VALUES
('Noah''s Hotel', 'Finlandsgade 17, 8200 Aarhus N', '+45 71555080', '11111114'),
('Austrian Airlines', 'Copenhagen Airport, 2770 Kastrup', '+45 33123456', '22222225'),
('Vienna Tours', 'Stephansplatz 1, 1010 Vienna', '+43 1234567', '33333336'),
('Downtown Restaurant', 'Aarhus C, 8000 Aarhus', '+45 86123456', '44444447'),
('Pottery Workshop', 'Kunstgade 5, 8000 Aarhus C', '+45 86789012', '55555558');
GO

-- Guests
INSERT INTO dbo.Guest (Name, Age, Phone, PersonalID) VALUES
('Joan', 28, '+45 20304050', 'DK123456'),    -- Trip organizer
('Suzzane', 32, '+45 30405060', 'DK234567'),
('Patrick', 35, '+45 40506070', 'DK345678'),
('Anne', 29, '+45 50607080', 'DK456789'),
('Michael', 45, '+45 60708090', 'DK567890'), -- Dinner organizer
('Sarah', 26, '+45 70809010', 'DK678901'),   -- Workshop organizer
('Thomas', 38, '+45 80901020', 'DK789012'),
('Emma', 31, '+45 90102030', 'DK890123');
GO

-- Experiences (linked to providers by ProviderID)
INSERT INTO dbo.Experience (ProviderID, Name, Description, Price) VALUES
(1, 'Night at Noah''s Hotel Single room', 'Comfortable single room accommodation', 730.50),
(1, 'Night at Noah''s Hotel Double room', 'Spacious double room accommodation', 910.99),
(2, 'Flight AAR - VIE', 'Round trip flight from Aarhus to Vienna', 1000.70),
(3, 'Vienna Historic Center Walking Tour', 'Guided tour through Vienna''s historic center', 100.00),
(4, 'Dinner Downtown', 'Three-course dinner at Downtown Restaurant', 250.00),
(5, 'Pottery Weekend Workshop', 'Two-day pottery workshop with materials included', 450.00);
GO

-- Shared Experiences (group trips/events)
INSERT INTO dbo.SharedExperience (Name, Date, OrganizerID) VALUES
('Trip to Austria', '2024-07-02', 1),  -- Joan organizes
('Dinner Downtown', '2024-04-07', 5),  -- Michael organizes
('Pottery Weekend', '2024-03-22', 6);  -- Sarah organizes
GO

-- Link experiences to trips
INSERT INTO dbo.SharedExperienceItem (SharedExperienceID, ExperienceID) VALUES
(1, 3),  -- Austria trip: Flight
(1, 1),  -- Austria trip: Hotel single
(1, 4),  -- Austria trip: Walking tour
(2, 5),  -- Dinner: Restaurant
(3, 6);  -- Pottery: Workshop
GO

-- Individual bookings (selective participation)
INSERT INTO dbo.Booking (GuestID, SharedExperienceItemID) VALUES
-- Austria trip bookings
(1, 1), (1, 2), (1, 3),  -- Joan: all 3
(2, 1), (2, 2), (2, 3),  -- Suzzane: all 3
(3, 1), (3, 2),          -- Patrick: flight & hotel only
(4, 1), (4, 2),          -- Anne: flight & hotel only

-- Dinner bookings
(5, 4), (6, 4), (7, 4),  -- Michael, Sarah, Thomas

-- Workshop bookings
(6, 5), (7, 5), (8, 5);  -- Sarah, Thomas, Emma
GO

-- Volume discounts per provider
INSERT INTO dbo.Discount (ProviderID, MinGuests, DiscountPercentage) VALUES
(1, 10, 10.00), (1, 50, 20.00),  -- Noah's Hotel
(2, 5, 5.00), (2, 15, 12.00),     -- Austrian Airlines
(3, 8, 15.00), (3, 20, 25.00);    -- Vienna Tours
GO

PRINT 'Sample data inserted successfully!';