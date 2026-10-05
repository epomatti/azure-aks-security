resource "azurerm_storage_account" "default" {
  name                       = "st${var.workload}"
  resource_group_name        = var.resource_group_name
  location                   = var.location
  account_tier               = "Standard"
  account_replication_type   = "ZRS"
  account_kind               = "StorageV2"
  https_traffic_only_enabled = true
  min_tls_version            = "TLS1_2"
  public_network_access      = "Public"

  # network_rules {
  #   default_action = "Deny"
  #   ip_rules       = var.network_ip_rules
  #   bypass         = ["AzureServices"]
  # }

  # lifecycle {
  #   ignore_changes = [
  #     network_rules[0].private_link_access
  #   ]
  # }
}

resource "azurerm_storage_container" "default" {
  name                  = "aks-backup-vault"
  storage_account_id    = azurerm_storage_account.default.id
  container_access_type = "private"
}
