variable "subscription_id" {
  type = string
}

variable "workload" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "aks_default_node_pool_vm_size" {
  type = string
}

variable "aks_user_node_pool_vm_size" {
  type = string
}

variable "aks_cluster_sku_tier" {
  type = string
}

variable "aks_automatic_upgrade_channel" {
  type = string
}

variable "aks_node_os_upgrade_channel" {
  type = string
}

variable "vnet_id" {
  type = string
}

variable "node_pool_subnet_id" {
  type = string
}

variable "local_account_disabled" {
  type = bool
}

variable "azure_rbac_enabled" {
  type = bool
}

variable "acr_id" {
  type = string
}

variable "create_agw" {
  type = bool
}

variable "application_gateway_id" {
  type = string
}

variable "private_cluster_enabled" {
  type = bool
}

variable "aks_private_cluster_public_fqdn_enabled" {
  type = bool
}

variable "jump_server_identity_principal_id" {
  type = string
}

variable "aks_network_plugin" {
  type = string
}

variable "aks_network_policy" {
  type = string
}

variable "aks_network_data_plane" {
  type = string
}

variable "aks_network_plugin_mode" {
  type = string
}

# variable "aks_network_outbound_type" {
#   type = string
# }
