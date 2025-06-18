resource "azurerm_log_analytics_workspace" "default" {
  name                = "log-${var.workload}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_monitor_workspace" "default" {
  name                          = "amw-${var.workload}"
  resource_group_name           = var.resource_group_name
  location                      = var.location
  public_network_access_enabled = true
}
