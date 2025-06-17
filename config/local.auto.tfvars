# Project
subscription_id          = "00000000-0000-0000-0000-000000000000"
location                 = "eastus2"
aks_authorized_ip_ranges = ["100.100.100.100/32"]

# Entra ID
entraid_tenant_domain = "<TENANT>"
generic_password      = "P4ssw0rd.1234"

# ACR
acr_sku                     = "Basic"
acr_create_private_endpoint = false

# AKS
aks_default_node_pool_vm_size = "Standard_B2pls_v2"
aks_user_node_pool_vm_size    = "Standard_B2pls_v2"
aks_cluster_sku_tier          = "Free"
aks_automatic_upgrade_channel = "patch"
aks_node_os_upgrade_channel   = "NodeImage"

aks_private_cluster_enabled = true
aks_local_account_disabled  = false
aks_azure_rbac_enabled      = true

# Jump Server
vm_jump_admin_username              = "azureuser"
vm_jump_public_key_path             = ".keys/tmp_rsa.pub"
vm_jump_size                        = "Standard_B2pts_v2"
vm_jump_osdisk_storage_account_type = "StandardSSD_LRS"
vm_jump_image_publisher             = "canonical"
vm_jump_image_offer                 = "ubuntu-24_04-lts"
vm_jump_image_sku                   = "server-arm64"
vm_jump_image_version               = "latest"

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
