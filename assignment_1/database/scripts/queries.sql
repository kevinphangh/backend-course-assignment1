-- Query 1: Retrieve cook personal data
-- Required by assignment: Address, Phone, PersonalID for a specific cook
-- Use case: Verifying cook identity or contacting for operational needs
SELECT Address, Phone, PersonalID
FROM dbo.Cook
WHERE Name = 'Noah''s Kitchen';
GO

-- Query 2: List available portions with time windows for a specific kitchen
-- Shows what food items a cook offers and when they're available each day
-- TIME format converted to HH:MM for readability (e.g., '11:30' instead of '11:30:00')
SELECT p.Name, p.Quantity, p.Price, 
       CONVERT(VARCHAR(5), p.AvailableFrom, 108) AS AvailableFrom,
       CONVERT(VARCHAR(5), p.AvailableUntil, 108) AS AvailableUntil
FROM dbo.Portion p
INNER JOIN dbo.Cook c ON p.CookID = c.CookID
WHERE c.Name = 'Noah''s Kitchen'
ORDER BY p.Name;
GO

-- Query 3: Display order items with their source kitchens
-- Demonstrates multi-kitchen ordering capability (Noah's + Helle's in one order)
-- Order #42 is ID=0 in database due to 0-based identity seeding
SELECT oi.Quantity, p.Name AS PortionName, c.Name AS Kitchen
FROM dbo.OrderItem oi
INNER JOIN dbo.Portion p ON oi.PortionID = p.PortionID
INNER JOIN dbo.Cook c ON oi.CookID = c.CookID
WHERE oi.OrderID = 0  -- Order #42 (0-based IDs)
ORDER BY p.Name;
GO

-- Query 4: Show delivery route with stops and times for a specific trip
-- Supports Star's requirement for multiple deliveries in one trip
-- Trip #52 is ID=0 in database, ordered by StopOrder to show route sequence
SELECT ts.Address,
       CONVERT(VARCHAR(5), ts.StopTime, 108) AS StopTime,
       ts.StopType
FROM dbo.TripStop ts
WHERE ts.TripID = 0  -- Trip #52 (0-based IDs)
ORDER BY ts.StopOrder;
GO

-- Query 5: Calculate average food quality rating for a specific cook
-- Only includes non-null food ratings (delivery ratings excluded)
-- Result formatted to 1 decimal place for star rating display
SELECT CAST(AVG(CAST(r.FoodRating AS FLOAT)) AS DECIMAL(2,1)) AS AverageRating
FROM dbo.Rating r
INNER JOIN dbo.Cook c ON r.CookID = c.CookID
WHERE c.Name = 'Noah''s Kitchen'
  AND r.FoodRating IS NOT NULL;
GO

-- Query 6: Summarize cyclist monthly performance metrics
-- Shows total hours worked and earnings per month for the year 2024
-- Essential for Star's income tracking and tax reporting needs
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

-- Query 7: List all cyclists with their contact and equipment information
-- Shows phone for dispatch, PersonalID for verification, BikeType for route planning
-- Custom query beyond assignment requirements for operational dashboard
SELECT Name, Phone, PersonalID, BikeType
FROM dbo.Cyclist
ORDER BY Name;
GO

-- Additional queries:

-- Customer data with payment method
SELECT Name, Address, Phone, PaymentOption
FROM dbo.Customer
WHERE Name = 'Knuth';
GO

-- Top-rated cooks with rating counts
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