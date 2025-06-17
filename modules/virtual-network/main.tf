resource "azurerm_virtual_network" "default" {
  name                = "vnet-${var.workload}"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_subnet" "aks_node_pool" {
  name                 = "aks-node-pool"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.default.name
  address_prefixes     = ["10.0.10.0/24"]
}

resource "azurerm_subnet" "private_endpoints" {
  name                 = "private-endpoints"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.default.name
  address_prefixes     = ["10.0.20.0/24"]
}

resource "azurerm_subnet" "jump_server" {
  name                 = "jump-server"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.default.name
  address_prefixes     = ["10.0.30.0/24"]
}

resource "azurerm_subnet" "application_gateway_for_containers" {
  name                 = "agwc-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.default.name
  address_prefixes     = ["10.0.199.0/24"]

  delegation {
    name = "delegation"

    service_delegation {
      name    = "Microsoft.ServiceNetworking/trafficControllers"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

resource "azurerm_subnet" "application_gateway" {
  name                 = "agw-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.default.name
  address_prefixes     = ["10.0.244.0/24"]
}

resource "azurerm_network_security_group" "default" {
  name                = "nsg-${var.workload}"
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_subnet_network_security_group_association" "aks_node_pool" {
  subnet_id                 = azurerm_subnet.aks_node_pool.id
  network_security_group_id = azurerm_network_security_group.default.id
}

resource "azurerm_subnet_network_security_group_association" "private_endpoints" {
  subnet_id                 = azurerm_subnet.private_endpoints.id
  network_security_group_id = azurerm_network_security_group.default.id
}

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
