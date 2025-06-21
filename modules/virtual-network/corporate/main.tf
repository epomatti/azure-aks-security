locals {
  cidr_prefix = "10.20"
}

# Virtual Network
resource "azurerm_virtual_network" "corporate" {
  name                = "vnet-${var.workload}-corporate"
  address_space       = ["${local.cidr_prefix}.0.0/16"]
  location            = var.location
  resource_group_name = var.resource_group_name
}

# Subnets
resource "azurerm_subnet" "private_endpoints" {
  name                 = "private-endpoints"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.corporate.name
  address_prefixes     = ["${local.cidr_prefix}.20.0/24"]
}

resource "azurerm_subnet" "jump_server" {
  name                 = "jump-server"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.corporate.name
  address_prefixes     = ["${local.cidr_prefix}.30.0/24"]
}

# NSG Jump Server
resource "azurerm_network_security_group" "jump_server" {
  name                = "nsg-${var.workload}-jump-server"
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_subnet_network_security_group_association" "jump" {
  subnet_id                 = azurerm_subnet.jump_server.id
  network_security_group_id = azurerm_network_security_group.jump_server.id
}

resource "azurerm_network_security_rule" "allow_ssh_from_ip" {
  name                        = "Allow-SSH-From-MyIP"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefixes     = var.ssh_allowed_ips
  destination_address_prefix  = "*"
  network_security_group_name = azurerm_network_security_group.jump_server.name
  resource_group_name         = var.resource_group_name
}
