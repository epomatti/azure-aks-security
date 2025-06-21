locals {
  cidr_prefix = "10.99"
}

# Virtual Network
resource "azurerm_virtual_network" "aks" {
  name                = "vnet-${var.workload}-aks"
  address_space       = ["${local.cidr_prefix}.0.0/16"]
  location            = var.location
  resource_group_name = var.resource_group_name
}

# Subnets
resource "azurerm_subnet" "aks_nodes" {
  name                 = "aks-nodes-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.aks.name
  address_prefixes     = ["${local.cidr_prefix}.10.0/24"]
}

resource "azurerm_subnet" "application_gateway_for_containers" {
  name                 = "app-gateway-for-containers-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.aks.name
  address_prefixes     = ["${local.cidr_prefix}.20.0/24"]

  delegation {
    name = "delegation"
    service_delegation {
      name    = "Microsoft.ServiceNetworking/trafficControllers"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

resource "azurerm_subnet" "application_gateway" {
  name                 = "app-gateway-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.aks.name
  address_prefixes     = ["${local.cidr_prefix}.30.0/24"]
}

# AKS Network Security Group
resource "azurerm_network_security_group" "aks" {
  name                = "nsg-${var.workload}-aks"
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_subnet_network_security_group_association" "aks" {
  subnet_id                 = azurerm_subnet.aks_nodes.id
  network_security_group_id = azurerm_network_security_group.aks.id
}

resource "azurerm_network_security_rule" "aks_nodes_block_all_inbound" {
  name                        = "DenyAll-Inbound"
  priority                    = 900
  direction                   = "Outbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  network_security_group_name = azurerm_network_security_group.aks.name
  resource_group_name         = var.resource_group_name
}

resource "azurerm_network_security_rule" "aks_nodes_block_all_outbound" {
  name                        = "DenyAll-Outbound"
  priority                    = 900
  direction                   = "Outbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  network_security_group_name = azurerm_network_security_group.aks.name
  resource_group_name         = var.resource_group_name
}
