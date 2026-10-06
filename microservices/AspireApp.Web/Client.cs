namespace AspireApp.Web;

public class OrderApiClient(HttpClient httpClient)
{
    public async Task<List<OrderDto>?> GetOrdersAsync() =>
        await httpClient.GetFromJsonAsync<List<OrderDto>>("/orders");

    public async Task<OrderDto?> CreateOrderAsync(CreateOrderRequest request)
    {
        var response = await httpClient.PostAsJsonAsync("/orders", request);
        return await response.Content.ReadFromJsonAsync<OrderDto>();
    }
}

public class InventoryApiClient(HttpClient httpClient)
{
    public async Task<Dictionary<string, int>?> GetStockAsync() =>
        await httpClient.GetFromJsonAsync<Dictionary<string, int>>("/inventory");
}

public record OrderDto(int Id, string ProductId, int Quantity, decimal TotalPrice, string Status, DateTime CreatedAt);
public record CreateOrderRequest(string ProductId, int Quantity, decimal UnitPrice);