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

aks_local_account_disabled = false
aks_azure_rbac_enabled     = true

aks_authorized_ip_ranges = ["1.2.3.4/30"]

# Application Load Balancer
create_alb = false

# Application Gateway
create_agw             = false
agw_sku_name           = "Standard_v2"
agw_sku_tier           = "Standard_v2"
agw_sku_capacity       = 1
agw_private_ip_address = "10.0.244.50"
