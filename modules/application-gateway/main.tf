resource "azurerm_public_ip" "default" {
  name                = "pip-agw-${var.workload}"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
}

# since these variables are re-used - a locals block makes this more maintainable
locals {
  backend_address_pool_name              = "${var.virtual_network_name}-beap"
  frontend_port_name                     = "${var.virtual_network_name}-feport"
  frontend_ip_configuration_name         = "${var.virtual_network_name}-feip"
  frontend_private_ip_configuration_name = "${var.virtual_network_name}-feipp"
  http_setting_name                      = "${var.virtual_network_name}-be-htst"
  listener_name                          = "${var.virtual_network_name}-httplstn"
  request_routing_rule_name              = "${var.virtual_network_name}-rqrt"
  redirect_configuration_name            = "${var.virtual_network_name}-rdrcfg"
}

resource "azurerm_application_gateway" "network" {
  name                = "agw-${var.workload}"
  resource_group_name = var.resource_group_name
  location            = var.location

  sku {
    name     = var.agw_sku_name
    tier     = var.agw_sku_tier
    capacity = var.agw_sku_capacity
  }

  gateway_ip_configuration {
    name      = "aks-ip-configuration"
    subnet_id = var.subnet_id
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.default.id
  }

  frontend_ip_configuration {
    name                          = "static-private-ip"
    private_ip_address_allocation = "Static"
    subnet_id                     = var.subnet_id
  }

  backend_address_pool {
    name = local.backend_address_pool_name
  }

  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Enabled"
    affinity_cookie_name  = "ApplicationGatewayAffinity"
    path                  = "/"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    priority                   = 9
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
  }
}
