variable "workload" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "cluster_subnet_id" {
  type = string
}

variable "private_dns_zone_id" {
  type = string
}

variable "zones" {
  type = list(string)
}

variable "container_registry_id" {
  type = string
}

variable "user_assigned_identity_id" {
  type = string
}

variable "key_vault_id" {
  type = string
}

variable "key_vault_key_id" {
  type = string
}

variable "disk_encryption_set_id" {
  type = string
}
