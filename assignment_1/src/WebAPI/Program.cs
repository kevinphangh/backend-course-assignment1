// SW4BAD Assignment 1 - Local Food Delivery Web API

var builder = WebApplication.CreateBuilder(args);

// Configure services
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

// Middleware pipeline - order matters for request processing
app.UseSwagger();     // JSON spec at /swagger/v1/swagger.json
app.UseSwaggerUI();   // Interactive UI at /swagger
app.MapControllers();

app.Run(); // Port 5097 (dev) or 8080 (Docker)