terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 5.8.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = ">= 3.10.0"
    }
  }
}

resource "random_string" "affix" {
  numeric     = true
  length      = 3
  min_numeric = 3
}

locals {
  workload = "contoso${random_string.affix.result}"
  zones    = ["1", "2", "3"]
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

module "key_vault" {
  source              = "./modules/key_vault"
  workload            = local.workload
  resource_group_name = module.resource_groups.kubernetes_resource_group_name
  location            = var.location
}

module "disk_encryption_set" {
  source              = "./modules/disk_encryption_set"
  workload            = local.workload
  resource_group_name = module.resource_groups.kubernetes_resource_group_name
  location            = var.location
  key_vault_key_id    = module.key_vault.kubernetes_cluster_key_id
  key_vault_id        = module.key_vault.key_vault_id
}

module "private_link" {
  source                      = "./modules/private_link"
  resource_group_name         = module.resource_groups.private_link_resource_group_name
  location                    = var.location
  vnet_id                     = module.network.vnet_id
  private_endpoints_subnet_id = module.network.private_endpoints_subnet_id
  container_registry_id       = module.container_registry.id
  key_vault_id                = module.key_vault.key_vault_id
}

module "private_dns" {
  source              = "./modules/private_dns_zones"
  resource_group_name = module.resource_groups.network_resource_group_name
  location            = var.location
}

module "kubernetes_identity" {
  source                                 = "./modules/identity/kubernetes"
  workload                               = local.workload
  location                               = var.location
  resource_group_name                    = module.resource_groups.kubernetes_resource_group_name
  vnet_id                                = module.network.vnet_id
  privatelink_azmk8s_private_dns_zone_id = module.private_dns.privatelink_azmk8s_private_dns_zone_id
  key_vault_id                           = module.key_vault.key_vault_id
}

module "kubernetes" {
  source                    = "./modules/kubernetes"
  workload                  = local.workload
  location                  = var.location
  resource_group_name       = module.resource_groups.kubernetes_resource_group_name
  cluster_subnet_id         = module.network.aks_nodes_subnet_id
  private_dns_zone_id       = module.private_dns.privatelink_azmk8s_private_dns_zone_id
  zones                     = local.zones
  container_registry_id     = module.container_registry.id
  user_assigned_identity_id = module.kubernetes_identity.user_assigned_identity_id
  key_vault_id              = module.key_vault.key_vault_id
  key_vault_key_id          = module.key_vault.kubernetes_cluster_key_id
  disk_encryption_set_id    = module.disk_encryption_set.aks_cluster_disk_encryption_set_id

  depends_on = [
    module.kubernetes_identity,
    module.private_link,
    module.private_dns,
    module.key_vault,
    module.disk_encryption_set,
  ]
}

# module "web_application_firewall" {
#   source                     = "./modules/web_application_firewall"
#   workload                   = local.workload
#   resource_group_name        = module.resource_groups.kubernetes_resource_group_name
#   location                   = var.location
#   log_analytics_workspace_id = module.monitor.log_analytics_workspace_id
# }

# module "application_gateway_for_containers" {
#   source              = "./modules/application_gateway/containers"
#   workload            = local.workload
#   resource_group_name = module.resource_groups.kubernetes_resource_group_name
#   location            = var.location
#   subnet_id           = module.network.application_gateway_for_containers_subnet_id
#   # web_application_firewall_policy_id = module.web_application_firewall.web_application_firewall_policy_id
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


