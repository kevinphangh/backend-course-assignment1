# Assignment 1 Checklist - Quick Reference Guide

**Student:** Kevin Phan | **AU ID:** AU778738

---

## 🚀 Quick Setup Check

```bash
# 1. API Running?
curl http://localhost:8080/api/menu
# Should return: [{"name":"Group42","price":75},...]

# 2. Database Running?
docker ps | grep sqlserver
# Should show: localfood-sqlserver (Up)

# 3. Run All Queries
docker exec localfood-sqlserver /opt/mssql-tools18/bin/sqlcmd \
  -S localhost -U sa -P YourStrong@Passw0rd123 -C \
  -d LocalFoodDB -i /scripts/queries.sql
```

---

## 📝 Web API Questions & Answers

### Q: Where is the endpoint code?
**File:** `src/WebAPI/Controllers/MenuController.cs`
- **Line 9:** `[ApiController]` - Enables automatic validation
- **Line 10:** `[Route("api/[controller]")]` - Creates `/api/menu` route
- **Line 19:** First dish = "Group42" (assignment requirement)
- **Line 37:** `[HttpGet]` - GET method
- **Line 38:** `Menu()` method returns dishes
- **Line 40:** `Ok(_dishes)` returns HTTP 200 + JSON

### Q: How does the request flow?
1. Client sends GET to `localhost:8080/api/menu`
2. Kestrel web server receives request
3. Middleware pipeline (Program.cs lines 13-15):
   - UseSwagger()
   - UseSwaggerUI()
   - MapControllers()
4. Routes to MenuController.Menu()
5. Returns JSON with 200 OK

### Q: What is an endpoint?
**Answer:** A URL + HTTP method that exposes functionality. Our `/api/menu` + GET is an endpoint.

### Q: Why ControllerBase not Controller?
**Answer:** Controller has View support (MVC). We only need API features, so ControllerBase is lighter.

---

## 🐳 Docker Questions & Answers

### Q: What stages in your Dockerfile?
**NOT services - STAGES:**

1. **Build Stage** (Line 5-14)
   - Base: SDK image (~800MB)
   - Purpose: Compile code
   - Discarded after build

2. **Publish Stage** (Line 17-18)
   - Extends: Build stage
   - Purpose: Optimize for production
   - Also discarded

3. **Final Stage** (Line 21-37)
   - Base: Runtime only (~200MB)
   - **This is the actual image**
   - No compilers = secure

### Q: Key Dockerfile lines explained?

**Line 9:** `COPY ["WebAPI.csproj", "./"]`
- Copies project file separately for caching
- If dependencies don't change, saves 30-60 seconds

**Line 34:** `EXPOSE 8080`
- Documentation only - doesn't open port
- Actual opening: `-p 8080:8080`

**Line 28:** `COPY --from=publish /app/publish .`
- **The magic line** - copies from build stage
- This is why final image is small

**Note:** ENV ASPNETCORE_URLS now in docker-compose.yml
- `+` means all interfaces (not just localhost)
- Required for container networking

**Line 37:** `ENTRYPOINT ["dotnet", "WebAPI.dll"]`
- Exec form (not shell) for proper signal handling
- Runs as PID 1

### Q: Why multi-stage build?
- **Security:** No build tools in production
- **Size:** 200MB vs 800MB (75% smaller)
- **Speed:** Faster container startup

### Q: What is port mapping?
`"8080:8080"` means host:container. Traffic to host port 8080 goes to container port 8080.

---

## 🗄️ Database Questions & Answers

### Q: What tables?
**9 tables:** Cook, Customer, Cyclist, Portion, Order, OrderItem, Trip, TripStop, Rating

### Q: E/R Diagram compliance?
✅ **Chen notation used:**
- Rectangles = Entities
- Diamonds = Relationships
- 1, N, M = Cardinalities
- ❌ NO junction tables shown as entities

### Q: Hardest design challenge?
**Multi-stop delivery system.** Solution: TripStop table with:
- StopOrder (sequence)
- StopType (Pickup/Delivery)
- Links Trip → multiple Orders

### Q: Why is Order-Portion many-to-many?
- One order → many portions
- One portion → many orders
- Junction table: OrderItem (adds Quantity, SubtotalPrice)

### Q: What is a foreign key?
**Answer:** Column that references another table's primary key. Example: `Portion.CookID` references `Cook.CookID`.

### Q: Cascade strategies?
- **CASCADE:** Parent deletion removes children (Cook→Portion)
- **NO ACTION:** Can't delete if referenced (Cyclist→Trip)
- **SET NULL:** Delete parent, keep record (Cook→Rating)

---

## 📊 SQL Queries Quick Reference

### Query 1: Cook Personal Data
```sql
SELECT Address, Phone, PersonalID FROM Cook WHERE Name = 'Noah''s Kitchen'
```
Returns: 3 columns

### Query 2: Portions with Time Windows
```sql
-- Uses CONVERT for HH:MM format
CONVERT(VARCHAR(5), p.AvailableFrom, 108) AS AvailableFrom
```
Returns: 5 columns with TIME as HH:MM

### Query 3: Order Items
- Shows Order #42 (ID=0 due to 0-based seeding)
- Demonstrates multi-kitchen orders

### Query 4: Delivery Route
- Trip #52 with stops
- Ordered by StopOrder

### Query 5: Average Rating
```sql
CAST(AVG(CAST(r.FoodRating AS FLOAT)) AS DECIMAL(2,1))
```
Returns: 4.3 (one decimal place)

### Query 6: Cyclist Monthly Performance
- Groups by month
- Shows hours and earnings

### Query 7: All Cyclists
- Lists with BikeType
- Ordered by name

---

## 🔧 Docker Compose Key Points

### Services
1. **sqlserver** - SQL Server 2022
2. **webapi** - Our API from Docker Hub

### Important Features
- **Health check:** SQL must be ready before API starts
- **depends_on:** `condition: service_healthy`
- **Network:** Bridge network for internal DNS
- **Volumes:** `sqldata` persists database

### Connection String
```yaml
Server=sqlserver  # Uses Docker DNS, not localhost
Database=LocalFoodDB
User Id=sa
Password=YourStrong@Passw0rd123
```

---

## 💡 Common Pitfalls to Avoid

❌ **DON'T show OrderItem as entity in ERD** - It's a relationship

❌ **DON'T use SDK image in production** - Use runtime only

❌ **DON'T forget cardinalities** - Mark all as 1, N, or M

❌ **DON'T format TIME wrong** - Use HH:MM not HH:MM:SS

---

## 🎯 Key Technical Decisions

### Why TIME not DATETIME?
- Recurring daily windows (lunch: 11:30-20:00)
- No date needed
- 3 bytes vs 8 bytes

### Why INT for prices?
- No floating-point errors
- Store as smallest unit (øre)
- 7500 = 75.00 DKK

### Why nullable Price in Dish?
- Assignment didn't require prices
- Allows market price items

### Why hardcoded menu data?
- Assignment explicitly requires it
- No database dependency for Part A
- "Group42" requirement easy to verify

---

## 🏆 Grade 12 Checklist

✅ **Group42** first dish (Line 19 MenuController)
✅ **Multi-stage Docker** (200MB final, not 800MB)
✅ **Chen notation** strictly followed
✅ **All cardinalities** marked (1/N/M)
✅ **7 queries** with correct output
✅ **Docker Hub** published (kevinphangh/local-food-api:latest)
✅ **Health checks** configured
✅ **No junction tables** in ERD diagram
✅ **Can explain** every design decision

---

## 🚨 Emergency Answers

**"What if DB is down when API starts?"**
→ Health check prevents this. API waits for `service_healthy`.

**"Why no authentication?"**
→ Not in requirements. Would add JWT Bearer if needed.

**"Why Docker Compose not Kubernetes?"**
→ Single-host sufficient. K8s overkill for this scope.

**"What's EXPOSE do?"**
→ Documentation only. Doesn't open port. That's `-p` flag.

**"Explain 1:N vs M:N"**
→ 1:N = One cook, many portions. M:N = Many orders, many portions (needs junction table).

---

## 📈 Performance Numbers

- **Docker Image:** 200MB (was 800MB with SDK)
- **Build Time:** 1m 45s (with caching)
- **Cache Benefit:** Saves 30-60s when only code changes
- **Query Speed:** <1ms per query
- **Tables:** 9 total
- **Sample Data:** ~25 records total

---

## ✅ Final Confidence Boost

**You built:**
- ✅ Working API with "Group42" requirement
- ✅ Optimized Docker image (75% smaller)
- ✅ Proper database design (3NF)
- ✅ All queries returning correct data
- ✅ Production-ready architecture

**You understand:**
- Why multi-stage builds matter
- How Docker networking works
- Database normalization principles
- RESTful API patterns
- Container orchestration basics

**Ready for any question!** 🎯