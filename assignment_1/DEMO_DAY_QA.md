# SW4BAD Assignment 1 - Demo Day Q&A Reference

## Web API Questions

### Q: What does your API endpoint do?
**A:** Returns a JSON array of available travel experiences (hotel rooms and tours) with name, description, and price. It's a prototype endpoint with 3 hardcoded experiences as required by Part A of the assignment.

### Q: Show me the code for the endpoint
**A:** Navigate to `src/WebAPI/Controllers/ExperiencesController.cs:36-39`
```csharp
[HttpGet]
public ActionResult<IEnumerable<Experience>> GetExperiences()
{
    return Ok(_experiences);  // Returns 200 OK with JSON array
}
```

### Q: Run the endpoint from Swagger
**A:** Steps to demonstrate:
```bash
cd src/WebAPI
dotnet run
```
1. Open browser to `http://localhost:5XXX/swagger`
2. Click "GET /api/experiences" to expand
3. Click "Try it out" button
4. Click "Execute" button
5. Show response body with 3 experiences in JSON format

### Q: Explain the data flow from request to response
**A:** 
1. **Client sends** GET request to `/api/experiences`
2. **ASP.NET routing** matches URL pattern to `ExperiencesController` via `[Route("api/[controller]")]` attribute (line 8)
3. **Controller instantiates** with hardcoded `_experiences` list (lines 12-32)
4. **GetExperiences method** executes, wrapping data in `Ok()` for HTTP 200 status
5. **ASP.NET serializes** `List<Experience>` to JSON using System.Text.Json
6. **Response sent** with status 200 and Content-Type: application/json header

### Q: Where is the Experience class defined?
**A:** `src/WebAPI/Models/Experience.cs:4-9` - POCO class with three properties:
- Name (string)
- Description (string) 
- Price (int? - nullable)

### Q: Where is the hardcoded data?
**A:** `src/WebAPI/Controllers/ExperiencesController.cs:12-32` in the private `_experiences` field:
- Night at Noah's Hotel Single room (730 DKK)
- Night at Noah's Hotel Double room (910 DKK)
- Vienna Historic Center Walking Tour (100 DKK)

## Dockerfile Questions

### Q: Why did you use a multi-stage Dockerfile?
**A:** To minimize the final image size. Build tools (SDK, ~800MB) are only needed during compilation, not runtime. The final image only contains the ASP.NET runtime (~200MB) and compiled application, reducing deployment size and attack surface.

### Q: What is the purpose of the build stage?
**A:** Lines 4-14 compile the C# code into IL assemblies. Uses the .NET SDK image to:
- Restore NuGet packages (`dotnet restore`)
- Build the application (`dotnet build`)
- Publish production binaries (`dotnet publish`)

### Q: What is the purpose of the final stage?
**A:** Lines 20-31 create the production runtime image:
- Uses lightweight ASP.NET runtime image (not SDK)
- Copies only the published binaries from build stage
- Sets working directory and port exposure
- Configures the entry point to start the application

### Q: What does this specific line do?

**Line 4:** `FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build`
- Pulls official .NET 8.0 SDK Docker image as base
- Names this stage "build" for later reference

**Line 8:** `COPY ["WebAPI.csproj", "./"]`
- Copies only project file first
- Enables Docker layer caching (dependencies change less than code)

**Line 9:** `RUN dotnet restore "WebAPI.csproj"`
- Downloads NuGet package dependencies
- Creates separate cacheable layer

**Line 17:** `RUN dotnet publish "WebAPI.csproj" -c Release -o /app/publish`
- Compiles in Release configuration
- Outputs production-ready binaries to /app/publish
- Sets UseAppHost=false for container deployment

**Line 25:** `COPY --from=publish /app/publish .`
- Copies compiled binaries from build/publish stage
- Only includes necessary runtime files, not source code

**Line 28:** `ENV ASPNETCORE_URLS=http://+:8080`
- Configures ASP.NET to listen on all interfaces port 8080
- Required for container networking

**Line 31:** `ENTRYPOINT ["dotnet", "WebAPI.dll"]`
- Defines command to start application
- Runs when container starts

## Database Design Questions

### Q: Explain your database design
**A:** Seven entities in Third Normal Form (3NF) capturing group travel with individual bookings:
- **Provider:** Businesses offering services (hotels, airlines) with CVR number
- **Guest:** Platform users with age≥18 constraint and unique PersonalID
- **Experience:** Individual services with DECIMAL(10,2) prices
- **SharedExperience:** Group events organized by a guest with date
- **SharedExperienceItem:** Junction table linking experiences to shared events
- **Booking:** Individual reservations tracking who booked what within which event
- **Discount:** Volume-based pricing tiers (10% at 10 guests, 20% at 50 guests)

### Q: Why is the relationship between Guest and Experience many-to-many?
**A:** It's not directly many-to-many. The relationship goes through two junction tables:
- Path: Guest → Booking → SharedExperienceItem → Experience
- This captures that guests book experiences *within the context of specific shared events*
- Same guest can book multiple experiences, same experience can have multiple guests
- But we need to know Joan booked the hotel as part of "Trip to Austria", not just that she booked a hotel

### Q: Why is the relationship between Provider and Experience one-to-many?
**A:** Business logic: Each experience belongs to exactly one provider (Noah's Hotel owns their rooms, Vienna Tours owns their walking tour). One provider can offer multiple experiences. The foreign key `ProviderID` in the Experience table enforces this relationship.

### Q: How does your design handle the discounts?
**A:** Separate `Discount` table with:
- `ProviderID` (foreign key)
- `MinGuests` (threshold for activation)
- `DiscountPercentage` (0-100)

Multiple rows per provider enable tiered discounts:
- Row 1: Provider=Noah's Hotel, MinGuests=10, Discount=10%
- Row 2: Provider=Noah's Hotel, MinGuests=50, Discount=20%

Query 10 calculates applicable discounts based on actual booking counts.

### Q: What was the hardest part of the design to figure out?
**A:** The three-level booking structure (SharedExperience → SharedExperienceItem → Booking). Initial instinct was a simple Guest-Experience junction table, but queries 4-6 require context: "Which guests booked the Vienna tour *as part of Trip to Austria*?" versus "Which guests booked it for the Pottery Weekend?". The SharedExperienceItem junction provides this context.

### Q: How do you ensure data integrity?
**A:** 
- **CASCADE DELETE** on all foreign keys (deleting provider removes their experiences)
- **UNIQUE constraints** prevent duplicate bookings (Guest+SharedExperienceItem)
- **CHECK constraints** enforce business rules (Age≥18, Price≥0, Discount 0-100)
- **NOT NULL** on critical fields (all except Description)

## SQL Query Questions

### Q: Is the output of this query correct?
**A:** Check against expected output from assignment PDF page 3:

**Query 1 (Provider data):**
- Should show: "Finlandsgade 17, 8200 Aarhus N" | "+45 71555080" | "11111114"
- Check column order: Address, Phone, CVR

**Query 2 (Experience list):**
- Price must be DECIMAL format: 730.50 not 730.5
- Check the decimal datatype requirement

**Query 3 (Shared experiences):**
- Date format must be YYYY-MM-DD
- Must be in descending order (newest first)

### Q: How would you fix this [missing order/wrong format]?

**Missing ORDER BY:**
```sql
-- Wrong:
SELECT Name, Date FROM SharedExperience;

-- Fixed:
SELECT Name, Date FROM SharedExperience 
ORDER BY Date DESC;
```

**Wrong date format:**
```sql
-- Wrong: Shows 2024-07-02 00:00:00
SELECT Date FROM SharedExperience;

-- Fixed: Shows 2024-07-02
SELECT CONVERT(VARCHAR(10), Date, 120) AS Date
FROM SharedExperience;
```

**Wrong decimal format:**
```sql
-- Wrong: Shows 730 or 730.5
SELECT Price FROM Experience;

-- Fixed: Shows 730.50
SELECT CAST(Price AS DECIMAL(10,2)) AS Price
FROM Experience;
```

### Q: Explain the JOIN you used in Query 4
**Query 4: Get guests registered for a shared experience**
```sql
FROM Guest g
INNER JOIN Booking b ON g.GuestID = b.GuestID
INNER JOIN SharedExperienceItem sei ON b.SharedExperienceItemID = sei.SharedExperienceItemID  
INNER JOIN SharedExperience se ON sei.SharedExperienceID = se.SharedExperienceID
WHERE se.Name = 'Trip to Austria'
```
- Starts with Guest table
- Joins to their Bookings
- Links bookings to SharedExperienceItems (which experience in which event)
- Links to SharedExperience to filter by event name
- Returns only guests who have bookings in "Trip to Austria"

### Q: What is a foreign key and how does it connect these tables?
**A:** A foreign key is a column that references the primary key of another table, enforcing referential integrity.

**Example:** `Experience.ProviderID`
- References `Provider.ProviderID`
- Ensures every experience belongs to a valid provider
- Can't insert experience with non-existent ProviderID
- `CASCADE DELETE` means deleting provider automatically deletes their experiences
- Creates the one-to-many line in the ERD between Provider and Experience

### Q: Why do you need SharedExperienceItem as a junction table?
**A:** It enables many-to-many between SharedExperience and Experience:
- One shared experience (Trip to Austria) can include many experiences (flight, hotel, tour)
- One experience (Noah's Hotel) can be part of many shared experiences (Austria trip, Pottery Weekend)
- The UNIQUE constraint on (SharedExperienceID, ExperienceID) prevents adding the same experience twice to an event

### Q: How do you handle guests who only book some experiences in a shared event?
**A:** The Booking table references SharedExperienceItem, not SharedExperience directly. This allows:
- Joan books hotel + flight for Austria trip
- Patrick books hotel + flight + walking tour for same trip
- Each guest has individual booking records
- Queries can show who booked what within each event

## General Troubleshooting

### Q: Why won't my API start?
**A:** Common issues:
1. Port already in use - check `launchSettings.json` for port configuration
2. Missing .NET 8.0 SDK - verify with `dotnet --version`
3. Build errors - run `dotnet build` to see compilation errors

### Q: Why doesn't Docker build work?
**A:** Check:
1. Docker daemon running: `docker --version`
2. In correct directory: Must run from `src/WebAPI/` where Dockerfile is
3. Line endings: Dockerfile must use LF not CRLF (Windows issue)

### Q: Why do queries fail?
**A:** Verify:
1. Scripts run in order: create_database.sql → insert_data.sql → queries.sql
2. Database exists: `CREATE DATABASE ExperienceShareDB`
3. Using correct database: `USE ExperienceShareDB`
4. SQL Server 2022 compatibility mode

## Quick Commands Reference

```bash
# Build and run API
cd src/WebAPI
dotnet build
dotnet run

# Docker commands
docker build -t webapi .
docker run -p 8080:8080 webapi

# Clean for submission
dotnet clean
cd ../..
./prepare_submission.sh au123456

# Test queries
sqlcmd -S localhost -U sa -P YourPassword -i database/scripts/create_database.sql
sqlcmd -S localhost -U sa -P YourPassword -i database/scripts/insert_data.sql
sqlcmd -S localhost -U sa -P YourPassword -i database/scripts/queries.sql
```

## Important File Locations

- **API Endpoint:** `src/WebAPI/Controllers/ExperiencesController.cs:36`
- **Experience Model:** `src/WebAPI/Models/Experience.cs:4`
- **Hardcoded Data:** `src/WebAPI/Controllers/ExperiencesController.cs:12-32`
- **Dockerfile:** `src/WebAPI/Dockerfile`
- **Database Schema:** `database/scripts/create_database.sql`
- **Sample Data:** `database/scripts/insert_data.sql`
- **Required Queries:** `database/scripts/queries.sql`
- **ERD Diagram:** `database/ERD.png`
- **Design Reasoning:** `database/design_reasoning.md`