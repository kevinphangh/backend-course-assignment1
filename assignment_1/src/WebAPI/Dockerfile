# dockerfile for the web api
# using multistage build to reduce size

# build stage
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# copy csproj first (for caching)
COPY ["WebAPI.csproj", "./"]
RUN dotnet restore "WebAPI.csproj"

COPY . .
RUN dotnet build "WebAPI.csproj" -c Release -o /app/build

# publish
FROM build AS publish
RUN dotnet publish "WebAPI.csproj" -c Release -o /app/publish /p:UseAppHost=false

# runtime image
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app

# dont run as root user
USER app

COPY --from=publish /app/publish .

EXPOSE 8080
EXPOSE 8081

ENTRYPOINT ["dotnet", "WebAPI.dll"]