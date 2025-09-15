-- Query 1: Cook personal data (required by assignment)
SELECT Address, Phone, PersonalID
FROM dbo.Cook
WHERE Name = 'Noah''s Kitchen';
GO

-- Query 2: Available portions with time windows
SELECT p.Name, p.Quantity, p.Price,
       CONVERT(VARCHAR(5), p.AvailableFrom, 108) AS AvailableFrom,
       CONVERT(VARCHAR(5), p.AvailableUntil, 108) AS AvailableUntil
FROM dbo.Portion p
INNER JOIN dbo.Cook c ON p.CookID = c.CookID
WHERE c.Name = 'Noah''s Kitchen'
ORDER BY p.Name;
GO

-- Query 3: Order items with source kitchens
-- Order #42 = ID 0 (0-based identity seeding)
SELECT oi.Quantity, p.Name AS PortionName, c.Name AS Kitchen
FROM dbo.OrderItem oi
INNER JOIN dbo.Portion p ON oi.PortionID = p.PortionID
INNER JOIN dbo.Cook c ON oi.CookID = c.CookID
WHERE oi.OrderID = 0
ORDER BY p.Name;
GO

-- Query 4: Delivery route stops for trip
-- Trip #52 = ID 0
SELECT ts.Address,
       CONVERT(VARCHAR(5), ts.StopTime, 108) AS StopTime,
       ts.StopType
FROM dbo.TripStop ts
WHERE ts.TripID = 0
ORDER BY ts.StopOrder;
GO

-- Query 5: Average food rating for cook
SELECT CAST(AVG(CAST(r.FoodRating AS FLOAT)) AS DECIMAL(2,1)) AS AverageRating
FROM dbo.Rating r
INNER JOIN dbo.Cook c ON r.CookID = c.CookID
WHERE c.Name = 'Noah''s Kitchen'
  AND r.FoodRating IS NOT NULL;
GO

-- Query 6: Cyclist monthly performance (2024)
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

-- Query 7: All cyclists with equipment info (custom query)
SELECT Name, Phone, PersonalID, BikeType
FROM dbo.Cyclist
ORDER BY Name;
GO

-- Additional queries beyond assignment requirements:

-- Customer data with payment method
SELECT Name, Address, Phone, PaymentOption
FROM dbo.Customer
WHERE Name = 'Knuth';
GO

-- Top-rated cooks
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

-- Cyclist performance summary
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