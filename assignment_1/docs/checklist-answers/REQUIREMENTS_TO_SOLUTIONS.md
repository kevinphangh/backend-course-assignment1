# Assignment Requirements to Solution Mapping

**Student:** Kevin Phan | **AU ID:** AU778738
**Course:** SW4BAD-E24 | **Assignment:** Local Food Delivery Backend

---

## Part A: Web API Requirements

### Requirement A1: Create ASP.NET Core Web API
**Solution Location:** `src/WebAPI/Program.cs`
- **Lines 1-17:** Complete ASP.NET Core 8.0 Web API setup
- **Line 3:** `WebApplication.CreateBuilder(args)` creates host
- **Lines 6-8:** Service registration (Controllers, Swagger)
- **Lines 13-15:** Middleware pipeline configuration
- **Technology:** ASP.NET Core 8.0 with minimal hosting

### Requirement A2: Menu Endpoint
**Solution Location:** `src/WebAPI/Controllers/MenuController.cs`
- **Line 10:** `[Route("api/[controller]")]` defines `/api/menu` route
- **Line 37:** `[HttpGet]` attribute
- **Line 38:** `public ActionResult<IEnumerable<Dish>> Menu()` implements GET
- **Lines 15-32:** Static dish collection with items
- **Line 40:** Returns `Ok(_dishes)` with HTTP 200 + JSON

### Requirement A3: First Menu Item = "Group42"
**Solution Location:** `src/WebAPI/Controllers/MenuController.cs`
- **Line 19:** `new Dish { Name = "Group42", Price = 75 }`
- **Verification:** First element in `_dishes` collection

### Requirement A4: Dish Model with Name and Price
**Solution Location:** `src/WebAPI/Models/Dish.cs`
- **Line 8:** `public string Name { get; set; }`
- **Line 13:** `public int? Price { get; set; }` (nullable as required)
- **Price Unit:** Stored as øre (smallest Danish currency unit)
- **Example:** 7500 = 75.00 DKK

---

## Part B: Docker Containerization

### Requirement B1: Multi-Stage Dockerfile
**Solution Location:** `src/WebAPI/Dockerfile`

#### Stage 1: Build (Lines 5-14)
```dockerfile
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ["WebAPI.csproj", "./"]
RUN dotnet restore "WebAPI.csproj"
```
- **Purpose:** Compile source code
- **Base Image:** SDK (~800MB) with build tools
- **Optimization:** Separate COPY for project file enables layer caching

#### Stage 2: Publish (Lines 17-18)
```dockerfile
FROM build AS publish
RUN dotnet publish "WebAPI.csproj" -c Release -o /app/publish /p:UseAppHost=false
```
- **Purpose:** Create optimized production build
- **Configuration:** Release mode with optimizations

#### Stage 3: Runtime (Lines 21-37)
```dockerfile
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "WebAPI.dll"]
```
- **Purpose:** Final production image
- **Base Image:** Runtime only (~200MB)
- **Security:** Non-root user (line 25: `USER app`)
- **Health Check:** Lines 31-32 with curl
- **Line 28:** Key multi-stage copy command

### Requirement B2: Docker Compose Setup
**Solution Location:** `docker-compose.yml`

#### Web API Service (Lines 4-21)
```yaml
localfood-api:
  image: kevinphangh/local-food-api:latest
  ports:
    - "8080:8080"
  depends_on:
    sqlserver:
      condition: service_healthy
```
- **Port Mapping:** 8080:8080 (host:container)
- **Health Check:** Waits for SQL Server readiness
- **Environment:** ASPNETCORE_URLS=http://+:8080

#### SQL Server Service (Lines 23-44)
```yaml
localfood-sqlserver:
  image: mcr.microsoft.com/mssql/server:2022-latest
  ports:
    - "1433:1433"
  volumes:
    - sqldata:/var/opt/mssql
```
- **Database:** SQL Server 2022 on Linux
- **Persistence:** Named volume for data
- **Health Check:** Custom sqlcmd probe

---

## Part C: Docker Hub Publication

### Requirement C1: Published Container
**Solution:** Docker Hub Repository
- **Image:** `kevinphangh/local-food-api:latest`
- **Public URL:** https://hub.docker.com/r/kevinphangh/local-food-api
- **Build Command:** `docker build -t kevinphangh/local-food-api:latest .`
- **Push Command:** `docker push kevinphangh/local-food-api:latest`

### Requirement C2: Container Runs Successfully
**Verification Steps:**
```bash
# Pull and run
docker pull kevinphangh/local-food-api:latest
docker run -p 8080:8080 kevinphangh/local-food-api:latest

# Test endpoint
curl http://localhost:8080/api/menu
# Returns: [{"name":"Group42","price":null},...]
```

---

## Part D: Database Design

### Requirement D1: Entity-Relationship Diagram
**Solution Location:** `database/design/LocalFoodDelivery_ERD.png`
- **Notation:** Chen notation (as required, not UML/Crow's Foot)
- **9 Entities:** Cook, Cyclist, Customer, Portion, Order, OrderItem, Trip, TripStop, Rating
- **Key Relationships:**
  - Cook 1:N Portion (CASCADE DELETE)
  - Customer 1:N Order (CASCADE DELETE)
  - Trip 1:N TripStop (multi-location delivery)

### Requirement D2: Database Schema
**Solution Location:** `database/scripts/create_database.sql`

#### Key Design Decisions:

**Line 7-17: Cook Table**
```sql
CREATE TABLE dbo.Cook (
    CookID INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL,
    PersonalID NVARCHAR(50) UNIQUE NOT NULL
```
- **Identity:** Auto-incrementing primary keys
- **PersonalID:** Danish CPR number equivalent

**Lines 46-57: Portion Table**
```sql
Price INT NOT NULL CHECK (Price > 0),
AvailableFrom TIME NOT NULL,
AvailableUntil TIME NOT NULL
```
- **Price as INT:** Avoids floating-point errors (stored as øre)
- **TIME Type:** Recurring daily availability windows

**Line 104-113: TripStop Table**
```sql
StopOrder INT NOT NULL,
StopType NVARCHAR(20) CHECK (StopType IN ('Pickup', 'Delivery'))
```
- **StopOrder:** Enables multi-stop route optimization
- **StopType:** Distinguishes pickup vs delivery locations

### Requirement D3: Test Data
**Solution Location:** `database/scripts/insert_data.sql`
- **Lines 8-13:** 3 Cooks (Mormors Mad, Studenter Køkken, Pizza & Pasta)
- **Lines 16-20:** 3 Cyclists (Mikkel, Lars, Sofie)
- **Lines 23-27:** 3 Customers (Peter Jensen, Anne Nielsen, Thomas Hansen)
- **Lines 30-44:** 12 Portions across 3 cooks
- **Lines 47-58:** 6 Orders demonstrating relationships
- **Lines 61-75:** 15 OrderItems showing multi-kitchen orders
- **Lines 78-84:** 4 Trips with earnings
- **Lines 87-98:** 12 TripStops showing route sequences

### Requirement D4: SQL Queries (7 Required)
**Solution Location:** `database/scripts/queries.sql`

#### Query 1: Cook Personal Data (Lines 8-11)
```sql
SELECT Address, Phone, PersonalID
FROM dbo.Cook
WHERE Name = 'Mormors Mad';
```
- **Purpose:** Retrieve cook contact information
- **Technique:** Simple SELECT with WHERE

#### Query 2: Food Availability (Lines 22-28)
```sql
SELECT p.Name, CONVERT(VARCHAR(5), p.AvailableFrom, 108) AS AvailableFrom
FROM dbo.Portion p
INNER JOIN dbo.Cook c ON p.CookID = c.CookID
```
- **Purpose:** Show portions with time windows
- **Technique:** JOIN + TIME formatting (style 108 = HH:MM)

#### Query 3: Order Contents (Lines 40-45)
```sql
SELECT oi.Quantity, p.Name, c.Name AS Kitchen
FROM dbo.OrderItem oi
INNER JOIN dbo.Portion p ON oi.PortionID = p.PortionID
INNER JOIN dbo.Cook c ON oi.CookID = c.CookID
```
- **Purpose:** Display multi-kitchen order items
- **Technique:** Triple JOIN across related tables

#### Query 4: Delivery Route (Lines 57-62)
```sql
SELECT ts.Address, ts.StopTime, ts.StopType
FROM dbo.TripStop ts
WHERE ts.TripID = 0
ORDER BY ts.StopOrder;
```
- **Purpose:** Show trip stops in sequence
- **Technique:** ORDER BY StopOrder field

#### Query 5: Average Rating (Lines 74-78)
```sql
SELECT CAST(AVG(CAST(r.FoodRating AS FLOAT)) AS DECIMAL(2,1))
FROM dbo.Rating r
WHERE r.FoodRating IS NOT NULL;
```
- **Purpose:** Calculate cook's average stars
- **Technique:** Double CAST for precision

#### Query 6: Monthly Performance (Lines 90-100)
```sql
SELECT DATENAME(MONTH, t.StartTime) AS Month,
       SUM(DATEDIFF(MINUTE, t.StartTime, t.EndTime)) / 60 AS Hours
GROUP BY MONTH(t.StartTime)
```
- **Purpose:** Cyclist earnings/hours by month
- **Technique:** Date functions + GROUP BY aggregation

#### Query 7: Cyclist List (Lines 111-113)
```sql
SELECT Name, Phone, PersonalID, BikeType
FROM dbo.Cyclist
ORDER BY Name;
```
- **Purpose:** Complete cyclist roster
- **Technique:** Simple SELECT with ORDER BY

---

## Technical Implementation Details

### Identity Seeding (0-Based)
**Location:** `database/scripts/insert_data.sql` Lines 3-5
```sql
DBCC CHECKIDENT ('dbo.Cook', RESEED, 0);
```
- **Linux SQL Server 2022:** IDENTITY starts at 0 with RESEED
- **Impact:** First OrderID = 0 (shown as Order #42 in UI)

### Connection String
**Location:** `docker-compose.yml` Line 17
```yaml
"Server=localfood-sqlserver,1433;Database=LocalFoodDB;User Id=sa;Password=MyP@ssw0rd2024!;TrustServerCertificate=true"
```
- **TrustServerCertificate:** Required for SQL Server 2022 TLS

### Database Initialization
**Commands:** Run after container start
```bash
# Create database
docker exec localfood-sqlserver /opt/mssql-tools18/bin/sqlcmd \
  -S localhost -U sa -P MyP@ssw0rd2024! -C \
  -Q "CREATE DATABASE LocalFoodDB"

# Run schema
docker exec localfood-sqlserver /opt/mssql-tools18/bin/sqlcmd \
  -S localhost -U sa -P MyP@ssw0rd2024! -C \
  -d LocalFoodDB -i /scripts/create_database.sql
```

---

## Submission Package

### Files Required
**Solution Location:** `submission/prepare_submission.sh`
- **Source Code:** Complete WebAPI project
- **Dockerfile:** Multi-stage build configuration
- **Docker Compose:** Full stack orchestration
- **Database Scripts:** Schema, data, queries
- **ERD Diagram:** Chen notation design
- **Documentation:** This requirements mapping

### Package Creation
```bash
cd submission
chmod +x prepare_submission.sh
./prepare_submission.sh AU778738
# Creates: sw4bad-mas1-AU778738.zip
```

---

## Verification Checklist

### Part A: Web API
- [x] ASP.NET Core 8.0 Web API created
- [x] `/api/menu` endpoint returns JSON
- [x] First item is "Group42" with null price
- [x] Dish model has Name and nullable Price

### Part B: Docker
- [x] Multi-stage Dockerfile (build, publish, runtime)
- [x] Image size optimized (~200MB final)
- [x] Docker Compose with API and SQL Server
- [x] Health checks configured

### Part C: Docker Hub
- [x] Published to kevinphangh/local-food-api:latest
- [x] Publicly accessible
- [x] Runs successfully when pulled

### Part D: Database
- [x] Chen notation ERD created
- [x] 9 tables with proper relationships
- [x] Test data inserted
- [x] All 7 required queries working
- [x] CASCADE DELETE implemented
- [x] TIME type for availability windows

---

## Notes

- **No Authentication:** Not required for assignment
- **No Tests:** Assignment doesn't require unit tests
- **Price Storage:** INT as øre prevents floating-point errors
- **Multi-Kitchen:** Key differentiator - orders from multiple cooks
- **Route Optimization:** StopOrder enables efficient delivery paths
- **0-Based IDs:** Linux SQL Server IDENTITY behavior