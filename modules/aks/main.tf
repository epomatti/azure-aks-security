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

### Cluster ###
resource "azurerm_kubernetes_cluster" "default" {
  name                = "aks-${var.workload}"
  location            = var.location
  resource_group_name = var.resource_group_name
  node_resource_group = "rg-aks-${var.workload}"
  dns_prefix          = "aks${var.workload}"

  sku_tier                  = "Free"
  local_account_disabled    = var.local_account_disabled
  automatic_channel_upgrade = "patch"

  # TODO: Learn this
  # https://learn.microsoft.com/en-us/azure/governance/policy/concepts/policy-for-kubernetes
  azure_policy_enabled = true

  default_node_pool {
    name           = "default"
    node_count     = 1
    vm_size        = var.vm_size
    vnet_subnet_id = var.node_pool_subnet_id
  }

  network_profile {
    network_plugin    = "kubenet"
    network_policy    = null # TODO: Implement Calico
    load_balancer_sku = "standard"

    # This will not integrate with the existing VNET
    # however, it must not overlap with an existing Subnet
    service_cidr   = "10.0.90.0/24"
    dns_service_ip = "10.0.90.10"
  }

  api_server_access_profile {
    authorized_ip_ranges = var.authorized_ip_ranges
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.aks.id]
  }

  # Managed property will now default to "true"
  azure_active_directory_role_based_access_control {
    azure_rbac_enabled = var.azure_rbac_enabled
  }

  lifecycle {
    ignore_changes = [
      # Application routing will be enabled via CLI.
      web_app_routing
    ]
  }
}

resource "azurerm_role_assignment" "acr" {
  principal_id                     = azurerm_kubernetes_cluster.default.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = var.acr_id
  skip_service_principal_aad_check = true
}
