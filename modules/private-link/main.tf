locals {
  acr_count = var.acr_create_private_endpoint ? 1 : 0
}

resource "azurerm_private_dns_zone" "registry" {
  count               = local.acr_count
  name                = "privatelink.azurecr.io"
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "registry" {
  count                 = local.acr_count
  name                  = "registry-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.registry[0].name
  virtual_network_id    = var.vnet_id
  registration_enabled  = false
}

resource "azurerm_private_endpoint" "registry" {
  count               = local.acr_count
  name                = "pe-cr"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoints_subnet_id

  private_dns_zone_group {
    name = azurerm_private_dns_zone.registry[0].name
    private_dns_zone_ids = [
      azurerm_private_dns_zone.registry[0].id
    ]
  }

  private_service_connection {
    name                           = "registry"
    private_connection_resource_id = var.container_registry_id
    is_manual_connection           = false
    subresource_names              = ["registry"]
  }
}
