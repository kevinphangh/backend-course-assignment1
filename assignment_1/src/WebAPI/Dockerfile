# Multi-stage Dockerfile for ASP.NET Core 8.0 Web API
# Required for SW4BAD Assignment 1 Part B - Containerization

# Stage 1: Build environment using full .NET SDK
# This stage compiles the application but is not included in final image
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy and restore dependencies separately for better Docker layer caching
# If dependencies haven't changed, this layer can be reused from cache
COPY ["WebAPI.csproj", "./"]
RUN dotnet restore "WebAPI.csproj"

# Copy all source code and build the application in Release configuration
COPY . .
RUN dotnet build "WebAPI.csproj" -c Release -o /app/build

# Stage 2: Publish the application to prepare for deployment
# Creates optimized, self-contained application package
FROM build AS publish
RUN dotnet publish "WebAPI.csproj" -c Release -o /app/publish /p:UseAppHost=false

# Stage 3: Final runtime image using minimal ASP.NET runtime
# Only includes .NET runtime dependencies, not SDK (~200MB vs ~800MB)
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app

# Expose port 8080 for container networking (required by assignment)
EXPOSE 8080

# Copy only the published application files from build stage
COPY --from=publish /app/publish .

# Configure ASP.NET Core to listen on all interfaces on port 8080
# Required for container networking to work properly
ENV ASPNETCORE_URLS=http://+:8080

# Set the entry point to run the compiled Web API application
ENTRYPOINT ["dotnet", "WebAPI.dll"]