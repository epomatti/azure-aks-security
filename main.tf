terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.81.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "2.46.0"
    }
  }
}

locals {
  workload = "cntrz"
}

resource "azurerm_resource_group" "default" {
  name     = "rg-${local.workload}"
  location = var.location
}

module "vnet" {
  source              = "./modules/vnet"
  workload            = local.workload
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location
}

module "aks" {
  source              = "./modules/aks"
  workload            = local.workload
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location

  vm_size                = var.aks_vm_size
  local_account_disabled = var.aks_local_account_disabled
}

module "aad_users" {
  source                  = "./modules/aad/users"
  entraid_tenant_domain   = var.entraid_tenant_domain
  aks_cluster_resource_id = module.aks.aks_cluster_id
}
