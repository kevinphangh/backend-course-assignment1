#!/bin/bash

# Wait for SQL Server to come up
echo "Waiting for SQL Server to start..."
sleep 30

# Create database and run scripts
echo "Creating database..."
/opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P YourStrong@Passw0rd123 -Q "CREATE DATABASE ExperienceShareDB"

echo "Creating tables..."
/opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P YourStrong@Passw0rd123 -d ExperienceShareDB -i /docker-entrypoint-initdb.d/create_database.sql

echo "Inserting sample data..."
/opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P YourStrong@Passw0rd123 -d ExperienceShareDB -i /docker-entrypoint-initdb.d/insert_data.sql

echo "Database initialization complete!"