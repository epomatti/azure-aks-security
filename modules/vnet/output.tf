output "vnet_id" {
  value = azurerm_virtual_network.default.id
}

output "default_subnet_id" {
  value = azurerm_subnet.default.id
}

output "node_pool_subnet_id" {
  value = azurerm_subnet.aks_node_pool.id
}
