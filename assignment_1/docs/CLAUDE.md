# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

### Build and Run
```bash
# Build the entire solution from root
dotnet build

# Clean build artifacts
dotnet clean

# Run the Web API locally
cd src/WebAPI
dotnet run
# API will be available at: http://localhost:5000/swagger

# Run with Docker
cd src/WebAPI
docker build -t webapi .
docker run -p 8080:8080 webapi
# API will be available at: http://localhost:8080/swagger
```

### Submission Preparation
```bash
# Create submission package for SW4BAD Assignment 1
./prepare_submission.sh au123456  # Replace with actual AU ID
```

### Database Setup
```bash
# SQL Server 2022 required (use -C flag for certificate trust)
# 1. Create database
sqlcmd -S localhost -C -Q "CREATE DATABASE ExperienceShareDB"

# 2. Run scripts in order
sqlcmd -S localhost -C -d ExperienceShareDB -i database/scripts/create_database.sql
sqlcmd -S localhost -C -d ExperienceShareDB -i database/scripts/insert_data.sql
sqlcmd -S localhost -C -d ExperienceShareDB -i database/scripts/queries.sql

# For Docker containers:
docker exec experience-sqlserver /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P YourStrong@Passw0rd123 -C -d ExperienceShareDB -i /scripts/create_database.sql
```

## Architecture Overview

This is an ASP.NET Core Web API project for an experience-sharing platform that enables group trip planning with individual billing. The system has a 3-tier architecture.

### ⚠️ Critical SQL Server 2022 Linux Notes

**IDENTITY Behavior**: On SQL Server 2022 Linux, `DBCC CHECKIDENT ('table', RESEED, 0)` causes the next identity value to be 0, not 1. All IDs in `insert_data.sql` are adjusted for 0-based indexing:
- ProviderID: 0-4 (not 1-5)
- GuestID: 0-7 (not 1-8)  
- ExperienceID: starts from 0
- SharedExperienceID: 0-2 (not 1-3)

**sqlcmd Path**: Use `/opt/mssql-tools18/bin/sqlcmd` with `-C` flag (not `/opt/mssql-tools/bin/sqlcmd`)

**Data Types**: API models use `decimal?` for Price to match database `DECIMAL(10,2)` type

1. **Web API Layer** (`src/WebAPI/`): ASP.NET Core 8.0 Web API with Swagger documentation
   - Controllers handle HTTP requests
   - Models define data transfer objects
   - Currently returns hardcoded data (no database connection implemented)

2. **Database Layer**: Microsoft SQL Server 2022 schema with 7 tables
   - Core entities: Provider, Guest, Experience, SharedExperience
   - Junction tables: SharedExperienceItem (M:N between SharedExperience and Experience), Booking (Guest registrations)
   - Support table: Discount (volume-based pricing)
   - All foreign keys are indexed for performance
   - Uses DECIMAL(10,2) for monetary values

3. **Container Layer**: Multi-stage Docker build optimized for size (SDK→Publish→Runtime)

## Key Design Decisions

- **Hardcoded Data**: The API currently returns hardcoded experiences from `ExperiencesController`. Database integration is prepared but not connected.
- **Chen Notation ER Diagram**: Database design documented in `database/design/er_diagram.svg` using academic Chen notation
- **Junction Tables**: Explicit junction tables (SharedExperienceItem, Booking) allow selective participation in M:N relationships
- **No Authentication**: Simplified for academic assignment - production would need auth/authz

## API Endpoint

- `GET /api/experiences` - Returns list of available experiences (currently hardcoded in ExperiencesController.cs:14-31)
  - Price values are decimals: 730.50, 910.99, 100.00
  - Model uses `decimal?` for nullable decimal prices
  - Properties use `required` modifier to avoid nullable warnings

## Project Structure

```
src/WebAPI/
├── Controllers/ExperiencesController.cs  # API endpoint (hardcoded data)
├── Models/Experience.cs                  # Data model
├── Program.cs                            # Application startup
├── WebAPI.csproj                        # Project configuration
└── Dockerfile                           # Container definition (multi-stage)
```

Database scripts:
- `database/scripts/create_database.sql` - Schema creation with constraints and indexes
- `database/scripts/insert_data.sql` - Sample data for testing (0-based IDs for SQL Server 2022 Linux)
- `database/scripts/queries.sql` - Example queries demonstrating business logic

## Common Issues & Solutions

### Foreign Key Constraint Violations During Insert
- **Cause**: IDs in insert script don't match actual IDENTITY values on SQL Server 2022 Linux
- **Solution**: insert_data.sql uses 0-based IDs (ProviderID 0-4, GuestID 0-7, etc.)

### Empty Junction Tables (SharedExperienceItem, Booking)
- **Cause**: FK references using wrong ID ranges
- **Solution**: Fixed in insert_data.sql to use correct 0-based IDs

### Docker Healthcheck Fails
- **Cause**: Wrong sqlcmd path in docker-compose.yml
- **Solution**: Use `/opt/mssql-tools18/bin/sqlcmd` with `-C` flag

### Build Warnings CS8618
- **Cause**: Non-nullable properties without default values
- **Solution**: Properties marked with `required` modifier in Experience.cs