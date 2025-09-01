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

-- Reset identity counters (on SQL Server 2022 Linux, RESEED 0 starts from 0)
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

-- Experiences (ProviderIDs start from 0 on SQL Server 2022 Linux)
INSERT INTO dbo.Experience (ProviderID, Name, Description, Price) VALUES
(0, 'Night at Noah''s Hotel Single room', 'Comfortable single room accommodation', 730.50),
(0, 'Night at Noah''s Hotel Double room', 'Spacious double room accommodation', 910.99),
(1, 'Flight AAR - VIE', 'Round trip flight from Aarhus to Vienna', 1000.70),
(2, 'Vienna Historic Center Walking Tour', 'Guided tour through Vienna''s historic center', 100.00),
(3, 'Dinner Downtown', 'Three-course dinner at Downtown Restaurant', 250.00),
(4, 'Pottery Weekend Workshop', 'Two-day pottery workshop with materials included', 450.00);
GO

-- Shared Experiences (GuestIDs start from 0)
INSERT INTO dbo.SharedExperience (Name, Date, OrganizerID) VALUES
('Trip to Austria', '2024-07-02', 0),  -- Joan (GuestID 0) organizes
('Dinner Downtown', '2024-04-07', 4),  -- Michael (GuestID 4) organizes
('Pottery Weekend', '2024-03-22', 5);  -- Sarah (GuestID 5) organizes
GO

-- Link experiences to trips (IDs start from 0)
INSERT INTO dbo.SharedExperienceItem (SharedExperienceID, ExperienceID) VALUES
(0, 2),  -- Austria trip (ID 0): Flight (ID 2)
(0, 0),  -- Austria trip: Hotel single (ID 0)
(0, 3),  -- Austria trip: Walking tour (ID 3)
(1, 4),  -- Dinner (ID 1): Restaurant (ID 4)
(2, 5);  -- Pottery (ID 2): Workshop (ID 5)
GO

-- Individual bookings (all IDs start from 0)
INSERT INTO dbo.Booking (GuestID, SharedExperienceItemID) VALUES
-- Austria trip bookings (SharedExperienceItemIDs 0,1,2)
(0, 0), (0, 1), (0, 2),  -- Joan (ID 0): all 3 items
(1, 0), (1, 1), (1, 2),  -- Suzzane (ID 1): all 3
(2, 0), (2, 1),          -- Patrick (ID 2): flight & hotel only
(3, 0), (3, 1),          -- Anne (ID 3): flight & hotel only

-- Dinner bookings (SharedExperienceItemID 3)
(4, 3), (5, 3), (6, 3),  -- Michael, Sarah, Thomas

-- Workshop bookings (SharedExperienceItemID 4)
(5, 4), (6, 4), (7, 4);  -- Sarah, Thomas, Emma
GO

-- Volume discounts per provider (ProviderIDs start from 0)
INSERT INTO dbo.Discount (ProviderID, MinGuests, DiscountPercentage) VALUES
(0, 10, 10.00), (0, 50, 20.00),  -- Noah's Hotel (ID 0)
(1, 5, 5.00), (1, 15, 12.00),     -- Austrian Airlines (ID 1)
(2, 8, 15.00), (2, 20, 25.00);    -- Vienna Tours (ID 2)
GO

PRINT 'Sample data inserted successfully!';