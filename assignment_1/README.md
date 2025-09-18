# Local Food Delivery API

A REST API for a food delivery platform that connects home kitchen cooks with customers through cyclist delivery services.

## Quick Start

### Using Docker Compose (Recommended)
```bash
# Start API and Database
docker compose up -d

# API available at: http://localhost:8080/api/Menu
# Swagger UI: http://localhost:8080/swagger
```

### Local Development
```bash
cd src/WebAPI
dotnet run

# API available at: http://localhost:5097/api/Menu
# Swagger UI: http://localhost:5097/swagger
```

## Project Structure

```
assignment_1/
├── src/
│   └── WebAPI/                 # ASP.NET Core 8.0 Web API
│       ├── Controllers/        # API endpoints
│       ├── Models/            # Data models
│       ├── Dockerfile         # Multi-stage container build
│       └── Program.cs         # Application entry point
├── database/
│   ├── scripts/               # SQL scripts
│   │   ├── create_database.sql
│   │   ├── insert_data.sql
│   │   └── queries.sql
│   └── design/
│       └── ERD.png           # Database design diagram
├── docs/                      # Documentation
│   ├── assignment/           # Assignment files
│   └── checklist-answers/    # Exam preparation
├── submission/                # Submission package files
└── docker-compose.yml         # Container orchestration
```

## API Endpoint

### GET /api/Menu
Returns available dishes from local kitchens.

**Response:**
```json
[
  { "name": "Group42", "price": 75 },
  { "name": "Spaghetti Carbonara", "price": 89 },
  { "name": "Caesar Salad", "price": 65 }
]
```

## Database Setup

After starting containers with `docker compose up -d`:

```bash
# Create database
docker exec localfood-sqlserver /opt/mssql-tools18/bin/sqlcmd \
  -S localhost -U sa -P MyP@ssw0rd2024! -C \
  -Q "CREATE DATABASE LocalFoodDB"

# Run schema script
docker exec localfood-sqlserver /opt/mssql-tools18/bin/sqlcmd \
  -S localhost -U sa -P MyP@ssw0rd2024! -C \
  -d LocalFoodDB -i /scripts/create_database.sql

# Insert sample data
docker exec localfood-sqlserver /opt/mssql-tools18/bin/sqlcmd \
  -S localhost -U sa -P MyP@ssw0rd2024! -C \
  -d LocalFoodDB -i /scripts/insert_data.sql
```

## Tech Stack

- **Framework:** ASP.NET Core 8.0
- **Database:** SQL Server 2022
- **Containerization:** Docker (multi-stage build)
- **API Documentation:** Swagger/OpenAPI
- **Architecture:** RESTful API

## Database Schema

9 tables modeling a food delivery system:
- **Users:** Cook, Customer, Cyclist
- **Business:** Portion, Order, OrderItem
- **Delivery:** Trip, TripStop
- **Feedback:** Rating

## Docker Commands

```bash
# View logs
docker compose logs -f

# Stop services
docker compose down

# Stop and remove data
docker compose down -v

# Check container status
docker ps
```

## Requirements

- .NET 8.0 SDK (local development)
- Docker & Docker Compose (containerized deployment)
- 4GB RAM minimum (for SQL Server)

---

*SW4BAD Assignment 1 - Backend Development Course*