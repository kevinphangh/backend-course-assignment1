// assignment 1 - food delivery api

var builder = WebApplication.CreateBuilder(args);

// setup services
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(); // for swagger UI

var app = builder.Build();

// middleware
app.UseSwagger();
app.UseSwaggerUI();   // swagger at /swagger
app.MapControllers();

app.Run(); // port 5097 locally, 8080 in docker