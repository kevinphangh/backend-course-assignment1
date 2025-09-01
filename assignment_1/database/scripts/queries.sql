-- Required queries for Experience Share App

-- Query 1: Get provider data
SELECT Address, Phone, CVR 
FROM dbo.Provider 
WHERE Name = 'Noah''s Hotel';
GO

-- Query 2: List experiences with price
SELECT Name, Price 
FROM dbo.Experience 
ORDER BY Name;
GO

-- Query 3: List shared experiences DESC by date
SELECT Name, CONVERT(VARCHAR(10), Date, 120) AS Date  -- Format: YYYY-MM-DD
FROM dbo.SharedExperience 
ORDER BY Date DESC;
GO

-- Query 4: Get guests for shared experience
SELECT DISTINCT g.Name 
FROM dbo.Guest g
    INNER JOIN dbo.Booking b ON g.GuestID = b.GuestID
    INNER JOIN dbo.SharedExperienceItem sei ON b.SharedExperienceItemID = sei.SharedExperienceItemID
    INNER JOIN dbo.SharedExperience se ON sei.SharedExperienceID = se.SharedExperienceID
WHERE se.Name = 'Trip to Austria'
ORDER BY g.Name;
GO

-- Query 5: Get experiences in shared experience
SELECT DISTINCT e.Name 
FROM dbo.Experience e
    INNER JOIN dbo.SharedExperienceItem sei ON e.ExperienceID = sei.ExperienceID
    INNER JOIN dbo.SharedExperience se ON sei.SharedExperienceID = se.SharedExperienceID
WHERE se.Name = 'Trip to Austria'
ORDER BY e.Name;
GO

-- Query 6: Get guests for specific experience in shared experience
SELECT g.Name 
FROM dbo.Guest g
    INNER JOIN dbo.Booking b ON g.GuestID = b.GuestID
    INNER JOIN dbo.SharedExperienceItem sei ON b.SharedExperienceItemID = sei.SharedExperienceItemID
    INNER JOIN dbo.Experience e ON sei.ExperienceID = e.ExperienceID
    INNER JOIN dbo.SharedExperience se ON sei.SharedExperienceID = se.SharedExperienceID
WHERE se.Name = 'Trip to Austria' 
    AND e.Name = 'Vienna Historic Center Walking Tour'
ORDER BY g.Name;
GO

-- Alternative for hotel booking
SELECT g.Name 
FROM dbo.Guest g
    INNER JOIN dbo.Booking b ON g.GuestID = b.GuestID
    INNER JOIN dbo.SharedExperienceItem sei ON b.SharedExperienceItemID = sei.SharedExperienceItemID
    INNER JOIN dbo.Experience e ON sei.ExperienceID = e.ExperienceID
    INNER JOIN dbo.SharedExperience se ON sei.SharedExperienceID = se.SharedExperienceID
WHERE se.Name = 'Trip to Austria' 
    AND e.Name = 'Night at Noah''s Hotel Single room'
ORDER BY g.Name;
GO

-- Query 7: Get min/avg/max prices
SELECT 
    CAST(MIN(Price) AS DECIMAL(10,2)) AS MinPrice,
    CAST(AVG(Price) AS DECIMAL(10,4)) AS AvgPrice,
    CAST(MAX(Price) AS DECIMAL(10,2)) AS MaxPrice
FROM dbo.Experience;
GO

-- Query 8: Get guest count and sales sum per experience
SELECT 
    e.Name,
    COUNT(b.BookingID) AS NumberOfGuests,
    CAST(COUNT(b.BookingID) * e.Price AS DECIMAL(10,2)) AS TotalSales
FROM dbo.Experience e
    LEFT JOIN dbo.SharedExperienceItem sei ON e.ExperienceID = sei.ExperienceID
    LEFT JOIN dbo.Booking b ON sei.SharedExperienceItemID = b.SharedExperienceItemID
GROUP BY e.ExperienceID, e.Name, e.Price
ORDER BY e.Name;
GO

-- Query 9: Show discount thresholds
SELECT 
    p.Name AS ProviderName,
    d.MinGuests AS RequiredGroupSize,
    CAST(d.DiscountPercentage AS VARCHAR(10)) + '%' AS DiscountOffered,
    CASE 
        WHEN d.MinGuests <= 10 THEN 'Small Group Discount'
        WHEN d.MinGuests <= 20 THEN 'Medium Group Discount'
        ELSE 'Large Group Discount'
    END AS DiscountTier
FROM dbo.Provider p
    INNER JOIN dbo.Discount d ON p.ProviderID = d.ProviderID
ORDER BY p.Name, d.MinGuests;
GO

-- Query 10: Calculate applicable discounts based on bookings
WITH BookingCounts AS (
    SELECT 
        e.ExperienceID,
        e.Name AS ExperienceName,
        p.Name AS ProviderName,
        e.Price,
        COUNT(DISTINCT b.GuestID) AS CurrentGuests
    FROM dbo.Experience e
        INNER JOIN dbo.Provider p ON e.ProviderID = p.ProviderID
        LEFT JOIN dbo.SharedExperienceItem sei ON e.ExperienceID = sei.ExperienceID
        LEFT JOIN dbo.Booking b ON sei.SharedExperienceItemID = b.SharedExperienceItemID
    GROUP BY e.ExperienceID, e.Name, p.Name, e.Price
),
ApplicableDiscounts AS (
    SELECT 
        bc.ExperienceName,
        bc.ProviderName,
        bc.Price AS OriginalPrice,
        bc.CurrentGuests,
        MAX(d.DiscountPercentage) AS ApplicableDiscount
    FROM BookingCounts bc
        INNER JOIN dbo.Provider p ON bc.ProviderName = p.Name
        LEFT JOIN dbo.Discount d ON p.ProviderID = d.ProviderID 
            AND bc.CurrentGuests >= d.MinGuests
    GROUP BY bc.ExperienceName, bc.ProviderName, bc.Price, bc.CurrentGuests
)
SELECT 
    ExperienceName,
    ProviderName,
    CurrentGuests,
    CAST(OriginalPrice AS DECIMAL(10,2)) AS OriginalPrice,
    ISNULL(ApplicableDiscount, 0) AS DiscountPercentage,
    CAST(OriginalPrice * (1 - ISNULL(ApplicableDiscount, 0) / 100) AS DECIMAL(10,2)) AS DiscountedPrice
FROM ApplicableDiscounts
WHERE CurrentGuests > 0
ORDER BY ProviderName, ExperienceName;
GO

PRINT 'All queries executed successfully!';