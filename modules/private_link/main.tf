resource "azurerm_private_dns_zone" "registry" {
  name                = "privatelink.azurecr.io"
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone" "key_vault" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "registry" {
  name                 = "registry-link"
  private_dns_zone_id  = azurerm_private_dns_zone.registry.id
  virtual_network_id   = var.vnet_id
  registration_enabled = false
}

resource "azurerm_private_dns_zone_virtual_network_link" "key_vault" {
  name                 = "keyvault-link"
  private_dns_zone_id  = azurerm_private_dns_zone.key_vault.id
  virtual_network_id   = var.vnet_id
  registration_enabled = false
}

resource "azurerm_private_endpoint" "registry" {
  name                = "pe-registry"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoints_subnet_id

  private_dns_zone_group {
    name = azurerm_private_dns_zone.registry.name
    private_dns_zone_ids = [
      azurerm_private_dns_zone.registry.id
    ]
  }

  private_service_connection {
    name                           = "registry"
    private_connection_resource_id = var.container_registry_id
    is_manual_connection           = false
    subresource_names              = ["registry"]
  }
}

resource "azurerm_private_endpoint" "key_vault" {
  name                = "pe-keyvault"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoints_subnet_id

  private_dns_zone_group {
    name = azurerm_private_dns_zone.key_vault.name
    private_dns_zone_ids = [
      azurerm_private_dns_zone.key_vault.id
    ]
  }

  private_service_connection {
    name                           = "vault"
    private_connection_resource_id = var.key_vault_id
    is_manual_connection           = false
    subresource_names              = ["vault"]
  }
}
