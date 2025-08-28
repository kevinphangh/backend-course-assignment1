-- Database schema for Experience Share App
-- SQL Server 2022 / Transact-SQL

-- Drop existing tables (in dependency order)
IF OBJECT_ID('dbo.Booking', 'U') IS NOT NULL DROP TABLE dbo.Booking;
IF OBJECT_ID('dbo.SharedExperienceItem', 'U') IS NOT NULL DROP TABLE dbo.SharedExperienceItem;
IF OBJECT_ID('dbo.SharedExperience', 'U') IS NOT NULL DROP TABLE dbo.SharedExperience;
IF OBJECT_ID('dbo.Discount', 'U') IS NOT NULL DROP TABLE dbo.Discount;
IF OBJECT_ID('dbo.Experience', 'U') IS NOT NULL DROP TABLE dbo.Experience;
IF OBJECT_ID('dbo.Guest', 'U') IS NOT NULL DROP TABLE dbo.Guest;
IF OBJECT_ID('dbo.Provider', 'U') IS NOT NULL DROP TABLE dbo.Provider;
GO

-- Provider: Businesses offering services
CREATE TABLE dbo.Provider (
    ProviderID INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(255) NOT NULL,
    Address NVARCHAR(500) NOT NULL,
    Phone NVARCHAR(50) NOT NULL,
    CVR NVARCHAR(20) NOT NULL  -- Danish business registration
);
GO

-- Guest: Platform users
CREATE TABLE dbo.Guest (
    GuestID INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(255) NOT NULL,
    Age INT NOT NULL CHECK (Age >= 18),  -- Adults only
    Phone NVARCHAR(50) NOT NULL,
    PersonalID NVARCHAR(50) NOT NULL UNIQUE  -- Prevent duplicates
);
GO

-- Experience: Services offered by providers
CREATE TABLE dbo.Experience (
    ExperienceID INT IDENTITY(1,1) PRIMARY KEY,
    ProviderID INT NOT NULL,
    Name NVARCHAR(255) NOT NULL,
    Description NVARCHAR(1000),
    Price DECIMAL(10,2) NOT NULL CHECK (Price >= 0),  -- Required decimal type for money
    CONSTRAINT FK_Experience_Provider FOREIGN KEY (ProviderID) 
        REFERENCES dbo.Provider(ProviderID) ON DELETE CASCADE
);
GO

-- SharedExperience: Group trips/events
CREATE TABLE dbo.SharedExperience (
    SharedExperienceID INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(255) NOT NULL,
    Date DATE NOT NULL,
    OrganizerID INT NOT NULL,
    CONSTRAINT FK_SharedExperience_Organizer FOREIGN KEY (OrganizerID) 
        REFERENCES dbo.Guest(GuestID)
);
GO

-- SharedExperienceItem: Links experiences to trips (M:N junction)
CREATE TABLE dbo.SharedExperienceItem (
    SharedExperienceItemID INT IDENTITY(1,1) PRIMARY KEY,
    SharedExperienceID INT NOT NULL,
    ExperienceID INT NOT NULL,
    CONSTRAINT FK_SEItem_SharedExperience FOREIGN KEY (SharedExperienceID) 
        REFERENCES dbo.SharedExperience(SharedExperienceID) ON DELETE CASCADE,
    CONSTRAINT FK_SEItem_Experience FOREIGN KEY (ExperienceID) 
        REFERENCES dbo.Experience(ExperienceID) ON DELETE CASCADE,
    CONSTRAINT UQ_SharedExperienceItem UNIQUE (SharedExperienceID, ExperienceID)
);
GO

-- Booking: Guest registrations for experiences (M:N junction)
CREATE TABLE dbo.Booking (
    BookingID INT IDENTITY(1,1) PRIMARY KEY,
    GuestID INT NOT NULL,
    SharedExperienceItemID INT NOT NULL,
    BookingDate DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Booking_Guest FOREIGN KEY (GuestID) 
        REFERENCES dbo.Guest(GuestID) ON DELETE CASCADE,
    CONSTRAINT FK_Booking_SEItem FOREIGN KEY (SharedExperienceItemID) 
        REFERENCES dbo.SharedExperienceItem(SharedExperienceItemID) ON DELETE CASCADE,
    CONSTRAINT UQ_Booking UNIQUE (GuestID, SharedExperienceItemID)  -- No duplicate bookings
);
GO

-- Discount: Volume-based pricing
CREATE TABLE dbo.Discount (
    DiscountID INT IDENTITY(1,1) PRIMARY KEY,
    ProviderID INT NOT NULL,
    MinGuests INT NOT NULL CHECK (MinGuests > 0),
    DiscountPercentage DECIMAL(5,2) NOT NULL CHECK (DiscountPercentage >= 0 AND DiscountPercentage <= 100),
    CONSTRAINT FK_Discount_Provider FOREIGN KEY (ProviderID) 
        REFERENCES dbo.Provider(ProviderID) ON DELETE CASCADE
);
GO

-- Create indexes for foreign keys (improves JOIN performance)
CREATE INDEX IX_Experience_ProviderID ON dbo.Experience(ProviderID);
CREATE INDEX IX_SharedExperience_OrganizerID ON dbo.SharedExperience(OrganizerID);
CREATE INDEX IX_SharedExperienceItem_SharedExperienceID ON dbo.SharedExperienceItem(SharedExperienceID);
CREATE INDEX IX_SharedExperienceItem_ExperienceID ON dbo.SharedExperienceItem(ExperienceID);
CREATE INDEX IX_Booking_GuestID ON dbo.Booking(GuestID);
CREATE INDEX IX_Booking_SharedExperienceItemID ON dbo.Booking(SharedExperienceItemID);
CREATE INDEX IX_Discount_ProviderID ON dbo.Discount(ProviderID);
GO

PRINT 'Database schema created successfully!';