variable "workload" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "vm_size" {
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

variable "authorized_ip_ranges" {
  type = list(string)
}
