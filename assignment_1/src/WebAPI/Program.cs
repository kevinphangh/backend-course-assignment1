// Application entry point - configures and starts the web server

var builder = WebApplication.CreateBuilder(args);

// Configure services
builder.Services.AddControllers();           // Enable MVC controllers
builder.Services.AddEndpointsApiExplorer();  // Support for API endpoint discovery
builder.Services.AddSwaggerGen();            // Generate Swagger documentation

var app = builder.Build();

// Configure middleware pipeline
app.UseSwagger();     // Enable Swagger JSON endpoint
app.UseSwaggerUI();   // Enable Swagger UI at /swagger
app.MapControllers(); // Map requests to controller actions

app.Run();  // Start listening for requests