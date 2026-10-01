resource "azurerm_resource_group" "kubernetes" {
  name     = "rg-${var.workload}-kubernetes"
  location = var.location
}

resource "azurerm_resource_group" "network" {
  name     = "rg-${var.workload}-network"
  location = var.location
}

resource "azurerm_resource_group" "private_link" {
  name     = "rg-${var.workload}-private-link"
  location = var.location
}

resource "azurerm_resource_group" "monitor" {
  name     = "rg-${var.workload}-monitor"
  location = var.location
}
