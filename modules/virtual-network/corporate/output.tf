output "vnet_id" {
  value = azurerm_virtual_network.corporate.id
}

output "vnet_name" {
  value = azurerm_virtual_network.corporate.name
}

output "jump_server_subnet_id" {
  value = azurerm_subnet.jump_server.id
}

output "private_endpoints_subnet_id" {
  value = azurerm_subnet.private_endpoints.id
}
