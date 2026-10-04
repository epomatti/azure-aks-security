# Recommended: https://learn.microsoft.com/en-us/azure/aks/configure-kubenet
resource "azurerm_user_assigned_identity" "aks" {
  name                = "id-aks-cluster-${var.workload}"
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_role_assignment" "network_contributor" {
  scope                            = var.vnet_id
  role_definition_name             = "Network Contributor"
  principal_id                     = azurerm_user_assigned_identity.aks.principal_id
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "private_dnz_zone_contributor" {
  scope                            = var.privatelink_azmk8s_private_dns_zone_id
  role_definition_name             = "Private DNS Zone Contributor"
  principal_id                     = azurerm_user_assigned_identity.aks.principal_id
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "key_vault_crypto_user" {
  scope                            = var.key_vault_id
  role_definition_name             = "Key Vault Crypto User"
  principal_id                     = azurerm_user_assigned_identity.aks.principal_id
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "key_vault_contributor" {
  scope                            = var.key_vault_id
  role_definition_name             = "Key Vault Contributor"
  principal_id                     = azurerm_user_assigned_identity.aks.principal_id
  skip_service_principal_aad_check = true
}
