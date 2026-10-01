output "vnet_id" {
  value = azurerm_virtual_network.default.id
}

output "vnet_name" {
  value = azurerm_virtual_network.default.name
}

output "aks_nodes_subnet_id" {
  value = azurerm_subnet.aks_nodes.id
}

output "application_gateway_for_containers_subnet_id" {
  value = azurerm_subnet.application_gateway_for_containers.id
}

output "application_gateway_subnet_id" {
  value = azurerm_subnet.application_gateway.id
}

output "private_endpoints_subnet_id" {
  value = azurerm_subnet.private_endpoints.id
}

output "azure_bastion_subnet_id" {
  value = azurerm_subnet.azure_bastion.id
}
