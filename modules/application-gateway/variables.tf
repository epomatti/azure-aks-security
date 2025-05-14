variable "workload" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "virtual_network_name" {
  type = string
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

variable "waf_policy_id" {
  type = string
}
