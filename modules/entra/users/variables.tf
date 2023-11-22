variable "entraid_tenant_domain" {
  type = string
}

variable "password" {
  type      = string
  sensitive = true
}

variable "aks_cluster_resource_id" {
  type = string
}

variable "storage_account_id" {
  type = string
}

variable "resource_group_id" {
  type = string
}
