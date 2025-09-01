# Critical Issues Fixed in Backend Course Assignment 1

## Date: 2025-09-01

This document details critical issues discovered and fixed in the SW4BAD Assignment 1 codebase.

## 1. SQL Server 2022 Linux IDENTITY Behavior

### Issue
- `DBCC CHECKIDENT` with `RESEED, 0` on SQL Server 2022 Linux starts IDs from 0, not 1
- All foreign key references in `insert_data.sql` assumed 1-based IDs
- Result: Foreign key constraint violations, empty junction tables

### Fix
Updated `insert_data.sql` to use 0-based IDs:
- ProviderID: 0-4 (was 1-5)
- GuestID: 0-7 (was 1-8)
- ExperienceID: 0-5 (was 1-6)
- SharedExperienceID: 0-2 (was 1-3)
- SharedExperienceItemID: 0-4 (was 1-5)

### Files Modified
- `database/scripts/insert_data.sql`

## 2. Data Type Mismatch

### Issue
- Database: `Price DECIMAL(10,2)` stores values like 730.50, 910.99
- API Model: `int?` caused precision loss
- Result: Prices truncated (730 instead of 730.50)

### Fix
- Changed `Experience.Price` from `int?` to `decimal?`
- Updated hardcoded values to use decimal literals (730.50m, 910.99m)

### Files Modified
- `src/WebAPI/Models/Experience.cs`
- `src/WebAPI/Controllers/ExperiencesController.cs`

## 3. Nullable Properties Warnings

### Issue
- Build warnings CS8618: Non-nullable properties without default values
- Properties `Name` and `Description` weren't marked properly

### Fix
- Added `required` modifier to `Name` and `Description` properties
- Ensures properties must be initialized during object creation

### Files Modified
- `src/WebAPI/Models/Experience.cs`

## 4. Docker Healthcheck Path

### Issue
- Healthcheck used `/opt/mssql-tools/bin/sqlcmd` (doesn't exist)
- Actual path is `/opt/mssql-tools18/bin/sqlcmd`
- Missing `-C` flag for certificate trust

### Fix
- Updated path to `/opt/mssql-tools18/bin/sqlcmd`
- Added `-C` flag for certificate trust

### Files Modified
- `docker-compose.yml`

## 5. Junction Tables Empty

### Issue
- SharedExperienceItem: 0 rows
- Booking: 0 rows
- Caused by wrong foreign key references (IDs off by 1)

### Fix
- Corrected all FK references in insert script
- SharedExperienceItem now has 5 rows
- Booking now has 16 rows

### Files Modified
- `database/scripts/insert_data.sql`

## Verification Tests

### Database Integrity
```sql
-- Check junction tables populated
SELECT COUNT(*) FROM SharedExperienceItem;  -- Returns: 5
SELECT COUNT(*) FROM Booking;                -- Returns: 16

-- Query 4: Guests in Austria trip
SELECT DISTINCT g.Name FROM Guest g 
JOIN Booking b ON g.GuestID = b.GuestID
JOIN SharedExperienceItem sei ON b.SharedExperienceItemID = sei.SharedExperienceItemID
JOIN SharedExperience se ON sei.SharedExperienceID = se.SharedExperienceID
WHERE se.Name = 'Trip to Austria';
-- Returns: Anne, Joan, Patrick, Suzzane
```

### API Response
```bash
curl http://localhost:8080/api/experiences
```
Returns:
```json
[
  {"name": "Night at Noah's Hotel Single room", "price": 730.5},
  {"name": "Night at Noah's Hotel Double room", "price": 910.99},
  {"name": "Vienna Historic Center Walking Tour", "price": 100.0}
]
```

## Impact Assessment

### Before Fixes
- ❌ Junction tables empty (0 rows)
- ❌ Queries 4-6, 8, 10 returned no results
- ❌ API returned integer prices (lost decimal precision)
- ❌ Docker healthcheck failed
- ❌ Build warnings for nullable properties

### After Fixes
- ✅ All tables properly populated
- ✅ All 10 queries return correct results
- ✅ API returns decimal prices with proper precision
- ✅ Docker healthcheck passes
- ✅ Clean build with no warnings

## Lessons Learned

1. **Platform Differences**: SQL Server behavior varies between Windows and Linux
2. **Type Consistency**: Always match data types between database and application layers
3. **Testing**: Test with actual data, not just schema creation
4. **Docker Paths**: Container tools versions may differ from documentation

## Recommendations

1. Add integration tests to verify data insertion
2. Include platform-specific notes in documentation
3. Use transactions for data insertion to ensure atomicity
4. Consider using migrations instead of manual scripts