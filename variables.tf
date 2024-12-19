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
