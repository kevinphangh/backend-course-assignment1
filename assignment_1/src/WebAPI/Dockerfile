# ========================================================================================================
# Multi-Stage Dockerfile for ASP.NET Core 8.0 Web API
# ========================================================================================================
# This Dockerfile uses a multi-stage build pattern to create an optimized production image.
#
# WHY MULTI-STAGE BUILD?
# ----------------------
# 1. SECURITY: The SDK contains compilers, package managers, and build tools that could be exploited
#    in production. By excluding them, we reduce the attack surface significantly.
#
# 2. SIZE OPTIMIZATION:
#    - SDK image: ~800MB (contains MSBuild, NuGet, compilers, analyzers, etc.)
#    - Runtime image: ~200MB (contains only .NET runtime libraries)
#    - Result: 75% smaller image = faster pulls, less storage, lower costs
#
# 3. SEPARATION OF CONCERNS: Build tools belong in CI/CD, not in production containers
#
# 4. COMPLIANCE: Many security standards require minimal production images
# ========================================================================================================

# ========================================================================================================
# STAGE 1: BUILD STAGE (Temporary - Discarded after build)
# ========================================================================================================
# This stage exists only during docker build and is completely removed from the final image.
# Think of it as a temporary workshop where we compile our code, then throw away the workshop
# keeping only the finished product.
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# --------------------------------------------------------------------------------------------------------
# LAYER CACHING OPTIMIZATION STRATEGY
# --------------------------------------------------------------------------------------------------------
# Docker creates a cache layer for each instruction. If a layer hasn't changed, Docker reuses it.
# We copy files in order of change frequency: rarely-changing files first, frequently-changing last.
#
# COPY PROJECT FILE SEPARATELY - WHY?
# ------------------------------------
# The .csproj file contains package dependencies (NuGet references) which change infrequently.
# By copying it alone first, we create a cache layer that's only invalidated when dependencies change.
#
# REAL-WORLD IMPACT:
# - Without this optimization: Every code change = re-download all packages (30-60 seconds)
# - With this optimization: Code changes skip package download (saves 30-60 seconds per build)
#
# Example scenario: You fix a typo in a comment
# - Bad approach: Re-downloads Entity Framework, Newtonsoft.Json, etc. (unnecessary)
# - Our approach: Uses cached packages, only recompiles changed code
COPY ["WebAPI.csproj", "./"]

# Restore downloads NuGet packages specified in the .csproj file
# This is network-intensive and slow, so we want it cached whenever possible
RUN dotnet restore "WebAPI.csproj"

# NOW copy source code (changes frequently)
# This layer is invalidated on every code change, but package restore above remains cached
COPY . .

# Build compiles the C# code into Intermediate Language (IL) binaries
# Release configuration enables optimizations and removes debug symbols
# Output goes to /app/build (we'll copy from here in the publish stage)
RUN dotnet build "WebAPI.csproj" -c Release -o /app/build

# ========================================================================================================
# STAGE 2: PUBLISH STAGE (Temporary - Also discarded)
# ========================================================================================================
# This stage takes the build output and prepares it for production deployment
# It performs additional optimizations like tree-shaking (removing unused code)
FROM build AS publish

# The publish command creates a deployment-ready package with several optimizations:
# - Removes development-only dependencies
# - Performs IL linking to remove unused code paths
# - Generates runtime configuration files
#
# /p:UseAppHost=false - WHY?
# ---------------------------
# - true: Creates a self-contained executable (larger, includes .NET runtime)
# - false: Creates a framework-dependent deployment (smaller, requires .NET runtime in container)
# We choose false because our container already has the runtime, avoiding duplication
RUN dotnet publish "WebAPI.csproj" -c Release -o /app/publish /p:UseAppHost=false

# ========================================================================================================
# STAGE 3: RUNTIME STAGE (This is the actual final image)
# ========================================================================================================
# This is the only stage that makes it into the final Docker image.
# It's based on the minimal ASP.NET runtime image, not the SDK.
#
# SECURITY BENEFITS OF RUNTIME-ONLY IMAGE:
# -----------------------------------------
# Excludes: Compilers (can't compile malicious code)
# Excludes: Package managers (can't download arbitrary packages)
# Excludes: Build tools (can't be exploited for lateral movement)
# Excludes: Development certificates and debugging tools
# Includes: ONLY the minimal .NET runtime needed to execute compiled code
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app

# EXPOSE is documentation for humans and orchestrators
# It does NOT actually open the port (that's done with -p flag or docker-compose ports)
# Think of it as a "this container expects traffic on port 8080" label
EXPOSE 8080

# Copy ONLY the published files from the publish stage
# The build and publish stages (with all their build tools) are now discarded
# --from=publish references the publish stage above
# This is the key line that gives us our security and size benefits
COPY --from=publish /app/publish .

# ASP.NET Core by default only listens on localhost inside the container
# The + symbol means "all network interfaces" - required for container networking
# Without this, the app would be unreachable from outside the container
# Alternative: ASPNETCORE_URLS=http://0.0.0.0:8080 (same effect, different syntax)
ENV ASPNETCORE_URLS=http://+:8080

# ENTRYPOINT using exec form (JSON array) vs shell form - WHY?
# --------------------------------------------------------------
# Shell form: ENTRYPOINT dotnet WebAPI.dll
#   - Runs: /bin/sh -c "dotnet WebAPI.dll"
#   - PID 1 is shell, your app is a child process
#   - Docker stop signals go to shell, not your app
#   - App might not shut down gracefully
#
# Exec form: ENTRYPOINT ["dotnet", "WebAPI.dll"]
#   - Runs: dotnet WebAPI.dll directly as PID 1
#   - Docker stop signals go directly to your app
#   - Enables graceful shutdown and proper signal handling
#   - Required for Kubernetes graceful termination
ENTRYPOINT ["dotnet", "WebAPI.dll"]

# ========================================================================================================
# BUILD COMMAND EXAMPLES
# ========================================================================================================
# Build the image:
#   docker build -t myapi:latest .
#
# See image size comparison:
#   docker images | grep myapi
#   (will show ~200MB for this multi-stage build vs ~800MB if using SDK as base)
#
# Inspect what's in each stage (for learning):
#   docker build --target build -t myapi:build .  (shows build stage - 800MB)
#   docker build --target final -t myapi:final .  (shows final stage - 200MB)
#
# View layer caching in action:
#   1. Build once: docker build -t myapi .
#   2. Change a comment in Program.cs
#   3. Build again: docker build -t myapi .
#   4. Notice: "Using cache" for restore step (packages not re-downloaded)
# ========================================================================================================