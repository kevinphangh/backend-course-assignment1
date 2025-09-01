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
│   └── design/
│       ├── ERD.png                        # Chen notation diagram
│       └── design_reasoning.md            # Design documentation
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

```bash
# Using Docker container
docker exec experience-sqlserver /opt/mssql-tools18/bin/sqlcmd \
  -S localhost -U sa -P YourStrong@Passw0rd123 -C \
  -Q "CREATE DATABASE ExperienceShareDB"

docker exec experience-sqlserver /opt/mssql-tools18/bin/sqlcmd \
  -S localhost -U sa -P YourStrong@Passw0rd123 -C \
  -d ExperienceShareDB -i /scripts/create_database.sql

docker exec experience-sqlserver /opt/mssql-tools18/bin/sqlcmd \
  -S localhost -U sa -P YourStrong@Passw0rd123 -C \
  -d ExperienceShareDB -i /scripts/insert_data.sql

# Or using local SQL Server
sqlcmd -S localhost -C -Q "CREATE DATABASE ExperienceShareDB"
sqlcmd -S localhost -C -d ExperienceShareDB -i database/scripts/create_database.sql
sqlcmd -S localhost -C -d ExperienceShareDB -i database/scripts/insert_data.sql
sqlcmd -S localhost -C -d ExperienceShareDB -i database/scripts/queries.sql
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
    "price": 730.5
  },
  {
    "name": "Night at Noah's Hotel Double room",
    "description": "Spacious double room accommodation at Noah's Hotel", 
    "price": 910.99
  },
  {
    "name": "Vienna Historic Center Walking Tour",
    "description": "Guided walking tour through Vienna's historic center",
    "price": 100.0
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
# Optional: Clean build outputs (removes most build artifacts)
cd src/WebAPI
dotnet clean

# Create submission package (handles complete cleanup automatically)
cd ../..
chmod +x prepare_submission.sh
./prepare_submission.sh au123456  # Replace with your AU ID

# Creates: sw4bad-mas1-au123456.zip
```

### Submission Package Contents
- `WebAPI/` - Cleaned .NET solution (bin/obj directories removed)
- `create_database.sql` - Database schema
- `insert_data.sql` - Sample data
- `queries.sql` - Required queries
- `ERD.png` - Chen notation diagram  
- `design_reasoning.md` - Design documentation

**Note:** The submission script automatically:
1. Runs `dotnet clean` to remove most build artifacts
2. Copies all required files to a temporary directory
3. Completely removes bin/obj directories using `rm -rf`
4. Creates a properly named zip file for Brightspace submission

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

## Important SQL Server 2022 Linux Notes

When running on SQL Server 2022 Linux (including Docker containers):
- **IDENTITY columns**: `DBCC CHECKIDENT` with `RESEED, 0` starts IDs from 0, not 1
- **sqlcmd path**: Use `/opt/mssql-tools18/bin/sqlcmd` (not `/opt/mssql-tools/bin/sqlcmd`)
- **Certificate flag**: Always use `-C` flag with sqlcmd for certificate trust
- **Data types**: API models use `decimal?` to match database `DECIMAL(10,2)` for prices

## Important Notes

1. **Grading**: Assignment must be approved (grade 1) or course is "Ikke bestået"
2. **Deadline**: Submit before deadline - late submissions receive grade 0
3. **Demo Day**: Be prepared to run solution and explain any part
4. **File Format**: Submit as .zip only (not .rar, .7z, etc.)

## About `dotnet clean`

The `dotnet clean` command removes most build artifacts but may leave some files in bin/obj directories. The prepare_submission.sh script handles this by:
- First running `dotnet clean` to remove compiled binaries
- Then using `rm -rf` to completely remove bin and obj directories
- This ensures the submission package is fully cleaned

## Support

For questions about the assignment requirements, contact course instructors well in advance of the deadline.