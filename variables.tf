variable "subscription_id" {
  type = string
}

variable "location" {
  type = string
}

variable "aks_vm_size" {
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

# ACR
variable "acr_sku" {
  type = string
}

variable "acr_create_private_endpoint" {
  type = bool
}
