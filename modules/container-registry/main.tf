resource "azurerm_container_registry" "acr" {
  name                          = "acr${var.workload}"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  sku                           = var.acr_sku
  admin_enabled                 = false
  public_network_access_enabled = true

  dynamic "network_rule_set" {
    for_each = var.acr_sku == "Premium" ? [1] : []
    content {
      default_action = "Deny"

      ip_rule {
        action   = "Allow"
        ip_range = var.authorized_cidr_block
      }
    }
  }

  network_rule_bypass_option = "AzureServices"
}

# resource "azurerm_container_registry_cache_rule" "epomatti_arm" {
#   name                  = "epomatti-arm"
#   container_registry_id = azurerm_container_registry.acr.id
#   target_repo           = "aks-security-app"
#   source_repo           = "docker.io/epomatti/aks-security-app"
#   # credential_set_id     = "${azurerm_container_registry.acr.id}/credentialSets/example"
# }

# resource "azurerm_container_registry_credential_set" "example" {
#   name                  = "exampleCredentialSet"
#   container_registry_id = azurerm_container_registry.example.id
#   login_server          = "docker.io"

#   identity {
#     type = "SystemAssigned"
#   }

#   authentication_credentials {
#     username_secret_id = "https://example-keyvault.vault.azure.net/secrets/example-user-name"
#     password_secret_id = "https://example-keyvault.vault.azure.net/secrets/example-user-password"
#   }
# }
