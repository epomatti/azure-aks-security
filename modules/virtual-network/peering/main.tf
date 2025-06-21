resource "azurerm_virtual_network_peering" "aks_to_corporate" {
  name                      = "peer_aks_to_corporate"
  resource_group_name       = var.resource_group_name
  virtual_network_name      = var.aks_vnet_name
  remote_virtual_network_id = var.corporate_vnet_id
}

resource "azurerm_virtual_network_peering" "corporate_to_aks" {
  name                      = "peer_corporate_to_aks"
  resource_group_name       = var.resource_group_name
  virtual_network_name      = var.corporate_vnet_name
  remote_virtual_network_id = var.aks_vnet_id
}
