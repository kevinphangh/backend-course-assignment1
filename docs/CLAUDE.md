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
# SQL Server 2022 required
# 1. Create database
sqlcmd -S localhost -Q "CREATE DATABASE ExperienceShareDB"

# 2. Run scripts in order
sqlcmd -S localhost -d ExperienceShareDB -i database/scripts/create_database.sql
sqlcmd -S localhost -d ExperienceShareDB -i database/scripts/insert_data.sql
sqlcmd -S localhost -d ExperienceShareDB -i database/scripts/queries.sql
```

## Architecture Overview

This is an ASP.NET Core Web API project for an experience-sharing platform that enables group trip planning with individual billing. The system has a 3-tier architecture:

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

- `GET /api/experiences` - Returns list of available experiences (currently hardcoded in ExperiencesController.cs:10-30)

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
- `database/scripts/insert_data.sql` - Sample data for testing
- `database/scripts/queries.sql` - Example queries demonstrating business logic