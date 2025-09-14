-- Database schema for Local Food Delivery Application
-- Platform: SQL Server 2022 / Transact-SQL
-- Purpose: SW4BAD Assignment 1 Part D - Database Design
-- This script creates the complete relational database schema for the food delivery system

-- Drop existing tables if they exist (ordered by foreign key dependencies)
-- Must drop child tables before parent tables to avoid constraint violations
IF OBJECT_ID('dbo.Rating', 'U') IS NOT NULL DROP TABLE dbo.Rating;
IF OBJECT_ID('dbo.TripStop', 'U') IS NOT NULL DROP TABLE dbo.TripStop;
IF OBJECT_ID('dbo.Trip', 'U') IS NOT NULL DROP TABLE dbo.Trip;
IF OBJECT_ID('dbo.OrderItem', 'U') IS NOT NULL DROP TABLE dbo.OrderItem;
IF OBJECT_ID('dbo.[Order]', 'U') IS NOT NULL DROP TABLE dbo.[Order];
IF OBJECT_ID('dbo.Portion', 'U') IS NOT NULL DROP TABLE dbo.Portion;
IF OBJECT_ID('dbo.Customer', 'U') IS NOT NULL DROP TABLE dbo.Customer;
IF OBJECT_ID('dbo.Cyclist', 'U') IS NOT NULL DROP TABLE dbo.Cyclist;
IF OBJECT_ID('dbo.Cook', 'U') IS NOT NULL DROP TABLE dbo.Cook;
GO

-- Table: Cook
-- Purpose: Stores information about home kitchen cooks offering food
-- Required fields per assignment: Address, Phone, PersonalID (Norwegian-style CPR number)
CREATE TABLE dbo.Cook (
    CookID INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(255) NOT NULL,
    Address NVARCHAR(500) NOT NULL,
    Phone NVARCHAR(50) NOT NULL,
    PersonalID NVARCHAR(50) NOT NULL UNIQUE
);
GO

-- Table: Cyclist 
-- Purpose: Stores delivery riders who transport food from cooks to customers
-- BikeType field helps match cyclists to appropriate delivery distances/loads
CREATE TABLE dbo.Cyclist (
    CyclistID INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(255) NOT NULL,
    Phone NVARCHAR(50) NOT NULL,
    PersonalID NVARCHAR(50) NOT NULL UNIQUE,
    BikeType NVARCHAR(100) NOT NULL
);
GO

-- Table: Customer
-- Purpose: Stores end users who place food orders through the platform
-- PaymentOption restricted to 'Card' or 'MobilePay' per Danish market requirements
CREATE TABLE dbo.Customer (
    CustomerID INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(255) NOT NULL,
    Address NVARCHAR(500) NOT NULL,
    Phone NVARCHAR(50) NOT NULL,
    PaymentOption NVARCHAR(20) NOT NULL CHECK (PaymentOption IN ('Card', 'MobilePay'))
);
GO

-- Table: Portion
-- Purpose: Represents available food items from each cook with quantities and time windows
-- Uses TIME datatype for AvailableFrom/Until to model recurring daily availability
-- This fulfills Noah's requirement for lunch break service windows
CREATE TABLE dbo.Portion (
    PortionID INT IDENTITY(1,1) PRIMARY KEY,
    CookID INT NOT NULL,
    Name NVARCHAR(255) NOT NULL,
    Quantity INT NOT NULL CHECK (Quantity > 0),
    Price INT NOT NULL CHECK (Price > 0),
    AvailableFrom TIME NOT NULL,
    AvailableUntil TIME NOT NULL,
    CONSTRAINT FK_Portion_Cook FOREIGN KEY (CookID) 
        REFERENCES dbo.Cook(CookID) ON DELETE CASCADE,
    CONSTRAINT CHK_TimeInterval CHECK (AvailableUntil > AvailableFrom)
);
GO

-- Order: Customer orders
CREATE TABLE dbo.[Order] (
    OrderID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT NOT NULL,
    OrderDate DATETIME NOT NULL DEFAULT GETDATE(),
    TotalAmount INT NOT NULL CHECK (TotalAmount >= 0),
    CONSTRAINT FK_Order_Customer FOREIGN KEY (CustomerID) 
        REFERENCES dbo.Customer(CustomerID) ON DELETE CASCADE
);
GO

-- OrderItem: Items in an order
CREATE TABLE dbo.OrderItem (
    OrderItemID INT IDENTITY(1,1) PRIMARY KEY,
    OrderID INT NOT NULL,
    PortionID INT NOT NULL,
    CookID INT NOT NULL,
    Quantity INT NOT NULL CHECK (Quantity > 0),
    Price INT NOT NULL CHECK (Price >= 0),
    CONSTRAINT FK_OrderItem_Order FOREIGN KEY (OrderID) 
        REFERENCES dbo.[Order](OrderID) ON DELETE CASCADE,
    CONSTRAINT FK_OrderItem_Portion FOREIGN KEY (PortionID) 
        REFERENCES dbo.Portion(PortionID),
    CONSTRAINT FK_OrderItem_Cook FOREIGN KEY (CookID) 
        REFERENCES dbo.Cook(CookID)
);
GO

-- Trip: Delivery trips for cyclists
CREATE TABLE dbo.Trip (
    TripID INT IDENTITY(1,1) PRIMARY KEY,
    CyclistID INT NOT NULL,
    OrderID INT NOT NULL,
    StartTime DATETIME NOT NULL,
    EndTime DATETIME NULL,
    Earnings INT NOT NULL CHECK (Earnings >= 0),
    CONSTRAINT FK_Trip_Cyclist FOREIGN KEY (CyclistID) 
        REFERENCES dbo.Cyclist(CyclistID) ON DELETE CASCADE,
    CONSTRAINT FK_Trip_Order FOREIGN KEY (OrderID) 
        REFERENCES dbo.[Order](OrderID)
);
GO

-- TripStop: Pickup and delivery addresses for a trip
CREATE TABLE dbo.TripStop (
    TripStopID INT IDENTITY(1,1) PRIMARY KEY,
    TripID INT NOT NULL,
    Address NVARCHAR(500) NOT NULL,
    StopTime TIME NOT NULL,
    StopType NVARCHAR(20) NOT NULL CHECK (StopType IN ('Pickup', 'Delivery')),
    StopOrder INT NOT NULL,
    CONSTRAINT FK_TripStop_Trip FOREIGN KEY (TripID) 
        REFERENCES dbo.Trip(TripID) ON DELETE CASCADE
);
GO

-- Rating: Customer ratings for food and delivery
CREATE TABLE dbo.Rating (
    RatingID INT IDENTITY(1,1) PRIMARY KEY,
    OrderID INT NOT NULL,
    CookID INT NULL,
    CyclistID INT NULL,
    FoodRating INT NULL CHECK (FoodRating BETWEEN 1 AND 5),
    DeliveryRating INT NULL CHECK (DeliveryRating BETWEEN 1 AND 5),
    RatingDate DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_Rating_Order FOREIGN KEY (OrderID) 
        REFERENCES dbo.[Order](OrderID) ON DELETE CASCADE,
    CONSTRAINT FK_Rating_Cook FOREIGN KEY (CookID) 
        REFERENCES dbo.Cook(CookID),
    CONSTRAINT FK_Rating_Cyclist FOREIGN KEY (CyclistID) 
        REFERENCES dbo.Cyclist(CyclistID),
    CONSTRAINT CHK_AtLeastOneRating CHECK (FoodRating IS NOT NULL OR DeliveryRating IS NOT NULL)
);
GO

-- Create indexes for foreign keys and common queries
CREATE INDEX IX_Portion_CookID ON dbo.Portion(CookID);
CREATE INDEX IX_Order_CustomerID ON dbo.[Order](CustomerID);
CREATE INDEX IX_OrderItem_OrderID ON dbo.OrderItem(OrderID);
CREATE INDEX IX_OrderItem_PortionID ON dbo.OrderItem(PortionID);
CREATE INDEX IX_Trip_CyclistID ON dbo.Trip(CyclistID);
CREATE INDEX IX_Trip_OrderID ON dbo.Trip(OrderID);
CREATE INDEX IX_TripStop_TripID ON dbo.TripStop(TripID);
CREATE INDEX IX_Rating_OrderID ON dbo.Rating(OrderID);
CREATE INDEX IX_Rating_CookID ON dbo.Rating(CookID);
CREATE INDEX IX_Rating_CyclistID ON dbo.Rating(CyclistID);
GO

-- Reset identity seeds for SQL Server 2022 Linux compatibility
DBCC CHECKIDENT ('dbo.Cook', RESEED, 0);
DBCC CHECKIDENT ('dbo.Cyclist', RESEED, 0);
DBCC CHECKIDENT ('dbo.Customer', RESEED, 0);
DBCC CHECKIDENT ('dbo.Portion', RESEED, 0);
DBCC CHECKIDENT ('dbo.[Order]', RESEED, 0);
DBCC CHECKIDENT ('dbo.OrderItem', RESEED, 0);
DBCC CHECKIDENT ('dbo.Trip', RESEED, 0);
DBCC CHECKIDENT ('dbo.TripStop', RESEED, 0);
DBCC CHECKIDENT ('dbo.Rating', RESEED, 0);
GO