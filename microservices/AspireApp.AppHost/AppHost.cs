var builder = DistributedApplication.CreateBuilder(args);

// 1. Containers
var messaging = builder.AddRabbitMQ("eventbus");
var postgres = builder.AddPostgres("postgres").AddDatabase("ordersdb");

// 2. Microservices
var inventoryApi = builder.AddProject<Projects.Inventory_API>("inventory-api")
                           .WithReference(messaging);

var orderApi = builder.AddProject<Projects.Order_API>("order-api")
                      .WithReference(postgres)
                      .WithReference(messaging);

// 3. Frontend (Consumes Order.API)
builder.AddProject<Projects.AspireApp_Web>("webfrontend")
    .WithExternalHttpEndpoints()
    .WithReference(orderApi);

builder.Build().Run();