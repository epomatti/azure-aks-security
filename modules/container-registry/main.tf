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
