using Microsoft.EntityFrameworkCore;
using Order.API;

var builder = WebApplication.CreateBuilder(args);

// Add Aspire service defaults & PostgreSQL EF Core integration
builder.AddServiceDefaults();
builder.AddNpgsqlDbContext<OrdersDbContext>("ordersdb");

var app = builder.Build();

app.MapDefaultEndpoints();

// Auto-create database schema on startup for sandbox simplicity
using (var scope = app.Services.CreateScope())
{
    var db = scope.ServiceProvider.GetRequiredService<OrdersDbContext>();
    await db.Database.EnsureCreatedAsync();
}

app.MapGet("/orders", async (OrdersDbContext db) => 
    await db.Orders.OrderByDescending(o => o.CreatedAt).ToListAsync());

app.MapPost("/orders", async (CreateOrderRequest request, OrdersDbContext db) =>
{
    var order = new OrderEntity
    {
        ProductId = request.ProductId,
        Quantity = request.Quantity,
        TotalPrice = request.Quantity * request.UnitPrice,
        Status = "Pending",
        CreatedAt = DateTime.UtcNow
    };

    db.Orders.Add(order);
    await db.SaveChangesAsync();

    return Results.Created($"/orders/{order.Id}", order);
});

app.Run();