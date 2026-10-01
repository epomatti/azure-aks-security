terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 5.7.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = ">= 3.10.0"
    }
  }
}

data "azurerm_subscription" "current" {
  subscription_id = var.subscription_id
}

resource "random_string" "affix" {
  numeric     = true
  length      = 3
  min_numeric = 3
}

locals {
  workload  = "contoso${random_string.affix.result}"
  tenant_id = data.azurerm_subscription.current.tenant_id
}

module "resource_groups" {
  source   = "./modules/resource_groups"
  workload = local.workload
  location = var.location
}

module "network" {
  source              = "./modules/network"
  workload            = local.workload
  resource_group_name = module.resource_groups.network_resource_group_name
  location            = var.location
}

module "monitor" {
  source              = "./modules/monitor"
  workload            = local.workload
  resource_group_name = module.resource_groups.monitor_resource_group_name
  location            = var.location
}

module "container_registry" {
  source               = "./modules/container_registry"
  workload             = local.workload
  resource_group_name  = module.resource_groups.kubernetes_resource_group_name
  location             = var.location
  acr_sku              = var.acr_sku
  authorized_ip_ranges = var.authorized_ip_ranges
}

module "private_link" {
  source                      = "./modules/private_link"
  resource_group_name         = module.resource_groups.private_link_resource_group_name
  location                    = var.location
  vnet_id                     = module.network.vnet_id
  private_endpoints_subnet_id = module.network.private_endpoints_subnet_id
  container_registry_id       = module.container_registry.id
}

# module "aks" {
#   source              = "./modules/kubernetes"
#   subscription_id     = var.subscription_id
#   workload            = local.workload
#   resource_group_name = azurerm_resource_group.workload.name
#   location            = var.location

#   aks_default_node_pool_vm_size           = var.aks_default_node_pool_vm_size
#   aks_user_node_pool_vm_size              = var.aks_user_node_pool_vm_size
#   aks_cluster_sku_tier                    = var.aks_cluster_sku_tier
#   aks_automatic_upgrade_channel           = var.aks_automatic_upgrade_channel
#   aks_node_os_upgrade_channel             = var.aks_node_os_upgrade_channel
#   vnet_id                                 = module.vnet_aks.vnet_id
#   node_pool_subnet_id                     = module.vnet_aks.nodes_subnet_id
#   local_account_disabled                  = var.aks_local_account_disabled
#   azure_rbac_enabled                      = var.aks_azure_rbac_enabled
#   acr_id                                  = module.acr.id
#   aks_private_cluster_public_fqdn_enabled = var.aks_private_cluster_public_fqdn_enabled
#   private_cluster_enabled                 = var.aks_private_cluster_enabled
#   jump_server_identity_principal_id       = azurerm_user_assigned_identity.jump_server.principal_id

#   aks_network_plugin      = var.aks_network_plugin
#   aks_network_policy      = var.aks_network_policy
#   aks_network_data_plane  = var.aks_network_data_plane
#   aks_network_plugin_mode = var.aks_network_plugin_mode
#   # network_outbound_type = var.aks_network_outbound_type

#   create_agw             = var.create_agw
#   application_gateway_id = var.create_agw == true ? module.application_gateway[0].id : null
# }

# resource "azurerm_user_assigned_identity" "jump_server" {
#   name                = "id-vm-${local.workload}"
#   location            = var.location
#   resource_group_name = azurerm_resource_group.workload.name
# }

# module "jump_server" {
#   source                         = "./modules/jump-server"
#   location                       = azurerm_resource_group.jump_server.location
#   resource_group_name            = azurerm_resource_group.jump_server.name
#   workload                       = local.workload
#   vm_public_key_path             = var.vm_jump_public_key_path
#   vm_admin_username              = var.vm_jump_admin_username
#   vm_size                        = var.vm_jump_size
#   vm_osdisk_storage_account_type = var.vm_jump_osdisk_storage_account_type
#   subnet_id                      = module.vnet_corporate.jump_server_subnet_id
#   user_assigned_identity_id      = azurerm_user_assigned_identity.jump_server.id

#   vm_image_publisher = var.vm_jump_image_publisher
#   vm_image_offer     = var.vm_jump_image_offer
#   vm_image_sku       = var.vm_jump_image_sku
#   vm_image_version   = var.vm_jump_image_version
# }

# module "application_gateway_for_containers" {
#   count               = var.create_agwc ? 1 : 0
#   source              = "./modules/application-gateway-for-containers"
#   workload            = local.workload
#   resource_group_name = azurerm_resource_group.workload.name
#   location            = var.location
#   subnet_id           = module.vnet_aks.agwc_subnet_id
# }

# module "application_gateway" {
#   count               = var.create_agw ? 1 : 0
#   source              = "./modules/application-gateway"
#   workload            = local.workload
#   resource_group_name = azurerm_resource_group.workload.name
#   location            = var.location

#   # Network
#   subnet_id              = module.vnet_aks.agw_subnet_id
#   virtual_network_name   = module.vnet_aks.vnet_name
#   agw_private_ip_address = var.agw_private_ip_address

#   # SKU
#   agw_sku_name     = var.agw_sku_name
#   agw_sku_tier     = var.agw_sku_tier
#   agw_sku_capacity = var.agw_sku_capacity

#   # WAF
#   waf_policy_id = var.attach_waf_policy_to_gateway ? module.waf_policy[0].id : null
# }

# module "waf_policy" {
#   count                      = var.create_waf_policy ? 1 : 0
#   source                     = "./modules/waf-policy"
#   workload                   = local.workload
#   resource_group_name        = azurerm_resource_group.workload.name
#   location                   = var.location
#   log_analytics_workspace_id = module.monitor.log_analytics_workspace_id
# }

# module "storage" {
#   source              = "./modules/storage"
#   resource_group_name = azurerm_resource_group.workload.name
#   workload            = local.workload
#   location            = var.location
#   network_ip_rules    = var.aks_authorized_ip_ranges
# }

# module "entra_users" {
#   source                  = "./modules/entra/users"
#   entraid_tenant_domain   = var.entraid_tenant_domain
#   password                = var.generic_password
#   aks_cluster_resource_id = module.aks.aks_cluster_id
#   storage_account_id      = module.storage.id
#   resource_group_id       = azurerm_resource_group.workload.id
# }


