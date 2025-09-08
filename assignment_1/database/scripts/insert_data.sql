-- Sample data for Local Food Delivery App
-- IDs start from 0 for SQL Server 2022 Linux compatibility

-- Insert Cooks
INSERT INTO dbo.Cook (Name, Address, Phone, PersonalID) VALUES
('Noah''s Kitchen', 'Finlandsgade 17, 8200 Aarhus N', '+45 71555080', '010100-4201'),
('Helle''s Kitchen', 'Ny Munkegade 118, 8200', '+45 12345678', '020202-1234'),
('Maria''s Kitchen', 'Finsensgade 1493, 8000 Aarhus', '+45 87654321', '030303-5678');
GO

-- Insert Cyclists
INSERT INTO dbo.Cyclist (Name, Phone, PersonalID, BikeType) VALUES
('Star', '+45 98765432', '040404-9876', 'Mountain Bike'),
('John', '+45 11223344', '050505-1122', 'Road Bike'),
('Emma', '+45 55667788', '060606-5566', 'Electric Bike');
GO

-- Insert Customers
INSERT INTO dbo.Customer (Name, Address, Phone, PaymentOption) VALUES
('Knuth', 'Finsensgade 1493, 8000 Aarhus', '+45 33445566', 'Card'),
('Alice', 'Nordre Ringgade 100, 8000 Aarhus', '+45 77889900', 'MobilePay'),
('Bob', 'Vesterbro Torv 3, 8000 Aarhus', '+45 22334455', 'Card'),
('Charlie', 'Mejlgade 53, 8000 Aarhus', '+45 66778899', 'MobilePay');
GO

-- Insert Portions (using TIME datatype as required)
-- Noah's Kitchen (CookID = 0)
INSERT INTO dbo.Portion (CookID, Name, Quantity, Price, AvailableFrom, AvailableUntil) VALUES
(0, 'Pasta', 3, 30, '11:30:00', '12:30:00'),
(0, 'Romkugle', 10, 3, '08:00:00', '12:30:00'),
(0, 'Lasagna', 5, 45, '17:00:00', '20:00:00');

-- Helle's Kitchen (CookID = 1)
INSERT INTO dbo.Portion (CookID, Name, Quantity, Price, AvailableFrom, AvailableUntil) VALUES
(1, 'Lemonade', 20, 15, '10:00:00', '18:00:00'),
(1, 'Sandwich', 8, 35, '11:00:00', '14:00:00'),
(1, 'Soup', 6, 25, '12:00:00', '14:00:00');

-- Maria's Kitchen (CookID = 2)
INSERT INTO dbo.Portion (CookID, Name, Quantity, Price, AvailableFrom, AvailableUntil) VALUES
(2, 'Pizza', 4, 60, '16:00:00', '21:00:00'),
(2, 'Salad', 10, 20, '11:00:00', '15:00:00');
GO

-- Insert Orders
-- Order 42 for Knuth (CustomerID = 0)
INSERT INTO dbo.[Order] (CustomerID, OrderDate, TotalAmount) VALUES
(0, '2024-06-15 12:00:00', 126); -- 2*Pasta + 4*Romkugle + 2*Lemonade

-- Order 43 for Alice (CustomerID = 1)
INSERT INTO dbo.[Order] (CustomerID, OrderDate, TotalAmount) VALUES
(1, '2024-06-20 13:30:00', 90); -- 2*Lasagna

-- Order 44 for Bob (CustomerID = 2)
INSERT INTO dbo.[Order] (CustomerID, OrderDate, TotalAmount) VALUES
(2, '2024-07-10 18:00:00', 120); -- 2*Pizza

-- Additional orders for cyclist monthly stats
INSERT INTO dbo.[Order] (CustomerID, OrderDate, TotalAmount) VALUES
(3, '2024-06-05 12:30:00', 60),
(0, '2024-06-08 13:00:00', 45),
(1, '2024-07-12 19:00:00', 75),
(2, '2024-07-15 12:45:00', 50),
(3, '2024-08-01 13:15:00', 80),
(0, '2024-08-10 18:30:00', 65),
(1, '2024-08-20 12:00:00', 55);
GO

-- Insert OrderItems for Order 42
INSERT INTO dbo.OrderItem (OrderID, PortionID, CookID, Quantity, Price) VALUES
(0, 0, 0, 2, 30), -- 2 Pasta from Noah
(0, 1, 0, 4, 3),  -- 4 Romkugle from Noah
(0, 3, 1, 2, 15); -- 2 Lemonade from Helle

-- Insert OrderItems for other orders
INSERT INTO dbo.OrderItem (OrderID, PortionID, CookID, Quantity, Price) VALUES
(1, 2, 0, 2, 45), -- Order 43: 2 Lasagna
(2, 6, 2, 2, 60), -- Order 44: 2 Pizza
(3, 0, 0, 2, 30), -- Additional orders
(4, 4, 1, 1, 35),
(5, 5, 1, 3, 25),
(6, 1, 0, 5, 3),
(7, 6, 2, 1, 60),
(8, 7, 2, 2, 20),
(9, 0, 0, 1, 30);
GO

-- Insert Trips (Trip 52 for Star as required)
-- Trip 52 for Order 42 (Star, CyclistID = 0)
INSERT INTO dbo.Trip (CyclistID, OrderID, StartTime, EndTime, Earnings) VALUES
(0, 0, '2024-06-15 11:50:00', '2024-06-15 12:20:00', 45);

-- Additional trips for monthly statistics
INSERT INTO dbo.Trip (CyclistID, OrderID, StartTime, EndTime, Earnings) VALUES
(0, 3, '2024-06-05 12:20:00', '2024-06-05 12:50:00', 40),
(0, 4, '2024-06-08 12:45:00', '2024-06-08 13:20:00', 42),
(0, 5, '2024-07-12 18:45:00', '2024-07-12 19:20:00', 48),
(0, 6, '2024-07-15 12:30:00', '2024-07-15 13:00:00', 38),
(0, 7, '2024-08-01 13:00:00', '2024-08-01 13:35:00', 50),
(0, 8, '2024-08-10 18:15:00', '2024-08-10 18:50:00', 45),
(0, 9, '2024-08-20 11:45:00', '2024-08-20 12:20:00', 42),
(1, 1, '2024-06-20 13:15:00', '2024-06-20 13:45:00', 35),
(2, 2, '2024-07-10 17:45:00', '2024-07-10 18:15:00', 38);
GO

-- Insert TripStops for Trip 52 (TripID = 0)
INSERT INTO dbo.TripStop (TripID, Address, StopTime, StopType, StopOrder) VALUES
(0, 'Finlandsgade 17, 8200', '12:00:00', 'Pickup', 1),
(0, 'Ny Munkegade 118, 8200', '12:09:00', 'Pickup', 2),
(0, 'Finsensgade 1493, 8000 Aarhus', '12:16:00', 'Delivery', 3);

-- Additional trip stops for other trips
INSERT INTO dbo.TripStop (TripID, Address, StopTime, StopType, StopOrder) VALUES
(1, 'Finlandsgade 17, 8200', '12:25:00', 'Pickup', 1),
(1, 'Mejlgade 53, 8000 Aarhus', '12:35:00', 'Delivery', 2);
GO

-- Insert Ratings
-- Ratings for Noah (CookID = 0)
INSERT INTO dbo.Rating (OrderID, CookID, CyclistID, FoodRating, DeliveryRating) VALUES
(0, 0, 0, 5, 5),
(3, 0, 0, 5, 4),
(4, 0, 0, 4, 5),
(9, 0, 0, 5, 4);

-- Ratings for other cooks and cyclists
INSERT INTO dbo.Rating (OrderID, CookID, CyclistID, FoodRating, DeliveryRating) VALUES
(1, 0, 1, 5, 4),
(2, 2, 2, 4, 5),
(5, 1, 0, 4, 5),
(6, 0, 0, 5, 5),
(7, 2, 0, 4, 4),
(8, 2, 0, 3, 5);
GO

-- Calculate monthly hours and earnings for Star (CyclistID = 0)
-- June: 45 hours, 4520 DKK
-- July: 50 hours, 5019 DKK
-- August: 49 hours, 4910 DKK

-- To achieve these numbers, we need many more trips
-- We'll insert simplified bulk data for demonstration

-- June additional trips for Star
DECLARE @i INT = 10;
WHILE @i < 55
BEGIN
    INSERT INTO dbo.[Order] (CustomerID, OrderDate, TotalAmount) 
    VALUES (@i % 4, DATEADD(day, @i % 25, '2024-06-01'), 50 + (@i % 30));
    
    INSERT INTO dbo.Trip (CyclistID, OrderID, StartTime, EndTime, Earnings)
    VALUES (0, @i, DATEADD(hour, @i % 24, '2024-06-01'), DATEADD(hour, (@i % 24) + 1, '2024-06-01'), 100);
    
    SET @i = @i + 1;
END

-- July additional trips for Star  
WHILE @i < 105
BEGIN
    INSERT INTO dbo.[Order] (CustomerID, OrderDate, TotalAmount) 
    VALUES (@i % 4, DATEADD(day, @i % 28, '2024-07-01'), 60 + (@i % 25));
    
    INSERT INTO dbo.Trip (CyclistID, OrderID, StartTime, EndTime, Earnings)
    VALUES (0, @i, DATEADD(hour, @i % 24, '2024-07-01'), DATEADD(hour, (@i % 24) + 1, '2024-07-01'), 100);
    
    SET @i = @i + 1;
END

-- August additional trips for Star
WHILE @i < 154
BEGIN
    INSERT INTO dbo.[Order] (CustomerID, OrderDate, TotalAmount) 
    VALUES (@i % 4, DATEADD(day, @i % 28, '2024-08-01'), 55 + (@i % 35));
    
    INSERT INTO dbo.Trip (CyclistID, OrderID, StartTime, EndTime, Earnings)
    VALUES (0, @i, DATEADD(hour, @i % 24, '2024-08-01'), DATEADD(hour, (@i % 24) + 1, '2024-08-01'), 100);
    
    SET @i = @i + 1;
END
GO