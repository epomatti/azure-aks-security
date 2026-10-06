namespace Order.API;

public class OrderEntity
{
    public int Id { get; set; }
    public string ProductId { get; set; } = default!;
    public int Quantity { get; set; }
    public decimal TotalPrice { get; set; }
    public string Status { get; set; } = "Pending"; // Pending, Confirmed, Rejected
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}

public record CreateOrderRequest(string ProductId, int Quantity, decimal UnitPrice);