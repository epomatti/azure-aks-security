var builder = WebApplication.CreateBuilder(args);

builder.AddServiceDefaults();

var app = builder.Build();

app.MapDefaultEndpoints();

// In-memory stock store for testing
var stock = new Dictionary<string, int>(StringComparer.OrdinalIgnoreCase)
{
    ["WIDGET-01"] = 50,
    ["GADGET-02"] = 10,
    ["THING-03"] = 0
};

app.MapGet("/inventory/{productId}", (string productId) =>
{
    if (stock.TryGetValue(productId, out var qty))
    {
        return Results.Ok(new { ProductId = productId, QuantityOnHand = qty });
    }
    return Results.NotFound();
});

app.MapGet("/inventory", () => Results.Ok(stock));

app.Run();