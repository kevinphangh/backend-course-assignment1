# CRITICAL MISALIGNMENT REPORT

## ⚠️ CRITICAL: WRONG ASSIGNMENT IMPLEMENTED

**The current codebase implements an "Experience Sharing/Travel App" but the assignment requires a "Local Food Delivery App".**

This is a fundamental mismatch - the entire project is solving the wrong problem!

---

## Part A: Web API - COMPLETELY WRONG ❌

### Required:
- **Endpoint**: `/api/menu` (NOT `/api/experiences`)
- **Model**: `Dish` class with:
  - `Name` (string)
  - `Price` (int?) - nullable integer
  - NO Description field
- **Data**: 3 dummy dishes with first dish name = group number
- **Deliverable name**: `BAD_MA1A_Solution_grp<grpno>.zip`

### Current Implementation:
- **Endpoint**: `/api/experiences` ❌
- **Model**: `Experience` class with:
  - `Name` (string)
  - `Description` (string) ❌ - shouldn't exist
  - `Price` (decimal?) ❌ - should be int?
- **Data**: 3 experiences about hotels and tours ❌
- **No group number in first item** ❌

### Files to Fix:
- `src/WebAPI/Controllers/ExperiencesController.cs` → Should be `MenuController.cs`
- `src/WebAPI/Models/Experience.cs` → Should be `Dish.cs`

---

## Part B: Containerization - CORRECT ✅
- Multi-stage Dockerfile is correctly implemented
- This part passes requirements

---

## Part C: Docker Hub - WRONG ❌

### Required:
- Publish image to Docker Hub
- Docker Compose should pull from Docker Hub (using `image:` directive)

### Current Implementation:
- Docker Compose builds locally using `build:` directive ❌
- No image published to Docker Hub ❌

### Files to Fix:
- `docker-compose.yml` - Should use `image: <dockerhub-username>/<image-name>`

---

## Part D: Database - COMPLETELY WRONG DOMAIN ❌

### Required Database Tables:
1. **Cook** - address, phone, id
2. **Cyclist** - phone, id, bike type  
3. **Customer** - address, phone, payment option (card/mobile pay)
4. **Dish/Portion** - name, quantity, price, time interval (using TIME datatype)
5. **Order** - linking customers to dishes
6. **Trip** - routes for cyclists with pickup/delivery addresses and times
7. **Rating** - 5-star ratings for food and delivery

### Current Implementation:
- Provider ❌ (should be Cook)
- Guest ❌ (should be Customer)
- Experience ❌ (should be Dish)
- SharedExperience ❌ (not needed)
- SharedExperienceItem ❌ (not needed)
- Booking ❌ (should be Order)
- Discount ❌ (not in requirements)
- **Missing**: Cyclist, Trip, Rating tables

### Required Queries vs Implemented:

| Query # | Required | Current | Status |
|---------|----------|---------|---------|
| 1 | Cook data (address, phone, id) | Provider data | ❌ Wrong entity |
| 2 | Available portions (name, quantity, price, TIME interval) | Experience list | ❌ Missing quantity, time |
| 3 | Goods in an order with provider kitchen | Shared experiences | ❌ Completely wrong |
| 4 | Trip for cyclist (addresses, times, pickup/delivery) | Guests in shared experience | ❌ Completely wrong |
| 5 | Average rating for cook | Experiences in shared experience | ❌ No ratings table |
| 6 | Monthly hours/earnings for cyclist | Guests for specific experience | ❌ No cyclist data |
| 7 | Custom query | Provider discount percentages | ❌ Not relevant |

### Critical Database Issues:
- **NO TIME datatype usage** (required for portion availability times)
- **NO cyclist tracking** (hours, earnings, trips)
- **NO rating system** (5-star ratings)
- **NO order management** (customer orders for dishes)

---

## Submission Requirements - PARTIALLY CORRECT ⚠️

### Correct:
- Final zip naming: `sw4bad-mas1-<au-id>.zip` ✅
- SQL files included ✅
- ERD diagram included ✅

### Issues:
- Part A specific deliverable naming not handled
- ERD might be in wrong notation (needs Chen notation)

---

## IMMEDIATE ACTIONS REQUIRED

This codebase needs a complete rewrite to match the assignment:

1. **Replace API**:
   - Create `MenuController` with `/api/menu` endpoint
   - Create `Dish` model with correct properties
   - Add group number as first dish name

2. **Redesign Database**:
   - Create Cook, Cyclist, Customer tables
   - Add Dish/Portion with TIME columns
   - Implement Order, Trip, Rating tables
   - Write 7 new queries matching requirements

3. **Fix Docker Compose**:
   - Publish to Docker Hub first
   - Update compose to pull from Docker Hub

4. **Update Documentation**:
   - All references to "Experience Share" → "Local Food App"
   - Update ERD for food delivery domain
   - Rewrite design reasoning

---

## Estimated Impact

**Grade Risk: 0 (ZERO) - Assignment will not be accepted**

The assignment explicitly states:
- "Assignment is graded by: 0 (zero) Assignment is not accepted"
- "If your Mandatory Assignment ends up with grade 0 (Zero) the SW4DAB course is then 'Ikke bestået'"

This needs immediate and complete correction before submission!