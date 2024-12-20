terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.14.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "3.0.2"
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
  subscription_id     = var.subscription_id
  workload            = local.workload
  resource_group_name = azurerm_resource_group.default.name
  location            = azurerm_resource_group.default.location

  vm_size                = var.aks_vm_size
  aks_cluster_sku_tier   = var.aks_cluster_sku_tier
  vnet_id                = module.vnet.vnet_id
  node_pool_subnet_id    = module.vnet.node_pool_subnet_id
  local_account_disabled = var.aks_local_account_disabled
  azure_rbac_enabled     = var.aks_azure_rbac_enabled
  acr_id                 = module.acr.id
  authorized_ip_ranges   = var.aks_authorized_ip_ranges
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
