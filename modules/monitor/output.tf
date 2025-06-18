output "log_analytics_workspace_id" {
  value = azurerm_log_analytics_workspace.default.id
}

output "monitor_workspace_id" {
  value = azurerm_monitor_workspace.default.id
}
