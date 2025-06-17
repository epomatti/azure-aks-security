# Project
subscription_id = "00000000-0000-0000-0000-000000000000"
location        = "eastus2"

# Entra ID
entraid_tenant_domain = "<TENANT>"
generic_password      = "P4ssw0rd.1234"

# ACR
acr_sku                     = "Basic"
acr_create_private_endpoint = false

# AKS
aks_vm_size                   = "Standard_B4ps_v2"
aks_cluster_sku_tier          = "Free"
aks_automatic_upgrade_channel = "patch"
aks_node_os_upgrade_channel   = "NodeImage"

aks_private_cluster_public_fqdn_enabled = true
aks_private_cluster_enabled             = true
aks_local_account_disabled              = false
aks_azure_rbac_enabled                  = true

aks_authorized_ip_ranges = ["100.100.100.100/30"]

# Application Gateway for Containers
create_agwc = false

# Application Gateway
create_agw             = false
agw_sku_name           = "Standard_v2"
agw_sku_tier           = "Standard_v2"
agw_sku_capacity       = 1
agw_private_ip_address = "10.0.244.50"

# Web Application Firewall (WAF)
create_waf_policy            = false
attach_waf_policy_to_gateway = false
