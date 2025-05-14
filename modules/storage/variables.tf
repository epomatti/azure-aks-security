variable "workload" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "network_ip_rules" {
  type = list(string)
}
