# Project Structure - Local Food Delivery API

## 📁 Directory Organization

```
assignment_1/
│
├── 📄 README.md                 # Project overview and setup instructions
├── 📄 docker-compose.yml        # Container orchestration
├── 📄 backend-course.sln        # Visual Studio solution file
├── 📄 .gitignore               # Git ignore patterns
│
├── 📂 src/                     # Source code
│   └── 📂 WebAPI/
│       ├── 📄 Program.cs       # Application entry point
│       ├── 📄 Dockerfile       # Container build instructions
│       ├── 📄 WebAPI.csproj    # Project configuration
│       ├── 📂 Controllers/     # API controllers
│       │   └── MenuController.cs
│       └── 📂 Models/          # Data models
│           └── Dish.cs
│
├── 📂 database/                # Database files
│   ├── 📂 scripts/
│   │   ├── create_database.sql # Schema creation
│   │   ├── insert_data.sql    # Sample data
│   │   └── queries.sql        # Assignment queries
│   └── 📂 design/
│       └── ERD.png            # Entity Relationship Diagram
│
├── 📂 docs/                    # Documentation
│   ├── 📄 CLAUDE.md           # AI assistant instructions
│   ├── 📂 assignment/         # Assignment files
│   │   ├── assignment.pdf    # Original assignment
│   │   └── Checklist Assignment 1.pdf
│   └── 📂 checklist-answers/  # Exam preparation
│       ├── ASSIGNMENT_CHECKLIST_CONCISE.md    # Quick reference (295 lines)
│       ├── ASSIGNMENT_CHECKLIST_ANSWERS.md     # Standard version (864 lines)
│       └── ASSIGNMENT_CHECKLIST_ANSWERS_EXPANDED.md # Detailed (1439 lines)
│
└── 📂 submission/              # Submission files
    ├── prepare_submission.sh   # Packaging script
    └── sw4bad-mas1-AU778738.zip # Submitted package
```

## 🎯 Quick Access Guide

### For Development
- **API Code:** `src/WebAPI/Controllers/MenuController.cs`
- **Docker Config:** `docker-compose.yml` (root level for easy access)
- **Database Scripts:** `database/scripts/`

### For Exam Preparation
1. **Quick Review:** `docs/checklist-answers/ASSIGNMENT_CHECKLIST_CONCISE.md`
2. **Standard Study:** `docs/checklist-answers/ASSIGNMENT_CHECKLIST_ANSWERS.md`
3. **Deep Dive:** `docs/checklist-answers/ASSIGNMENT_CHECKLIST_ANSWERS_EXPANDED.md`

### Essential Commands
```bash
# Start services
docker-compose up -d

# Run queries
docker exec localfood-sqlserver /opt/mssql-tools18/bin/sqlcmd \
  -S localhost -U sa -P YourStrong@Passw0rd123 -C \
  -d LocalFoodDB -i /scripts/queries.sql

# Test API
curl http://localhost:8080/api/menu

# Package for submission
cd submission && ./prepare_submission.sh AU778738
```

## 📋 File Purposes

### Root Level (Minimal - Clean!)
- **README.md** - First thing people see
- **docker-compose.yml** - Frequently used for `docker-compose up`
- **.gitignore** - Must be at root
- **backend-course.sln** - VS solution must be at root

### Why This Structure?
1. **Clean root** - Only essential files at top level
2. **Logical grouping** - Related files together
3. **Easy navigation** - Clear folder names
4. **Exam ready** - All answers in one place
5. **Development friendly** - Common files easily accessible

## 🔍 Finding Things

| What You Need | Where It Is |
|--------------|-------------|
| API endpoint code | `src/WebAPI/Controllers/MenuController.cs` line 46 |
| "Group42" requirement | `src/WebAPI/Controllers/MenuController.cs` line 25 |
| Dockerfile | `src/WebAPI/Dockerfile` |
| SQL queries | `database/scripts/queries.sql` |
| ERD diagram | `database/design/ERD.png` |
| Quick exam answers | `docs/checklist-answers/ASSIGNMENT_CHECKLIST_CONCISE.md` |
| Submission package | `submission/sw4bad-mas1-AU778738.zip` |