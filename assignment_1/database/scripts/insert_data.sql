-- Test data for Local Food Delivery database
-- IDs start from 0 (SQL Server 2022 Linux IDENTITY behavior)

-- Cook records
INSERT INTO dbo.Cook (Name, Address, Phone, PersonalID) VALUES
('Noah''s Kitchen', 'Finlandsgade 17, 8200 Aarhus N', '+45 71555080', '010100-4201'),
('Helle''s Kitchen', 'Ny Munkegade 118, 8200', '+45 12345678', '020202-1234'),
('Maria''s Kitchen', 'Finsensgade 1493, 8000 Aarhus', '+45 87654321', '030303-5678');
GO

-- Cyclist records
INSERT INTO dbo.Cyclist (Name, Phone, PersonalID, BikeType) VALUES
('Star', '+45 98765432', '040404-9876', 'Mountain Bike'),
('John', '+45 11223344', '050505-1122', 'Road Bike'),
('Emma', '+45 55667788', '060606-5566', 'Electric Bike');
GO

-- Customer records
INSERT INTO dbo.Customer (Name, Address, Phone, PaymentOption) VALUES
('Knuth', 'Nordre Ringgade 1, 8000 Aarhus C', '+45 33445566', 'Card'),
('Alice', 'Vesterbro Torv 3, 8000 Aarhus C', '+45 77889900', 'MobilePay'),
('Bob', 'Mejlgade 51, 8000 Aarhus C', '+45 22334455', 'Card');
GO

-- Portion records (daily availability windows)
INSERT INTO dbo.Portion (CookID, Name, Quantity, Price, AvailableFrom, AvailableUntil) VALUES
(0, 'Spaghetti Carbonara', 10, 89, '11:30:00', '13:30:00'),
(0, 'Caesar Salad', 15, 65, '11:30:00', '13:30:00'),
(0, 'Tiramisu', 8, 45, '11:30:00', '13:30:00'),
(1, 'Grilled Chicken', 12, 95, '12:00:00', '14:00:00'),
(1, 'Vegetable Stir Fry', 10, 75, '12:00:00', '14:00:00'),
(2, 'Fish Tacos', 20, 70, '17:00:00', '19:00:00');
GO

-- Order records
-- Order #42 (ID=0): Multi-kitchen order (Noah's + Helle's)
INSERT INTO dbo.[Order] (CustomerID, OrderDate, TotalAmount) VALUES
(0, '2024-01-15 12:45:00', 259),  -- Order #42
(1, '2024-01-15 13:00:00', 95),
(2, '2024-01-15 18:30:00', 70);
GO

-- OrderItem records for Order #42
INSERT INTO dbo.OrderItem (OrderID, PortionID, CookID, Quantity, Price) VALUES
(0, 0, 0, 2, 178),  -- 2x Spaghetti from Noah's
(0, 3, 1, 1, 95);   -- 1x Grilled Chicken from Helle's
GO

-- Additional order items
INSERT INTO dbo.OrderItem (OrderID, PortionID, CookID, Quantity, Price) VALUES
(1, 3, 1, 1, 95),
(2, 5, 2, 1, 70);
GO

-- Trip records
-- Trip #52 (ID=0): Multiple stops for Star
INSERT INTO dbo.Trip (CyclistID, OrderID, StartTime, EndTime, Earnings) VALUES
(0, 0, '2024-01-15 12:30:00', '2024-01-15 13:15:00', 50),  -- Trip #52
(1, 1, '2024-01-15 12:45:00', '2024-01-15 13:20:00', 45),
(2, 2, '2024-01-15 18:00:00', '2024-01-15 18:35:00', 40);
GO

-- TripStop records for Trip #52 (multiple pickups)
INSERT INTO dbo.TripStop (TripID, Address, StopTime, StopType, StopOrder) VALUES
(0, 'Finlandsgade 17, 8200 Aarhus N', '12:35:00', 'Pickup', 1),
(0, 'Ny Munkegade 118, 8200', '12:45:00', 'Pickup', 2),
(0, 'Nordre Ringgade 1, 8000 Aarhus C', '13:00:00', 'Delivery', 3);
GO

-- Additional trip stops
INSERT INTO dbo.TripStop (TripID, Address, StopTime, StopType, StopOrder) VALUES
(1, 'Ny Munkegade 118, 8200', '12:50:00', 'Pickup', 1),
(1, 'Vesterbro Torv 3, 8000 Aarhus C', '13:10:00', 'Delivery', 2),
(2, 'Finsensgade 1493, 8000 Aarhus', '18:05:00', 'Pickup', 1),
(2, 'Mejlgade 51, 8000 Aarhus C', '18:25:00', 'Delivery', 2);
GO

-- Rating records (food and delivery)
INSERT INTO dbo.Rating (OrderID, CookID, CyclistID, FoodRating, DeliveryRating, RatingDate) VALUES
(0, 0, 0, 5, 4, '2024-01-16 10:00:00'),
(0, 1, NULL, 4, NULL, '2024-01-16 10:00:00'),
(1, 1, 1, 5, 5, '2024-01-16 11:00:00'),
(2, 2, 2, 3, 4, '2024-01-16 09:00:00');
GO

-- Additional test data for monthly performance (Query 6)
INSERT INTO dbo.Trip (CyclistID, OrderID, StartTime, EndTime, Earnings) VALUES
(0, 0, '2024-01-20 12:00:00', '2024-01-20 12:45:00', 45),
(0, 0, '2024-02-10 13:00:00', '2024-02-10 13:40:00', 42),
(0, 0, '2024-02-15 12:30:00', '2024-02-15 13:10:00', 48),
(0, 0, '2024-03-05 11:45:00', '2024-03-05 12:30:00', 50);
GO