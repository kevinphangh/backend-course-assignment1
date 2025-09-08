-- Required queries for Local Food Delivery App

-- Query 1: Get the data collected for each cook
-- Example for Noah's Kitchen
SELECT Address, Phone, PersonalID
FROM dbo.Cook
WHERE Name = 'Noah''s Kitchen';
GO

-- Query 2: Available portion name, quantity, price, and time interval for a Kitchen
-- Example for Noah's Kitchen
SELECT p.Name, p.Quantity, p.Price, 
       CONVERT(VARCHAR(5), p.AvailableFrom, 108) AS AvailableFrom,
       CONVERT(VARCHAR(5), p.AvailableUntil, 108) AS AvailableUntil
FROM dbo.Portion p
INNER JOIN dbo.Cook c ON p.CookID = c.CookID
WHERE c.Name = 'Noah''s Kitchen'
ORDER BY p.Name;
GO

-- Query 3: Get the list of goods and the provider kitchen in an order
-- Example for Order 42
SELECT oi.Quantity, p.Name AS PortionName, c.Name AS Kitchen
FROM dbo.OrderItem oi
INNER JOIN dbo.Portion p ON oi.PortionID = p.PortionID
INNER JOIN dbo.Cook c ON oi.CookID = c.CookID
WHERE oi.OrderID = 0  -- OrderID 0 is Order #42 in our 0-based system
ORDER BY p.Name;
GO

-- Query 4: Get the trip for a cyclist
-- Example for Trip ID 52 (TripID = 0 in our 0-based system)
SELECT ts.Address,
       CONVERT(VARCHAR(5), ts.StopTime, 108) AS StopTime,
       ts.StopType
FROM dbo.TripStop ts
WHERE ts.TripID = 0  -- TripID 0 is Trip #52
ORDER BY ts.StopOrder;
GO

-- Query 5: Get the average rating for a cook
-- Example for Noah
SELECT CAST(AVG(CAST(r.FoodRating AS FLOAT)) AS DECIMAL(2,1)) AS AverageRating
FROM dbo.Rating r
INNER JOIN dbo.Cook c ON r.CookID = c.CookID
WHERE c.Name = 'Noah''s Kitchen'
  AND r.FoodRating IS NOT NULL;
GO

-- Query 6: Get the monthly hours and earning for a cyclist
-- Example for Star
SELECT 
    DATENAME(MONTH, t.StartTime) AS Month,
    SUM(DATEDIFF(MINUTE, t.StartTime, t.EndTime)) / 60 AS Hours,
    SUM(t.Earnings) AS Earnings
FROM dbo.Trip t
INNER JOIN dbo.Cyclist c ON t.CyclistID = c.CyclistID
WHERE c.Name = 'Star'
  AND YEAR(t.StartTime) = 2024
  AND t.EndTime IS NOT NULL
GROUP BY MONTH(t.StartTime), DATENAME(MONTH, t.StartTime)
ORDER BY MONTH(t.StartTime);
GO

-- Query 7: Custom query - Get cyclist data (phone, ID, bike type)
-- Shows all cyclists with their details
SELECT Name, Phone, PersonalID, BikeType
FROM dbo.Cyclist
ORDER BY Name;
GO

-- Additional useful queries for completeness:

-- Get customer data
SELECT Name, Address, Phone, PaymentOption
FROM dbo.Customer
WHERE Name = 'Knuth';
GO

-- Get top-rated cooks
SELECT c.Name AS Cook, 
       AVG(CAST(r.FoodRating AS FLOAT)) AS AverageRating,
       COUNT(r.FoodRating) AS NumberOfRatings
FROM dbo.Cook c
LEFT JOIN dbo.Rating r ON c.CookID = r.CookID
WHERE r.FoodRating IS NOT NULL
GROUP BY c.CookID, c.Name
HAVING COUNT(r.FoodRating) > 0
ORDER BY AverageRating DESC;
GO

-- Get cyclist performance metrics
SELECT c.Name AS Cyclist,
       COUNT(t.TripID) AS TotalTrips,
       SUM(DATEDIFF(MINUTE, t.StartTime, t.EndTime)) / 60.0 AS TotalHours,
       SUM(t.Earnings) AS TotalEarnings,
       AVG(r.DeliveryRating) AS AverageDeliveryRating
FROM dbo.Cyclist c
LEFT JOIN dbo.Trip t ON c.CyclistID = t.CyclistID
LEFT JOIN dbo.Rating r ON c.CyclistID = r.CyclistID
WHERE t.EndTime IS NOT NULL
GROUP BY c.CyclistID, c.Name
ORDER BY TotalEarnings DESC;
GO