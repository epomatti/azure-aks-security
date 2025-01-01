variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "vnet_id" {
  type = string
}

variable "private_endpoints_subnet_id" {
  type = string
}

variable "container_registry_id" {
  type = string
}

variable "acr_create_private_endpoint" {
  type = bool
}
