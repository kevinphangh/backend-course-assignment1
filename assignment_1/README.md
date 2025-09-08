# SW4BAD Assignment 1: WebAPI and Data Modelling

Local Food Delivery App - A platform connecting home kitchen cooks with customers through cyclist delivery services.

## Assignment Components

### ✅ Part A: Web API Prototype
- ASP.NET Core 8.0 Web API with `/api/menu` endpoint
- Returns JSON array of Dish objects with Name and nullable Price (int?)
- Swagger UI enabled for testing
- Three hardcoded dummy dishes (first dish named "Group42")

### ✅ Part B: Containerization  
- Multi-stage Dockerfile for optimized container builds
- Runs on port 8080 in container environment
- Build command: `docker build -t webapi .`

### ✅ Part C: Docker Hub Integration
- Docker Compose configured to pull from Docker Hub
- Image: `youruser/local-food-api:latest`
- Publish command: `docker push youruser/local-food-api:latest`

### ✅ Part D: Database Design
- Nine-table relational schema for food delivery system
- Core tables: Cook, Cyclist, Customer, Portion, Order, OrderItem, Trip, TripStop, Rating
- Uses TIME datatype for portion availability intervals
- Implements all 7 required queries plus additional queries
- Chen notation Entity-Relationship Diagram

## Docker Compose Configuration

The `docker-compose.yml` file provides:
- **SQL Server 2022**: Port 1433, persistent data volume
- **Web API**: Port 8080, pulls from Docker Hub
- **Network**: Internal bridge network for container communication
- **Health Check**: Ensures SQL Server is ready before starting API
- **Data Persistence**: Named volume `sqldata` survives container restarts

Check container status:
```bash
docker ps                    # View running containers
docker compose logs -f       # View logs (Ctrl+C to exit)
docker compose down          # Stop all services
docker compose down -v       # Stop and delete data volume
```

## Project Structure

```
backend-course/
├── src/
│   └── WebAPI/
│       ├── Controllers/
│       │   └── MenuController.cs           # API endpoint
│       ├── Models/
│       │   └── Dish.cs                     # POCO class
│       ├── Program.cs                      # App configuration
│       ├── Dockerfile                      # Multi-stage build
│       └── WebAPI.csproj                   # Project file
├── database/
│   ├── scripts/
│   │   ├── create_database.sql            # Schema definition
│   │   ├── insert_data.sql                # Sample data
│   │   └── queries.sql                    # 7 required queries
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

# API available at http://localhost:5097/swagger
```

### Docker Deployment

#### Option 1: Docker Compose (Recommended)

```bash
# Start both SQL Server and Web API
docker compose up -d

# Services available at:
# - SQL Server: localhost:1433
# - Web API: http://localhost:8080/swagger

# Stop services (data persists)
docker compose down

# Stop and remove data
docker compose down -v
```

#### Option 2: Build and Push to Docker Hub

```bash
# Build the image
cd src/WebAPI
docker build -t youruser/local-food-api:latest .

# Push to Docker Hub (requires login)
docker login
docker push youruser/local-food-api:latest
```

### Database Setup

After starting containers, initialize the database:

```bash
# Copy scripts to container
docker cp database/scripts/create_database.sql localfood-sqlserver:/tmp/
docker cp database/scripts/insert_data.sql localfood-sqlserver:/tmp/
docker cp database/scripts/queries.sql localfood-sqlserver:/tmp/

# Create database
docker exec localfood-sqlserver /opt/mssql-tools18/bin/sqlcmd \
  -S localhost -U sa -P YourStrong@Passw0rd123 -C \
  -Q "CREATE DATABASE LocalFoodDB"

# Create schema
docker exec localfood-sqlserver /opt/mssql-tools18/bin/sqlcmd \
  -S localhost -U sa -P YourStrong@Passw0rd123 -C \
  -d LocalFoodDB -i /tmp/create_database.sql

# Insert sample data
docker exec localfood-sqlserver /opt/mssql-tools18/bin/sqlcmd \
  -S localhost -U sa -P YourStrong@Passw0rd123 -C \
  -d LocalFoodDB -i /tmp/insert_data.sql

# Test queries
docker exec localfood-sqlserver /opt/mssql-tools18/bin/sqlcmd \
  -S localhost -U sa -P YourStrong@Passw0rd123 -C \
  -d LocalFoodDB -i /tmp/queries.sql
```

## API Specification

### GET /api/menu

Returns available dishes as JSON array.

**Response Example:**
```json
[
  {
    "name": "Group42",
    "price": 75
  },
  {
    "name": "Spaghetti Carbonara",
    "price": 89
  },
  {
    "name": "Caesar Salad",
    "price": 65
  }
]
```

## Database Schema

### Core Entities
- **Cook**: Home kitchen cooks with address, phone, ID
- **Cyclist**: Delivery workers with phone, ID, bike type
- **Customer**: Users with address, phone, payment option (Card/MobilePay)
- **Portion**: Available dishes with quantity, price, TIME availability
- **Order**: Customer orders with total amount
- **OrderItem**: Items within an order
- **Trip**: Cyclist delivery trips with earnings
- **TripStop**: Pickup/delivery addresses with times
- **Rating**: 5-star ratings for food and delivery

### Key Features
- TIME datatype for portion availability intervals
- CASCADE DELETE maintains referential integrity
- Comprehensive indexing for query performance
- Check constraints ensure data validity

## Required Queries

1. **Cook Data**: Address, phone, and personal ID for a cook
2. **Available Portions**: Name, quantity, price, and time intervals for a kitchen
3. **Order Contents**: List of goods and provider kitchen in an order
4. **Trip Details**: Addresses and times for a cyclist's trip
5. **Average Rating**: Average food rating for a cook
6. **Monthly Stats**: Hours and earnings per month for a cyclist
7. **Cyclist Data**: Phone, ID, and bike type for cyclists

## Building for Submission

### Clean and Prepare

```bash
# Clean build outputs
cd src/WebAPI
dotnet clean

# Create submission package
cd ../..
chmod +x prepare_submission.sh
./prepare_submission.sh au123456  # Replace with your AU ID

# Creates: sw4bad-mas1-au123456.zip
```

### Submission Package Contents
- `WebAPI/` - Cleaned .NET solution
- `create_database.sql` - Database schema
- `insert_data.sql` - Sample data
- `queries.sql` - Required queries
- `ERD.png` - Chen notation diagram  
- `design_reasoning.md` - Design documentation

### Pre-Submission Checklist
- [ ] Web API builds without errors
- [ ] Swagger UI displays Menu endpoint
- [ ] Docker image builds successfully
- [ ] All 7 SQL queries execute correctly
- [ ] ERD uses Chen notation (not UML/Crow's Foot)
- [ ] Design reasoning document included
- [ ] Solution cleaned (no bin/obj folders)
- [ ] Zip file named correctly: `sw4bad-mas1-<au-id>.zip`

## Technical Requirements

- .NET 8.0 SDK
- Docker (for containerization)
- SQL Server 2022 or Azure Data Studio (for database)
- Visual Studio 2022 or VS Code (recommended)

## Important SQL Server 2022 Linux Notes

When running on SQL Server 2022 Linux (including Docker containers):
- **IDENTITY columns**: `DBCC CHECKIDENT` with `RESEED, 0` starts IDs from 0
- **sqlcmd path**: Use `/opt/mssql-tools18/bin/sqlcmd` with `-C` flag
- **TIME datatype**: Used for portion availability intervals as required

## Important Notes

1. **Grading**: Assignment must be approved (grade 1) or course is "Ikke bestået"
2. **Deadline**: Submit before deadline - late submissions receive grade 0
3. **Demo Day**: Be prepared to run solution and explain any part
4. **File Format**: Submit as .zip only (not .rar, .7z, etc.)
5. **Docker Hub**: Image must be published to Docker Hub for Part C

## Support

For questions about the assignment requirements, contact course instructors well in advance of the deadline.