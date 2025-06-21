variable "workload" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "ssh_allowed_ips" {
  type = list(string)
}
