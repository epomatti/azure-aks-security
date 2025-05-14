terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = ">= 3.0.0"
    }
  }
}

resource "random_string" "affix" {
  numeric     = true
  length      = 3
  min_numeric = 3
}

locals {
  workload = "petzexpress${random_string.affix.result}"
}

resource "azurerm_resource_group" "workload" {
  name     = "rg-${local.workload}-workload"
  location = var.location
}

resource "azurerm_resource_group" "private_link" {
  name     = "rg-${local.workload}-privatelink"
  location = var.location
}

module "vnet" {
  source              = "./modules/virtual-network"
  workload            = local.workload
  resource_group_name = azurerm_resource_group.workload.name
  location            = var.location
}

module "monitor" {
  source              = "./modules/monitor"
  workload            = local.workload
  resource_group_name = azurerm_resource_group.workload.name
  location            = var.location
}

module "acr" {
  source                = "./modules/container-registry"
  workload              = local.workload
  resource_group_name   = azurerm_resource_group.workload.name
  location              = var.location
  acr_sku               = var.acr_sku
  authorized_cidr_block = var.aks_authorized_ip_ranges[0]
}

module "aks" {
  source              = "./modules/kubernetes"
  subscription_id     = var.subscription_id
  workload            = local.workload
  resource_group_name = azurerm_resource_group.workload.name
  location            = var.location

  vm_size                       = var.aks_vm_size
  aks_cluster_sku_tier          = var.aks_cluster_sku_tier
  aks_automatic_upgrade_channel = var.aks_automatic_upgrade_channel
  aks_node_os_upgrade_channel   = var.aks_node_os_upgrade_channel
  vnet_id                       = module.vnet.vnet_id
  node_pool_subnet_id           = module.vnet.node_pool_subnet_id
  local_account_disabled        = var.aks_local_account_disabled
  azure_rbac_enabled            = var.aks_azure_rbac_enabled
  acr_id                        = module.acr.id
  authorized_ip_ranges          = var.aks_authorized_ip_ranges

  create_agw             = var.create_agw
  application_gateway_id = var.create_agw == true ? module.application_gateway[0].id : null
}

module "alb" {
  count               = var.create_alb ? 1 : 0
  source              = "./modules/application-load-balancer"
  workload            = local.workload
  resource_group_name = azurerm_resource_group.workload.name
  location            = var.location
  subnet_id           = module.vnet.alb_subnet_id
}

module "application_gateway" {
  count               = var.create_agw ? 1 : 0
  source              = "./modules/application-gateway"
  workload            = local.workload
  resource_group_name = azurerm_resource_group.workload.name
  location            = var.location

  # Network
  subnet_id              = module.vnet.agw_subnet_id
  virtual_network_name   = module.vnet.vnet_name
  agw_private_ip_address = var.agw_private_ip_address

  # SKU
  agw_sku_name     = var.agw_sku_name
  agw_sku_tier     = var.agw_sku_tier
  agw_sku_capacity = var.agw_sku_capacity
}

module "waf_policy" {
  source                     = "./modules/waf-policy"
  workload                   = local.workload
  resource_group_name        = azurerm_resource_group.workload.name
  location                   = var.location
  log_analytics_workspace_id = module.monitor.log_analytics_workspace_id
}

module "storage" {
  source              = "./modules/storage"
  resource_group_name = azurerm_resource_group.workload.name
  location            = var.location
  network_ip_rules    = var.aks_authorized_ip_ranges
}

module "entra_users" {
  source                  = "./modules/entra/users"
  entraid_tenant_domain   = var.entraid_tenant_domain
  password                = var.generic_password
  aks_cluster_resource_id = module.aks.aks_cluster_id
  storage_account_id      = module.storage.id
  resource_group_id       = azurerm_resource_group.workload.id
}

module "private_link" {
  source                      = "./modules/private-link"
  resource_group_name         = azurerm_resource_group.private_link.name
  location                    = var.location
  vnet_id                     = module.vnet.vnet_id
  private_endpoints_subnet_id = module.vnet.private_endpoints_subnet_id
  container_registry_id       = module.acr.id
  acr_create_private_endpoint = var.acr_create_private_endpoint
}
