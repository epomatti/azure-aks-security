### Current ###
data "azurerm_client_config" "current" {}

# It was necessary to this to work explicitly, event thou I'm creating the resources
resource "azurerm_role_assignment" "me" {
  scope                = var.aks_cluster_resource_id
  role_definition_name = "Azure Kubernetes Service RBAC Cluster Admin"
  principal_id         = data.azurerm_client_config.current.object_id
}


### AKS Contributor ###
resource "azuread_user" "aks_contributor" {
  account_enabled     = true
  user_principal_name = "AKSContributor@${var.entraid_tenant_domain}"
  display_name        = "AKS Contributor"
  mail_nickname       = "AKSContributor"
  password            = "P4ssw0rd.1234"
}

resource "azurerm_role_assignment" "aks_contributor" {
  scope                = var.aks_cluster_resource_id
  role_definition_name = "Azure Kubernetes Service Contributor Role"
  principal_id         = azuread_user.aks_contributor.id
}

resource "azurerm_role_assignment" "storage_contributor" {
  scope                = var.storage_account_id
  role_definition_name = "Storage Account Contributor"
  principal_id         = azuread_user.aks_contributor.id
}

resource "azurerm_role_assignment" "storage_rg_reader" {
  scope                = var.resource_group_id
  role_definition_name = "Reader"
  principal_id         = azuread_user.aks_contributor.id
}
