# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Local Food Delivery App backend built with ASP.NET Core 8.0 Web API and SQL Server 2022. It's a university assignment (SW4BAD Assignment 1) implementing a platform that connects home kitchen cooks with customers through cyclist delivery services.

## Essential Commands

### Building and Running

```bash
# Build the project
cd src/WebAPI
dotnet build

# Run locally (Swagger UI at http://localhost:5097/swagger)
dotnet run

# Clean build artifacts
dotnet clean
```

### Docker Operations

```bash
# Build Docker image
cd src/WebAPI
docker build -t kevinphangh/local-food-api:latest .

# Run with Docker Compose (includes SQL Server)
docker compose up -d

# Stop services
docker compose down

# View logs
docker compose logs -f
```

### Database Setup

```bash
# After starting containers, initialize database
docker exec localfood-sqlserver /opt/mssql-tools18/bin/sqlcmd \
  -S localhost -U sa -P YourStrong@Passw0rd123 -C \
  -Q "CREATE DATABASE LocalFoodDB"

# Run schema creation script
docker exec localfood-sqlserver /opt/mssql-tools18/bin/sqlcmd \
  -S localhost -U sa -P YourStrong@Passw0rd123 -C \
  -d LocalFoodDB -i /tmp/create_database.sql
```

### Submission Packaging

```bash
# Create submission zip
chmod +x prepare_submission.sh
./prepare_submission.sh AU778738
```

## Architecture

### API Structure
- **Entry Point**: `src/WebAPI/Program.cs` - Minimal API configuration with Swagger
- **Controller**: `src/WebAPI/Controllers/MenuController.cs` - Single `/api/menu` endpoint returning hardcoded dishes
- **Model**: `src/WebAPI/Models/Dish.cs` - POCO with Name (string) and Price (nullable int)
- **Configuration**: Uses default ASP.NET Core conventions, Swagger enabled on all environments

### Database Design
- **9 Tables**: Cook, Cyclist, Customer, Portion, Order, OrderItem, Trip, TripStop, Rating
- **Key Features**:
  - TIME datatype for portion availability (recurring daily windows)
  - Nullable ratings for food and delivery (1-5 stars)
  - TripStop pattern for multi-location deliveries
  - CASCADE DELETE on Cook→Portion and Customer→Order relationships
- **SQL Scripts Location**: `database/scripts/` contains schema, data, and queries

### Docker Architecture
- **Multi-stage Dockerfile**: SDK for build, runtime-deps for execution
- **Docker Compose**: SQL Server on port 1433, Web API on port 8080
- **Networking**: Internal bridge network for container communication
- **Data Persistence**: Named volume `sqldata` for SQL Server data

## Assignment Requirements

This codebase fulfills 4 parts:
- **Part A**: Web API with `/api/menu` endpoint (first dish named "Group42")
- **Part B**: Containerized with Dockerfile
- **Part C**: Published to Docker Hub as `kevinphangh/local-food-api:latest`
- **Part D**: Database design with Chen notation ERD and 7 required queries

## Important Notes

- No test framework configured - assignment doesn't require tests
- No linting/formatting tools configured beyond default .NET conventions
- SQL Server 2022 on Linux uses `/opt/mssql-tools18/bin/sqlcmd` with `-C` flag
- IDENTITY columns in SQL Server 2022 Linux start from 0 when using `DBCC CHECKIDENT` with `RESEED, 0`
- Assignment requires Chen notation for ERD (not UML or Crow's Foot)