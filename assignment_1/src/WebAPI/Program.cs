// Program.cs - Application entry point for Local Food Delivery Web API
// Purpose: Configures services and HTTP pipeline for ASP.NET Core 8.0 Web API
// Part of SW4BAD Assignment 1 - WebAPI and Data Modelling

// Create the web application builder with default configuration
var builder = WebApplication.CreateBuilder(args);

// Register API services in the dependency injection container
builder.Services.AddControllers();           // Enable MVC controller support for handling HTTP requests
builder.Services.AddEndpointsApiExplorer();  // Provides API endpoint metadata for Swagger documentation
builder.Services.AddSwaggerGen();            // Generates Swagger/OpenAPI specification from controller attributes

// Build the configured application
var app = builder.Build();

// Configure the HTTP request pipeline - middleware executes in order
app.UseSwagger();     // Exposes OpenAPI JSON specification at /swagger/v1/swagger.json
app.UseSwaggerUI();   // Serves interactive Swagger UI at /swagger for API testing
app.MapControllers(); // Maps incoming HTTP requests to controller action methods

// Start the Kestrel web server and listen for requests
app.Run(); // Listens on port 5097 (development) or 8080 (Docker container)