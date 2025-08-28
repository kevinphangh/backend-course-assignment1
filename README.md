# SW4BAD Assignment 1: WebAPI and Data Modelling

Experience Share App - A decentralized platform for organizing group experiences with individual booking responsibilities and volume-based discounts.

## Assignment Components

### ✅ Part A: Web API Prototype
- ASP.NET Core 8.0 Web API with `/api/experiences` endpoint
- Returns JSON array of Experience objects with Name, Description, and nullable Price
- Swagger UI enabled for testing
- Three hardcoded dummy experiences

### ✅ Part B: Containerization  
- Multi-stage Dockerfile for optimized container builds
- Runs on port 8080 in container environment
- Build command: `docker build -t webapi .`

### ✅ Part C: Database Design
- Seven-table relational schema in Third Normal Form (3NF)
- Chen notation Entity-Relationship Diagram (ERD.png)
- Transact-SQL compatible with SQL Server 2022
- Implements all 10 required queries
- Comprehensive design reasoning document

### ❌ Part D: Extra (Optional)
- SQL connection endpoints not implemented
- Docker Compose not configured

## Project Structure

```
backend-course/
├── src/
│   └── WebAPI/
│       ├── Controllers/
│       │   └── ExperiencesController.cs    # API endpoint
│       ├── Models/
│       │   └── Experience.cs               # POCO class
│       ├── Program.cs                      # App configuration
│       ├── Dockerfile                      # Multi-stage build
│       └── WebAPI.csproj                   # Project file
├── database/
│   ├── scripts/
│   │   ├── create_database.sql            # Schema definition
│   │   ├── insert_data.sql                # Sample data
│   │   └── queries.sql                    # 10 required queries
│   ├── ERD.png                            # Chen notation diagram
│   └── design_reasoning.md                # Design documentation
└── prepare_submission.sh                   # Submission packager
```

## Quick Start

### Running the Web API

```bash
# Build and run locally
cd src/WebAPI
dotnet build
dotnet run

# API available at http://localhost:5XXX/swagger
```

### Docker Deployment

```bash
cd src/WebAPI
docker build -t experience-share-api .
docker run -p 8080:8080 experience-share-api

# Swagger UI at http://localhost:8080/swagger
```

### Database Setup

```sql
-- 1. Create database
CREATE DATABASE ExperienceShareDB;
GO
USE ExperienceShareDB;
GO

-- 2. Execute scripts in order
-- Run: database/scripts/create_database.sql
-- Run: database/scripts/insert_data.sql  
-- Run: database/scripts/queries.sql (for testing)
```

## API Specification

### GET /api/experiences

Returns available experiences as JSON array.

**Response Example:**
```json
[
  {
    "name": "Night at Noah's Hotel Single room",
    "description": "Comfortable single room accommodation at Noah's Hotel",
    "price": 730
  },
  {
    "name": "Night at Noah's Hotel Double room",
    "description": "Spacious double room accommodation at Noah's Hotel", 
    "price": 910
  },
  {
    "name": "Vienna Historic Center Walking Tour",
    "description": "Guided walking tour through Vienna's historic center",
    "price": 100
  }
]
```

## Database Schema

### Core Entities
- **Provider**: Businesses with CVR, address, phone
- **Guest**: Users (18+) with PersonalID, name, phone
- **Experience**: Services with DECIMAL(10,2) prices
- **SharedExperience**: Group events with organizer and date
- **SharedExperienceItem**: Junction table for experience composition
- **Booking**: Individual reservations with unique constraints
- **Discount**: Volume-based pricing tiers (e.g., 10% at 10 guests)

### Key Features
- CASCADE DELETE maintains referential integrity
- Seven indexes optimize JOIN performance
- Unique constraints prevent duplicate bookings
- Check constraints ensure data validity (age ≥18, price ≥0)

## Building for Submission

### Clean and Prepare

```bash
# Clean solution before submission
cd src/WebAPI
dotnet clean

# Create submission package
cd ../..
chmod +x prepare_submission.sh
./prepare_submission.sh au123456  # Replace with your AU ID

# Creates: sw4bad-mas1-au123456.zip
```

### Submission Package Contents
- `WebAPI/` - Cleaned .NET solution (no bin/obj)
- `create_database.sql` - Database schema
- `insert_data.sql` - Sample data
- `queries.sql` - Required queries
- `ERD.png` - Chen notation diagram  
- `design_reasoning.md` - Design documentation

### Pre-Submission Checklist
- [ ] Web API builds without errors
- [ ] Swagger UI displays Experiences endpoint
- [ ] Docker image builds successfully
- [ ] All 10 SQL queries execute correctly
- [ ] ERD uses Chen notation (not UML/Crow's Foot)
- [ ] Design reasoning is single-page PDF (if required)
- [ ] Solution cleaned (no bin/obj folders)
- [ ] Zip file named correctly: `sw4bad-mas1-<au-id>.zip`

## Technical Requirements

- .NET 8.0 SDK
- Docker (for containerization)
- SQL Server 2022 or Azure Data Studio (for database)
- Visual Studio 2022 or VS Code (recommended)

## Important Notes

1. **Grading**: Assignment must be approved (grade 1) or course is "Ikke bestået"
2. **Deadline**: Submit before deadline - late submissions receive grade 0
3. **Demo Day**: Be prepared to run solution and explain any part
4. **File Format**: Submit as .zip only (not .rar, .7z, etc.)

## Support

For questions about the assignment requirements, contact course instructors well in advance of the deadline.