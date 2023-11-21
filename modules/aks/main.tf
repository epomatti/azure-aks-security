resource "azurerm_kubernetes_cluster" "default" {
  name                = "aks-${var.workload}"
  location            = var.location
  resource_group_name = var.resource_group_name
  node_resource_group = "rg-aks-${var.workload}"
  dns_prefix          = "aks${var.workload}"

  sku_tier                  = "Free"
  local_account_disabled    = var.local_account_disabled
  automatic_channel_upgrade = "patch"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = var.vm_size
  }

  identity {
    type = "SystemAssigned"
  }

  azure_active_directory_role_based_access_control {
    managed            = true # Azure will create and manage the Service Principal
    azure_rbac_enabled = false
  }
}
