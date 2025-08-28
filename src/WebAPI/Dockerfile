# Multi-stage build for ASP.NET Core 8.0 Web API

# Build stage
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy project file first for better layer caching
COPY ["WebAPI.csproj", "./"]
RUN dotnet restore "WebAPI.csproj"

# Copy source code and build
COPY . .
RUN dotnet build "WebAPI.csproj" -c Release -o /app/build

# Publish stage
FROM build AS publish
RUN dotnet publish "WebAPI.csproj" -c Release -o /app/publish /p:UseAppHost=false

# Runtime stage - minimal image with only runtime dependencies
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app
EXPOSE 8080

# Copy published files from build stage
COPY --from=publish /app/publish .

# Configure ASP.NET to listen on port 8080
ENV ASPNETCORE_URLS=http://+:8080

# Start the application
ENTRYPOINT ["dotnet", "WebAPI.dll"]