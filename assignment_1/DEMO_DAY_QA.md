# SW4BAD Assignment 1 - Demo Day Q&A Reference

## Web API Questions

### Q: What does your API endpoint do?
**A:** I created a GET endpoint that returns a JSON array of available travel experiences - hotel rooms and tours. I implemented it with 3 hardcoded experiences as required by Part A of the assignment. Each experience has a name, description, and decimal price.

### Q: Show me the code for the endpoint
**A:** I'll navigate to `src/WebAPI/Controllers/ExperiencesController.cs:35-38`. Here's my implementation:
```csharp
[HttpGet]
public ActionResult<IEnumerable<Experience>> GetExperiences()
{
    return Ok(_experiences);  // I return 200 OK with JSON array
}
```

### Q: Run the endpoint from Swagger
**A:** I'll demonstrate this now:
```bash
cd src/WebAPI
dotnet run
```
1. I open the browser to `http://localhost:5097/swagger`
2. I click on "GET /api/experiences" to expand it
3. I click the "Try it out" button
4. I click "Execute" 
5. Here you can see the response with my 3 experiences in JSON format

### Q: Explain the data flow from request to response
**A:** Here's how I designed the request flow:
1. **Client sends** a GET request to `/api/experiences`
2. **ASP.NET routing** matches the URL to my `ExperiencesController` using the `[Route("api/[controller]")]` attribute I added on line 8
3. **Controller instantiates** with my hardcoded `_experiences` list (lines 12-31)
4. **My GetExperiences method** executes and I wrap the data in `Ok()` for HTTP 200 status
5. **ASP.NET serializes** my `List<Experience>` to JSON automatically
6. **Response returns** with status 200 and the JSON content

### Q: Where is the Experience class defined?
**A:** I defined it in `src/WebAPI/Models/Experience.cs:4-8`. I created a POCO class with three properties:
- Name (required string)
- Description (required string)
- Price (decimal? - nullable decimal for precise monetary values)

I used the `required` modifier to avoid nullable warnings and `decimal?` to match the database's DECIMAL(10,2) type.

### Q: Where is the hardcoded data?
**A:** I placed the hardcoded data in `src/WebAPI/Controllers/ExperiencesController.cs:12-31` in a private field. I included:
- Night at Noah's Hotel Single room (730.50 DKK)
- Night at Noah's Hotel Double room (910.99 DKK)  
- Vienna Historic Center Walking Tour (100.00 DKK)

## Dockerfile Questions

### Q: Why did you use a multi-stage Dockerfile?
**A:** I chose a multi-stage build to minimize the final image size. The build tools and SDK are about 800MB but I only need them during compilation. My final image only contains the ASP.NET runtime (~200MB) and my compiled application, which reduces both deployment size and attack surface.

### Q: What is the purpose of the build stage?
**A:** In lines 1-8, I set up the build stage where I compile the C# code. I use the .NET SDK image to:
- Restore NuGet packages with `dotnet restore`
- Build the application with `dotnet build`
- Publish production binaries with `dotnet publish`

### Q: What is the purpose of the final stage?
**A:** In lines 9-14, I create the production runtime image. I:
- Use the lightweight ASP.NET runtime image (not the SDK)
- Copy only the published binaries from my build stage
- Set the working directory and expose port 8080
- Configure the entry point to start my application

### Q: What does this specific line do?

**Line 1:** `FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build`
- I pull the official .NET 8.0 SDK Docker image
- I name this stage "build" for later reference

**Line 3:** `COPY ["WebAPI.csproj", "./"]`
- I copy only the project file first
- This enables Docker layer caching since dependencies change less than code

**Line 4:** `RUN dotnet restore "WebAPI.csproj"`
- I download NuGet package dependencies
- This creates a separate cacheable layer

**Line 8:** `RUN dotnet publish "WebAPI.csproj" -c Release -o /app/publish`
- I compile in Release configuration
- I output production-ready binaries to /app/publish

**Line 12:** `COPY --from=publish /app/publish .`
- I copy compiled binaries from the build stage
- I only include necessary runtime files, not source code

**Line 13:** `ENV ASPNETCORE_URLS=http://+:8080`
- I configure ASP.NET to listen on all interfaces port 8080
- This is required for container networking

**Line 14:** `ENTRYPOINT ["dotnet", "WebAPI.dll"]`
- I define the command to start my application
- This runs when the container starts

## Database Design Questions

### Q: Explain your database design
**A:** I designed seven entities in Third Normal Form (3NF) to capture group travel with individual bookings:
- **Provider:** I store businesses offering services with Danish CVR numbers
- **Guest:** I track platform users with age≥18 constraint and unique PersonalID
- **Experience:** I record individual services with DECIMAL(10,2) prices for precision
- **SharedExperience:** I model group events organized by a guest with dates
- **SharedExperienceItem:** I use this junction table to link experiences to shared events
- **Booking:** I track individual reservations showing who booked what within which event
- **Discount:** I handle volume-based pricing (10% at 10 guests, 20% at 50 guests)

### Q: Why is the relationship between Guest and Experience many-to-many?
**A:** I don't have a direct many-to-many relationship. Instead, I route it through two junction tables:
- The path I created: Guest → Booking → SharedExperienceItem → Experience
- This design captures that guests book experiences within specific shared events
- I need to know that Joan booked the hotel as part of "Trip to Austria", not just that she booked a hotel somewhere

### Q: Why is the relationship between Provider and Experience one-to-many?
**A:** I designed it this way for business logic: Each experience belongs to exactly one provider (Noah's Hotel owns their rooms, Vienna Tours owns their walking tour). One provider can offer multiple experiences. I enforce this with the foreign key `ProviderID` in the Experience table.

### Q: How does your design handle the discounts?
**A:** I created a separate `Discount` table with:
- `ProviderID` (foreign key to link to providers)
- `MinGuests` (the threshold I check for activation)
- `DiscountPercentage` (0-100 range)

I support multiple rows per provider for tiered discounts:
- Row 1: Provider=Noah's Hotel, MinGuests=10, Discount=10%
- Row 2: Provider=Noah's Hotel, MinGuests=50, Discount=20%

In Query 10, I calculate applicable discounts based on actual booking counts.

### Q: What was the hardest part of the design to figure out?
**A:** The three-level booking structure was challenging. My initial instinct was a simple Guest-Experience junction table, but I realized queries 4-6 need context: "Which guests booked the Vienna tour as part of Trip to Austria?" versus "Which guests booked it for the Pottery Weekend?". I solved this with the SharedExperienceItem junction to provide that context.

### Q: How do you ensure data integrity?
**A:** I implemented several constraints:
- **CASCADE DELETE** on all foreign keys - if I delete a provider, their experiences are removed
- **UNIQUE constraints** prevent duplicate bookings (Guest+SharedExperienceItem combination)
- **CHECK constraints** enforce my business rules (Age≥18, Price≥0, Discount 0-100)
- **NOT NULL** on critical fields - only Description is nullable

## SQL Query Questions

### Q: Is the output of this query correct?
**A:** I'll check against the expected output from the assignment PDF:

**Query 1 (Provider data):**
- I return: "Finlandsgade 17, 8200 Aarhus N" | "+45 71555080" | "11111114"
- The column order I use: Address, Phone, CVR

**Query 2 (Experience list):**
- I ensure prices show as DECIMAL: 730.50, 910.99, 100.00
- I cast to DECIMAL(10,2) when needed

**Query 3 (Shared experiences):**
- I format dates as YYYY-MM-DD using CONVERT
- I order by date DESC (newest first)

### Q: How would you fix this [missing order/wrong format]?

**If I'm missing ORDER BY:**
```sql
-- Wrong:
SELECT Name, Date FROM SharedExperience;

-- I fix it:
SELECT Name, Date FROM SharedExperience 
ORDER BY Date DESC;
```

**If the date format is wrong:**
```sql
-- Wrong: Shows 2024-07-02 00:00:00
SELECT Date FROM SharedExperience;

-- I fix it:
SELECT Name, CONVERT(VARCHAR(10), Date, 120) AS Date
FROM SharedExperience;
```

### Q: Explain the JOIN you used in Query 4
**Query 4: Get guests registered for a shared experience**

I built this query step by step:
```sql
FROM Guest g
INNER JOIN Booking b ON g.GuestID = b.GuestID
INNER JOIN SharedExperienceItem sei ON b.SharedExperienceItemID = sei.SharedExperienceItemID  
INNER JOIN SharedExperience se ON sei.SharedExperienceID = se.SharedExperienceID
WHERE se.Name = 'Trip to Austria'
```
- I start with the Guest table
- I join to their Bookings
- I link bookings to SharedExperienceItems 
- I connect to SharedExperience to filter by event name
- This returns only guests who have bookings in "Trip to Austria"

### Q: What is a foreign key and how does it connect these tables?
**A:** A foreign key is a column I use to reference the primary key of another table, enforcing referential integrity.

**Example:** I have `Experience.ProviderID` that:
- References `Provider.ProviderID`
- Ensures every experience I create belongs to a valid provider
- Prevents me from inserting an experience with non-existent ProviderID
- With `CASCADE DELETE`, when I delete a provider, their experiences are automatically deleted

### Q: Why do you need SharedExperienceItem as a junction table?
**A:** I need it to enable many-to-many between SharedExperience and Experience:
- One shared experience (Trip to Austria) can include many experiences (flight, hotel, tour)
- One experience (Noah's Hotel) can be part of many shared experiences
- I added a UNIQUE constraint on (SharedExperienceID, ExperienceID) to prevent adding the same experience twice

### Q: How do you handle guests who only book some experiences in a shared event?
**A:** I designed the Booking table to reference SharedExperienceItem, not SharedExperience directly. This allows:
- Joan to book hotel + flight for Austria trip
- Patrick to book hotel + flight + walking tour for the same trip
- Each guest has their individual booking records
- I can query who booked what within each event

## Docker Compose & Database Questions

### Q: How do you run everything with Docker?
**A:** I use Docker Compose to orchestrate both containers:
```bash
docker compose up -d
```
This starts:
- SQL Server on port 1433 with persistent storage
- Web API on port 8080
- I configured health checks so the API waits for SQL Server

### Q: What happens to the data when containers stop?
**A:** I configured a Docker volume called `sqldata` in my docker-compose.yml. When I run `docker compose down`, the containers stop but the data persists in the volume. Only `docker compose down -v` removes the data.

### Q: Why are all IDs starting from 0 instead of 1?
**A:** I discovered that SQL Server 2022 on Linux behaves differently. When I use `DBCC CHECKIDENT` with `RESEED, 0`, the next identity value is 0, not 1 like on Windows. I adjusted all my insert scripts to use 0-based IDs:
- ProviderID: 0-4
- GuestID: 0-7
- ExperienceID: starts from 0

### Q: How do you test the SQL queries?
**A:** I can run them directly in the container:
```bash
docker exec experience-sqlserver /opt/mssql-tools18/bin/sqlcmd \
  -S localhost -U sa -P YourStrong@Passw0rd123 -C \
  -d ExperienceShareDB -i /tmp/queries.sql
```

## General Troubleshooting

### Q: Why won't my API start?
**A:** I check these common issues:
1. Port conflict - I verify port 5097 is free
2. .NET 8.0 SDK - I confirm with `dotnet --version`
3. Build errors - I run `dotnet build` to see any compilation errors

### Q: Why doesn't Docker build work?
**A:** I verify:
1. Docker daemon is running: `docker --version`
2. I'm in the correct directory: `src/WebAPI/` where my Dockerfile is
3. The buildx warning on WSL2 is harmless - I can ignore it

### Q: Why do queries fail?
**A:** I ensure:
1. I run scripts in order: create_database.sql → insert_data.sql → queries.sql
2. Database exists: I create it first with `CREATE DATABASE ExperienceShareDB`
3. I'm using the correct sqlcmd path: `/opt/mssql-tools18/bin/sqlcmd` with `-C` flag

## Quick Commands Reference

```bash
# I build and run the API
cd src/WebAPI
dotnet build
dotnet run

# I use Docker Compose for both services
docker compose up -d
docker compose down

# I clean for submission
dotnet clean
./prepare_submission.sh au123456

# I test queries in Docker
docker exec experience-sqlserver /opt/mssql-tools18/bin/sqlcmd \
  -S localhost -U sa -P YourStrong@Passw0rd123 -C \
  -d ExperienceShareDB -Q "SELECT * FROM Experience"
```

## Important File Locations

- **API Endpoint:** `src/WebAPI/Controllers/ExperiencesController.cs:35-38`
- **Experience Model:** `src/WebAPI/Models/Experience.cs:4-8` 
- **Hardcoded Data:** `src/WebAPI/Controllers/ExperiencesController.cs:14-31`
- **Dockerfile:** `src/WebAPI/Dockerfile`
- **Docker Compose:** `docker-compose.yml`
- **Database Schema:** `database/scripts/create_database.sql`
- **Sample Data:** `database/scripts/insert_data.sql` (uses 0-based IDs)
- **Required Queries:** `database/scripts/queries.sql`
- **ERD Diagram:** `database/design/ERD.png`
- **Design Reasoning:** `database/design/design_reasoning.md`