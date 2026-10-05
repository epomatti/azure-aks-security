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

  disk_encryption_set_id = var.disk_encryption_set_id

  key_management_service {
    key_vault_key_id = var.key_vault_key_id

    # Currently using "Private" access is in Preview and not generally available.
    # https://learn.microsoft.com/en-us/azure/aks/kms-data-encryption?pivots=cmk-private
    key_vault_network_access = "Public"
  }

  key_vault_secrets_provider {
    secret_rotation_enabled = true
  }

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

### Node Pools ####
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



# https://learn.microsoft.com/en-us/azure/backup/quick-kubernetes-backup-terraform






# Flux extension for GitOps management
# resource "azurerm_kubernetes_cluster_extension" "flux" {
#   name           = "flux"
#   cluster_id     = azurerm_kubernetes_cluster.main.id
#   extension_type = "microsoft.flux"
# }

# resource "azurerm_kubernetes_flux_configuration" "dev_flux" {
#   name       = "example-fc"
#   cluster_id = azurerm_kubernetes_cluster.main.id
#   namespace  = "flux"

#   git_repository {
#     url             = "https://github.com/Azure/arc-k8s-demo"
#     reference_type  = "branch"
#     reference_value = "main"
#   }

#   kustomizations {
#     name = "kustomization-1"

#     post_build {
#       substitute = {
#         example_var = "substitute_with_this"
#       }
#       substitute_from {
#         kind = "ConfigMap"
#         name = "example-configmap"
#       }
#     }
#   }

#   depends_on = [
#     azurerm_kubernetes_cluster_extension.flux
#   ]
# }
