-- assignment 1 queries
-- part d - 7 required queries

-- query 1: get cook info
SELECT Address, Phone, PersonalID
FROM dbo.Cook
WHERE Name = 'Mormors Mad';
GO


-- query 2 - portions with times
SELECT p.Name, p.Quantity, p.Price,
       CONVERT(VARCHAR(5), p.AvailableFrom, 108) AS AvailableFrom,
       CONVERT(VARCHAR(5), p.AvailableUntil, 108) AS AvailableUntil
FROM dbo.Portion p
INNER JOIN dbo.Cook c ON p.CookID = c.CookID
WHERE c.Name = 'Mormors Mad'
ORDER BY p.Name;
GO


-- Query 3: order items
-- shows which kitchen each item comes from
SELECT oi.Quantity, p.Name AS PortionName, c.Name AS Kitchen
FROM dbo.OrderItem oi
INNER JOIN dbo.Portion p ON oi.PortionID = p.PortionID
INNER JOIN dbo.Cook c ON oi.CookID = c.CookID
WHERE oi.OrderID = 0  -- first order
ORDER BY p.Name;
GO


-- query 4 delivery route
SELECT ts.Address,
       CONVERT(VARCHAR(5), ts.StopTime, 108) AS StopTime,
       ts.StopType
FROM dbo.TripStop ts
WHERE ts.TripID = 0
ORDER BY ts.StopOrder; 
GO


-- query5: average rating
SELECT CAST(AVG(CAST(r.FoodRating AS FLOAT)) AS DECIMAL(2,1)) AS AverageRating
FROM dbo.Rating r
INNER JOIN dbo.Cook c ON r.CookID = c.CookID
WHERE c.Name = 'Mormors Mad'
  AND r.FoodRating IS NOT NULL;
GO


-- Query 6 - monthly cyclist performance
-- shows hours and earnings
SELECT
    DATENAME(MONTH, t.StartTime) AS Month,
    SUM(DATEDIFF(MINUTE, t.StartTime, t.EndTime)) / 60 AS Hours,
    SUM(t.Earnings) AS Earnings
FROM dbo.Trip t
INNER JOIN dbo.Cyclist c ON t.CyclistID = c.CyclistID
WHERE c.Name = 'Mikkel'
  AND YEAR(t.StartTime) = 2024
  AND t.EndTime IS NOT NULL  -- completed only
GROUP BY MONTH(t.StartTime), DATENAME(MONTH, t.StartTime)
ORDER BY MONTH(t.StartTime);
GO


-- query 7: all cyclists
SELECT Name, Phone, PersonalID, BikeType
FROM dbo.Cyclist
ORDER BY Name;
GO


-- extra queries (not required)

-- get customer details
SELECT Name, Address, Phone, PaymentOption
FROM dbo.Customer
WHERE Name = 'Peter Jensen';
GO

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

-- cyclist leaderboard
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