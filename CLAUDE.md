# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

### Build and Run
```bash
# Build entire solution
dotnet build

# Run the Web API
cd assignment_1/src/WebAPI
dotnet run
# API available at: http://localhost:5000/swagger

# Run with Docker
cd assignment_1/src/WebAPI
docker build -t webapi .
docker run -p 8080:8080 webapi
# API available at: http://localhost:8080/swagger
```

### Submission Preparation
```bash
cd assignment_1
./prepare_submission.sh au123456  # Replace with actual AU ID
# Creates: sw4bad-mas1-au123456.zip
```

### Database Operations
```bash
# SQL Server 2022 required
# Create database (use -C flag for certificate trust)
sqlcmd -S localhost -C -Q "CREATE DATABASE ExperienceShareDB"

# Run scripts in order from assignment_1/database/scripts/
sqlcmd -S localhost -C -d ExperienceShareDB -i create_database.sql
sqlcmd -S localhost -C -d ExperienceShareDB -i insert_data.sql
sqlcmd -S localhost -C -d ExperienceShareDB -i queries.sql

# In Docker container use:
docker exec experience-sqlserver /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P YourStrong@Passw0rd123 -C -d ExperienceShareDB -i /scripts/create_database.sql
```

## Architecture Overview

ASP.NET Core 8.0 Web API for SW4BAD Assignment 1 - an experience-sharing platform enabling group trip planning with individual billing and volume discounts.

### ⚠️ Critical SQL Server 2022 Linux Notes

**IDENTITY Behavior**: On SQL Server 2022 Linux, `DBCC CHECKIDENT ('table', RESEED, 0)` causes the next identity value to be 0, not 1. All IDs in `insert_data.sql` are adjusted for 0-based indexing:
- ProviderID: 0-4 (not 1-5)
- GuestID: 0-7 (not 1-8)  
- ExperienceID: starts from 0
- SharedExperienceID: 0-2 (not 1-3)

**sqlcmd Path**: Use `/opt/mssql-tools18/bin/sqlcmd` with `-C` flag (not `/opt/mssql-tools/bin/sqlcmd`)

### Key Components

1. **Web API** (`assignment_1/src/WebAPI/`)
   - ASP.NET Core 8.0 with Swagger documentation
   - Single endpoint: `GET /api/experiences` returns hardcoded data (ExperiencesController.cs:14-31)
   - Models use `decimal?` for Price to match database `DECIMAL(10,2)` type
   - Properties marked as `required` to avoid nullable warnings
   - No database connection implemented (returns dummy data: 730.50, 910.99, 100.00)
   - Multi-stage Docker build for optimized containers

2. **Database Design** (`assignment_1/database/`)
   - SQL Server 2022 relational schema in Third Normal Form (3NF)
   - 7 tables: Provider, Guest, Experience, SharedExperience, SharedExperienceItem (M:N junction), Booking (registrations), Discount (volume pricing)
   - Chen notation ERD in database/design/ERD.png
   - All monetary values use DECIMAL(10,2)
   - Foreign keys indexed for performance
   - CASCADE DELETE for referential integrity

### Important Notes

- **Hardcoded API**: ExperiencesController returns static data - database integration prepared but not connected
- **No Authentication**: Simplified for academic assignment
- **Junction Tables**: Explicit M:N relationships allow selective participation (SharedExperienceItem, Booking)
- **Age Constraint**: Guests must be 18+ (CHECK constraint in database)
- **Unique Bookings**: Constraint prevents duplicate Guest-SharedExperience pairs

## API Endpoint

`GET /api/experiences` - Returns list of available experiences with Name, Description, and nullable decimal Price fields

## Common Issues & Solutions

### Foreign Key Constraint Violations
- **Cause**: IDs in insert script don't match actual IDENTITY values
- **Solution**: Ensure IDs start from 0 on SQL Server 2022 Linux

### Empty Junction Tables (SharedExperienceItem, Booking)
- **Cause**: FK references use wrong IDs
- **Solution**: Use 0-based IDs in insert_data.sql

### Data Type Precision Loss
- **Cause**: Using `int?` instead of `decimal?` for prices
- **Solution**: Use `decimal?` in C# models to match `DECIMAL(10,2)` in database

### Docker Healthcheck Fails
- **Cause**: Wrong sqlcmd path in docker-compose.yml
- **Solution**: Use `/opt/mssql-tools18/bin/sqlcmd` with `-C` flag