# Multi-stage build for ASP.NET Core 8.0 Web API
# Reduces image size from ~800MB to ~200MB and improves security

# Build stage - compiles the application
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy csproj first for layer caching (packages change less than code)
COPY ["WebAPI.csproj", "./"]
RUN dotnet restore "WebAPI.csproj"

# Copy source code and build
COPY . .
RUN dotnet build "WebAPI.csproj" -c Release -o /app/build

# Publish stage - creates runtime-optimized output
FROM build AS publish
RUN dotnet publish "WebAPI.csproj" -c Release -o /app/publish /p:UseAppHost=false

# Runtime stage - minimal production image
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app

# Non-root user for security
USER app

# Copy published output from build stage
COPY --from=publish /app/publish .

# Health check endpoint
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8080/api/menu || exit 1

EXPOSE 8080
EXPOSE 8081

ENTRYPOINT ["dotnet", "WebAPI.dll"]