variable "workload" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "acr_sku" {
  type = string
}

variable "authorized_ip_ranges" {
  type = list(string)
}
