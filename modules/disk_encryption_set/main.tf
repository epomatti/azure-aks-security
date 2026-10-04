resource "azurerm_disk_encryption_set" "des" {
  name                = "des-aks-nodes-${var.workload}"
  resource_group_name = var.resource_group_name
  location            = var.location
  key_vault_key_id    = var.key_vault_key_id

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_role_assignment" "key_vault_crypto_service_encryption" {
  scope                = var.key_vault_id
  role_definition_name = "Key Vault Crypto Service Encryption User"
  principal_id         = azurerm_disk_encryption_set.des.identity.0.principal_id
}
