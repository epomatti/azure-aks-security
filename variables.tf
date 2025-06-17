variable "subscription_id" {
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

variable "entraid_tenant_domain" {
  type = string
}

variable "generic_password" {
  type      = string
  sensitive = true
}

variable "aks_local_account_disabled" {
  type = bool
}

variable "aks_azure_rbac_enabled" {
  type = bool
}

variable "aks_authorized_ip_ranges" {
  type = list(string)
}

variable "aks_private_cluster_enabled" {
  type = bool
}

# ACR
variable "acr_sku" {
  type = string
}

variable "acr_create_private_endpoint" {
  type = bool
}

# Application Gateway for Containers
variable "create_agwc" {
  type = bool
}

# Application Gateway
variable "create_agw" {
  type = bool
}

variable "agw_sku_name" {
  type = string
}

variable "agw_sku_tier" {
  type = string
}

variable "agw_sku_capacity" {
  type = number
}

variable "agw_private_ip_address" {
  type = string
}

# Web Application Firewall (WAF)
variable "create_waf_policy" {
  type = bool
}

variable "attach_waf_policy_to_gateway" {
  type = bool
}

# Jump Server
variable "vm_jump_admin_username" {
  type = string
}

variable "vm_jump_public_key_path" {
  type = string
}

variable "vm_jump_size" {
  type = string
}

variable "vm_jump_osdisk_storage_account_type" {
  type = string
}

variable "vm_jump_image_publisher" {
  type = string
}

variable "vm_jump_image_offer" {
  type = string
}

variable "vm_jump_image_sku" {
  type = string
}

variable "vm_jump_image_version" {
  type = string
}
