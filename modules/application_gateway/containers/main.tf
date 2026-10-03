resource "azurerm_application_load_balancer" "default" {
  name                = "agwc-${var.workload}"
  resource_group_name = var.resource_group_name
  location            = var.location
}

resource "azurerm_application_load_balancer_frontend" "default" {
  name                         = "default"
  application_load_balancer_id = azurerm_application_load_balancer.default.id
}

resource "azurerm_application_load_balancer_subnet_association" "default" {
  name                         = "default"
  application_load_balancer_id = azurerm_application_load_balancer.default.id
  subnet_id                    = var.subnet_id
}

# resource "azurerm_application_load_balancer_security_policy" "default" {
#   name                               = "default-albsp"
#   application_load_balancer_id       = azurerm_application_load_balancer.default.id
#   location                           = var.location
#   web_application_firewall_policy_id = var.web_application_firewall_policy_id
# }
