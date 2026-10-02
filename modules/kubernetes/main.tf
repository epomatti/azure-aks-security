data "azurerm_client_config" "current" {}

locals {
  tenant_id = data.azurerm_client_config.current.tenant_id
}

resource "azurerm_kubernetes_cluster" "main" {

  ##############################################################################
  ### BASICS
  ##############################################################################

  name                = "aks-${var.workload}"
  location            = var.location
  resource_group_name = var.resource_group_name

  sku_tier                  = "Free"
  automatic_upgrade_channel = "patch"

  maintenance_window_auto_upgrade {
    frequency   = "Weekly"
    day_of_week = "Sunday"
    interval    = 1
    duration    = 8
    start_time  = "00:00"
    utc_offset  = "+00:00"
  }

  node_os_upgrade_channel = "NodeImage"

  maintenance_window_node_os {
    frequency   = "Weekly"
    day_of_week = "Sunday"
    interval    = 1
    duration    = 8
    start_time  = "00:00"
    utc_offset  = "+00:00"
  }

  local_account_disabled = true

  azure_active_directory_role_based_access_control {
    tenant_id          = local.tenant_id
    azure_rbac_enabled = true
  }

  ##############################################################################
  ### NODE POOLS
  ##############################################################################

  node_provisioning_profile {
    mode               = "Manual" # Disables Karpenter
    default_node_pools = "Auto"
  }

  default_node_pool {
    name                   = "agentpool"
    node_count             = 1
    vm_size                = "Standard_B4s_v2" # TODO: ARM64
    zones                  = var.zones
    auto_scaling_enabled   = false
    vnet_subnet_id         = var.cluster_subnet_id
    os_sku                 = "Ubuntu"
    max_pods               = 110
    node_public_ip_enabled = false

    upgrade_settings {
      drain_timeout_in_minutes      = 0
      max_surge                     = "10%"
      node_soak_duration_in_minutes = 0
    }
  }

  ##############################################################################
  ### NETWORKING
  ##############################################################################

  private_cluster_public_fqdn_enabled = false
  private_cluster_enabled             = true
  private_dns_zone_id                 = var.private_dns_zone_id

  network_profile {
    network_plugin      = "azure"
    network_plugin_mode = "overlay"
    network_data_plane  = "cilium"
    network_policy      = "cilium"
    # network_outbound_type = var.aks_network_outbound_type
    load_balancer_sku = "standard"
    service_cidr      = "172.200.0.0/16"
    dns_service_ip    = "172.200.0.10"

    # advanced_networking {

    # }
  }

  dns_prefix_private_cluster = "apiserver-${var.workload}"

  ##############################################################################
  ### INTEGRATIONS
  ##############################################################################

  # bootstrap_profile {
  #   # artifact_source = ""
  # }

  # open_service_mesh_enabled = true
  # service_mesh_profile {

  # }

  azure_policy_enabled = true

  ##############################################################################
  ### MONITORING
  ##############################################################################

  # oms_agent {

  # }

  ##############################################################################
  ### SECURITY
  ##############################################################################

  oidc_issuer_enabled          = true
  workload_identity_enabled    = true
  image_cleaner_enabled        = true
  image_cleaner_interval_hours = 168

  identity {
    type         = "UserAssigned"
    identity_ids = [var.user_assigned_identity_id]
  }

  lifecycle {
    ignore_changes = [
      web_app_routing # Application routing will be enabled via CLI.
    ]
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "userpool" {
  mode                  = "User"
  name                  = "userpool"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.main.id
  vm_size               = "Standard_B4s_v2" # TODO: ARM64
  zones                 = var.zones
  vnet_subnet_id        = var.cluster_subnet_id
  node_count            = 1
  auto_scaling_enabled  = false
  os_sku                = "Ubuntu"

  upgrade_settings {
    drain_timeout_in_minutes      = 0
    max_surge                     = "10%"
    node_soak_duration_in_minutes = 0
  }
}

# Registry attachment
resource "azurerm_role_assignment" "container_registry_acr_pull" {
  principal_id                     = azurerm_kubernetes_cluster.main.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = var.container_registry_id
  skip_service_principal_aad_check = true
}


### Cluster ###



### Cluster ###
# resource "azurerm_kubernetes_cluster" "default" {
#   name                = "aks-${var.workload}"
#   location            = var.location
#   resource_group_name = var.resource_group_name
#   node_resource_group = "rg-${var.workload}-managed-aks"

#   node_provisioning_profile {

#   }

#   sku_tier                  = var.aks_cluster_sku_tier
#   local_account_disabled    = var.local_account_disabled
#   automatic_upgrade_channel = var.aks_automatic_upgrade_channel
#   node_os_upgrade_channel   = var.aks_node_os_upgrade_channel

#   # Must be false for private clusters
#   private_cluster_enabled             = var.private_cluster_enabled
#   private_cluster_public_fqdn_enabled = var.aks_private_cluster_public_fqdn_enabled
#   dns_prefix                          = var.private_cluster_enabled ? null : "aks${var.workload}"
#   dns_prefix_private_cluster          = var.private_cluster_enabled ? "aks${var.workload}-private" : null
#   private_dns_zone_id                 = var.private_cluster_enabled ? azurerm_private_dns_zone.aks.id : null

#   # TODO: Learn this
#   # https://learn.microsoft.com/en-us/azure/governance/policy/concepts/policy-for-kubernetes
#   azure_policy_enabled = true

#   default_node_pool {
#     name           = "system"
#     node_count     = 1
#     vm_size        = var.aks_default_node_pool_vm_size
#     vnet_subnet_id = var.node_pool_subnet_id

#     # Added this as it was diffing with terraform plan
#     upgrade_settings {
#       drain_timeout_in_minutes      = 0
#       max_surge                     = "10%"
#       node_soak_duration_in_minutes = 0
#     }
#   }

#   network_profile {
#     network_plugin      = var.aks_network_plugin
#     network_policy      = var.aks_network_policy
#     network_data_plane  = var.aks_network_data_plane
#     network_plugin_mode = var.aks_network_plugin_mode
#     # network_outbound_type = var.aks_network_outbound_type
#     load_balancer_sku = "standard"

#     # This will not integrate with the existing VNET
#     # however, it must not overlap with an existing Subnet
#     service_cidr   = "10.0.90.0/24"
#     dns_service_ip = "10.0.90.10"
#   }

#   dynamic "ingress_application_gateway" {
#     for_each = var.create_agw ? [1] : []
#     content {
#       gateway_id = var.application_gateway_id
#     }
#   }

#   identity {
#     type         = "UserAssigned"
#     identity_ids = [azurerm_user_assigned_identity.aks.id]
#   }

#   # Managed property will now default to "true"
#   azure_active_directory_role_based_access_control {
#     tenant_id          = data.azurerm_subscription.current.tenant_id
#     azure_rbac_enabled = var.azure_rbac_enabled
#   }

#   lifecycle {
#     ignore_changes = [
#       # Application routing will be enabled via CLI.
#       web_app_routing
#     ]
#   }

#   depends_on = [azurerm_role_assignment.private_dnz_zone_contributor]
# }

