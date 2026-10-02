# Private DNS Zone for AKS: https://learn.microsoft.com/en-us/azure/aks/private-clusters-dns
resource "azurerm_private_dns_zone" "privatelink_azmk8s" {
  name                = "privatelink.${var.location}.azmk8s.io"
  resource_group_name = var.resource_group_name
}
