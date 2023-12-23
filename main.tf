terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.85.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "2.47.0"
    }
  }
}

locals {
  workload = "petzexpress"
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

module "acr" {
  source              = "./modules/acr"
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
  vnet_id                = module.vnet.vnet_id
  node_pool_subnet_id    = module.vnet.node_pool_subnet_id
  local_account_disabled = var.aks_local_account_disabled
  azure_rbac_enabled     = var.aks_azure_rbac_enabled
  acr_id                 = module.acr.id
}

module "storage" {
  source              = "./modules/storage"
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location
}

module "entra_users" {
  source                  = "./modules/entra/users"
  entraid_tenant_domain   = var.entraid_tenant_domain
  password                = var.generic_password
  aks_cluster_resource_id = module.aks.aks_cluster_id
  storage_account_id      = module.storage.id
  resource_group_id       = azurerm_resource_group.default.id
}
