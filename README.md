# Experience Share App - Backend

Web API and database for an experience-sharing platform that enables group trip planning with individual billing.

## Project Structure

```
├── src/
│   └── WebAPI/            # ASP.NET Core Web API
│       ├── Controllers/   # API endpoints
│       ├── Models/        # Data models
│       └── Dockerfile     # Container configuration
├── database/
│   ├── scripts/           # SQL scripts
│   │   ├── create_database.sql
│   │   ├── insert_data.sql
│   │   └── queries.sql
│   └── design/            # Database design docs
│       ├── er_diagram.svg
│       └── design_reasoning.md
├── docs/                  # Documentation
│   └── CLAUDE.md         # Claude Code guidance
└── README.md             # This file
```

## Running the Web API

### Local Development
```bash
cd src/WebAPI
dotnet run
```
Access at: http://localhost:5000/swagger

### Docker
```bash
cd src/WebAPI
docker build -t webapi .
docker run -p 8080:8080 webapi
```
Access at: http://localhost:8080/swagger

## API Endpoints

- `GET /api/experiences` - Returns list of available experiences (hardcoded)

### Response Format
```json
[
  {
    "name": "Night at Noah's Hotel Single room",
    "description": "Comfortable single room accommodation at Noah's Hotel",
    "price": 730
  }
]
```

## Database Setup

### SQL Server 2022
1. Create database: `CREATE DATABASE ExperienceShareDB`
2. Run scripts in order:
   - `database/scripts/create_database.sql` - Creates tables and relationships
   - `database/scripts/insert_data.sql` - Loads sample data
   - `database/scripts/queries.sql` - Example queries

### Database Schema

**Core Tables:**
- `Provider` - Service providers (hotels, airlines, tour operators)
- `Guest` - Users who organize or join experiences
- `Experience` - Individual services offered
- `SharedExperience` - Group trips/events
- `Booking` - Guest registrations for experiences
- `Discount` - Volume-based pricing tiers

## Requirements

- .NET 8.0 SDK
- SQL Server 2022 (for database)
- Docker (optional)