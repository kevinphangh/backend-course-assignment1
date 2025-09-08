# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

### Build and Run
```bash
# Build the entire solution
dotnet build

# Clean build artifacts before submission
dotnet clean

# Run the Web API locally
cd src/WebAPI
dotnet run
# API available at: http://localhost:5097/swagger

# Build and run with Docker
cd src/WebAPI
docker build -t experience-share-api .
docker run -p 8080:8080 experience-share-api
# API available at: http://localhost:8080/swagger

# Run both SQL Server and Web API with Docker Compose
docker compose up -d       # Start services with persistent storage
docker compose down         # Stop services (data persists)
docker compose down -v      # Stop and delete all data
docker compose logs -f      # View logs (Ctrl+C to exit)
```

### Database Operations
```bash
# Initialize database in Docker container
docker cp database/scripts/create_database.sql experience-sqlserver:/tmp/
docker cp database/scripts/insert_data.sql experience-sqlserver:/tmp/

docker exec experience-sqlserver /opt/mssql-tools18/bin/sqlcmd \
  -S localhost -U sa -P YourStrong@Passw0rd123 -C \
  -Q "CREATE DATABASE ExperienceShareDB"

docker exec experience-sqlserver /opt/mssql-tools18/bin/sqlcmd \
  -S localhost -U sa -P YourStrong@Passw0rd123 -C \
  -d ExperienceShareDB -i /tmp/create_database.sql

docker exec experience-sqlserver /opt/mssql-tools18/bin/sqlcmd \
  -S localhost -U sa -P YourStrong@Passw0rd123 -C \
  -d ExperienceShareDB -i /tmp/insert_data.sql

# Test queries
docker exec experience-sqlserver /opt/mssql-tools18/bin/sqlcmd \
  -S localhost -U sa -P YourStrong@Passw0rd123 -C \
  -d ExperienceShareDB -i /tmp/queries.sql
```

### Submission Preparation
```bash
# Create submission package for SW4BAD Assignment 1
chmod +x prepare_submission.sh
./prepare_submission.sh au123456  # Replace with actual AU ID
# Creates: sw4bad-mas1-au123456.zip
```

## Architecture Overview

This is an ASP.NET Core 8.0 Web API for an experience-sharing platform implementing SW4BAD Assignment 1. The system enables group trip planning with individual bookings and volume-based discounts.

### Core Components

1. **Web API** (`src/WebAPI/`)
   - Single endpoint: `GET /api/experiences` returns hardcoded experience list
   - Controller: `ExperiencesController.cs` with 3 dummy experiences (lines 14-31)
   - Model: `Experience.cs` with Name, Description, and nullable decimal Price
   - Multi-stage Dockerfile optimized for production deployment

2. **Database Schema** (`database/scripts/`)
   - 7 tables in Third Normal Form (3NF): Provider, Guest, Experience, SharedExperience, SharedExperienceItem, Booking, Discount
   - Junction tables enable selective participation in group experiences
   - All foreign keys indexed for JOIN performance
   - CASCADE DELETE maintains referential integrity
   - Check constraints: Age≥18, Price≥0, Discount 0-100%

3. **Container Orchestration** (`docker-compose.yml`)
   - SQL Server 2022 on port 1433 with health checks
   - Web API on port 8080 (depends on SQL Server)
   - Persistent data volume `sqldata` survives container restarts

### Key Design Decisions

- **No Database Connection**: API returns hardcoded data per assignment Part A requirements. Connection string present in docker-compose.yml but not implemented in code.
- **Chen Notation ERD**: Academic-style entity-relationship diagram in `database/design/ERD.png`
- **0-Based Identity Values**: SQL Server 2022 Linux behavior - `DBCC CHECKIDENT` with `RESEED, 0` starts IDs at 0, not 1
- **Decimal Precision**: API uses `decimal?` to match database `DECIMAL(10,2)` for monetary values

## SQL Server 2022 Linux Specifics

**Critical**: When running on Linux/Docker, identity columns start at 0 after RESEED:
- ProviderID: 0-4 (not 1-5)
- GuestID: 0-7 (not 1-8)
- All other IDs follow 0-based indexing

**sqlcmd Path**: Use `/opt/mssql-tools18/bin/sqlcmd` with `-C` flag for certificate trust

## Assignment Status

- ✅ Part A: Web API with `/api/experiences` endpoint
- ✅ Part B: Multi-stage Dockerfile  
- ✅ Part C: Database design with ERD and 10 queries
- ⚠️ Part D: Docker Compose configured but SQL connection not implemented in API