# https://learn.microsoft.com/en-us/azure/backup/quick-kubernetes-backup-terraform
resource "azurerm_data_protection_backup_vault" "default" {
  name                         = "bvault-${var.workload}"
  resource_group_name          = var.resource_group_name
  location                     = var.location
  datastore_type               = "VaultStore"
  redundancy                   = "ZoneRedundant"
  immutability                 = "Disabled"
  retention_duration_in_days   = 14
  soft_delete                  = "Off"
  cross_region_restore_enabled = null

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_data_protection_backup_policy_blob_storage" "default" {
  name                                   = "default-backup-policy"
  vault_id                               = azurerm_data_protection_backup_vault.default.id
  operational_default_retention_duration = "P30D"
}
