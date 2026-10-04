data "azurerm_client_config" "current" {}

locals {
  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = data.azurerm_client_config.current.object_id
}

resource "azurerm_key_vault" "default" {
  name                = "kv-${var.workload}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tenant_id           = local.tenant_id
  sku_name            = "standard"

  # Private AKS access is currently in Preview: https://learn.microsoft.com/en-us/azure/aks/kms-data-encryption?pivots=cmk-private
  public_network_access_enabled = true

  # Required for CMK operations
  purge_protection_enabled   = true
  soft_delete_retention_days = 7
  rbac_authorization_enabled = true
}

resource "azurerm_role_assignment" "current_key_vault_administrator" {
  scope                = azurerm_key_vault.default.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_key_vault_key" "kubernetes_cluster" {
  name         = "cmk-kubernetes-cluster"
  key_vault_id = azurerm_key_vault.default.id
  key_type     = "RSA"
  key_size     = 4096

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]

  rotation_policy {
    automatic {
      time_before_expiry = "P30D"
    }
    notify_before_expiry = "P29D"
    expire_after         = "P90D"
  }

  depends_on = [azurerm_role_assignment.current_key_vault_administrator]
}
