data "azurerm_subscription" "current" {
  subscription_id = var.subscription_id
}

# When using VNET integration, User Assigned Identities are strongly recommended (required?) for AKS.
# https://learn.microsoft.com/en-us/azure/aks/configure-kubenet?_ga=2.141939570.1510144942.1703251968-967359652.1700361706
resource "azurerm_user_assigned_identity" "aks" {
  name                = "aks-cluster-${var.workload}-identity"
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_role_assignment" "network_contributor" {
  scope                = var.vnet_id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.aks.principal_id
}

# Private DNS Zone for AKS
# https://learn.microsoft.com/en-us/azure/aks/private-clusters-dns
resource "azurerm_private_dns_zone" "aks" {
  name                = "privatelink.${var.location}.azmk8s.io"
  resource_group_name = var.resource_group_name
}

resource "azurerm_role_assignment" "private_dnz_zone_contributor" {
  scope                = azurerm_private_dns_zone.aks.id
  role_definition_name = "Private DNS Zone Contributor"
  principal_id         = azurerm_user_assigned_identity.aks.principal_id
}

### Cluster ###
resource "azurerm_kubernetes_cluster" "default" {
  name                = "aks-${var.workload}"
  location            = var.location
  resource_group_name = var.resource_group_name
  node_resource_group = "rg-${var.workload}-aks"

  sku_tier                  = var.aks_cluster_sku_tier
  local_account_disabled    = var.local_account_disabled
  automatic_upgrade_channel = var.aks_automatic_upgrade_channel
  node_os_upgrade_channel   = var.aks_node_os_upgrade_channel

  # Must be false for private clusters
  private_cluster_public_fqdn_enabled = false

  dns_prefix_private_cluster = "aks${var.workload}-private"
  private_cluster_enabled    = var.private_cluster_enabled
  private_dns_zone_id        = azurerm_private_dns_zone.aks.id

  # TODO: Learn this
  # https://learn.microsoft.com/en-us/azure/governance/policy/concepts/policy-for-kubernetes
  azure_policy_enabled = true

  default_node_pool {
    name           = "system"
    node_count     = 1
    vm_size        = var.aks_default_node_pool_vm_size
    vnet_subnet_id = var.node_pool_subnet_id

    # Added this as it was diffing with terraform plan
    upgrade_settings {
      drain_timeout_in_minutes      = 0
      max_surge                     = "10%"
      node_soak_duration_in_minutes = 0
    }
  }

  network_profile {
    network_plugin      = var.aks_network_plugin
    network_policy      = var.aks_network_policy
    network_data_plane  = var.aks_network_data_plane
    network_plugin_mode = var.aks_network_plugin_mode
    # network_outbound_type = var.aks_network_outbound_type
    load_balancer_sku = "standard"

    # This will not integrate with the existing VNET
    # however, it must not overlap with an existing Subnet
    service_cidr   = "10.0.90.0/24"
    dns_service_ip = "10.0.90.10"
  }

  dynamic "ingress_application_gateway" {
    for_each = var.create_agw ? [1] : []
    content {
      gateway_id = var.application_gateway_id
    }
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.aks.id]
  }

  # Managed property will now default to "true"
  azure_active_directory_role_based_access_control {
    tenant_id          = data.azurerm_subscription.current.tenant_id
    azure_rbac_enabled = var.azure_rbac_enabled
  }

  lifecycle {
    ignore_changes = [
      # Application routing will be enabled via CLI.
      web_app_routing
    ]
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "user" {
  name                  = "user"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.default.id
  vm_size               = var.aks_user_node_pool_vm_size
  node_count            = 1
  auto_scaling_enabled  = false
  mode                  = "User"
  vnet_subnet_id        = var.node_pool_subnet_id
}

resource "azurerm_role_assignment" "acr" {
  principal_id                     = azurerm_kubernetes_cluster.default.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = var.acr_id
  skip_service_principal_aad_check = true
}

# Jump Server
resource "azurerm_role_assignment" "kubernetes_cluster_admin_jump_server" {
  scope                = var.vnet_id
  role_definition_name = "Azure Arc Kubernetes Cluster Admin"
  principal_id         = var.jump_server_identity_principal_id
}
