output "vnet_id" {
  value = azurerm_virtual_network.default.id
}

output "vnet_name" {
  value = azurerm_virtual_network.default.name
}

output "default_subnet_id" {
  value = azurerm_subnet.default.id
}

output "node_pool_subnet_id" {
  value = azurerm_subnet.aks_node_pool.id
}

output "private_endpoints_subnet_id" {
  value = azurerm_subnet.private_endpoints.id
}

output "alb_subnet_id" {
  value = azurerm_subnet.application_load_balancer.id
}

output "agw_subnet_id" {
  value = azurerm_subnet.application_gateway.id
}
