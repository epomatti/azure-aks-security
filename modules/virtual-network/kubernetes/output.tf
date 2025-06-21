output "vnet_id" {
  value = azurerm_virtual_network.aks.id
}

output "vnet_name" {
  value = azurerm_virtual_network.aks.name
}

output "nodes_subnet_id" {
  value = azurerm_subnet.aks_nodes.id
}

output "agwc_subnet_id" {
  value = azurerm_subnet.application_gateway_for_containers.id
}

output "agw_subnet_id" {
  value = azurerm_subnet.application_gateway.id
}
