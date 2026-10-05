output "kubernetes_resource_group_name" {
  value = azurerm_resource_group.kubernetes.name
}

output "network_resource_group_name" {
  value = azurerm_resource_group.network.name
}

output "private_link_resource_group_name" {
  value = azurerm_resource_group.private_link.name
}

output "monitor_resource_group_name" {
  value = azurerm_resource_group.monitor.name
}

output "backup_name" {
  value = azurerm_resource_group.backup.name
}
