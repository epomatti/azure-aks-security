resource "azuread_user" "aks_cluster_admin" {
  account_enabled     = true
  user_principal_name = "AKSClusterAdmin@${var.entraid_tenant_domain}"
  display_name        = "AKS Cluster Admin"
  mail_nickname       = "AKSClusterAdmin"
  password            = "P4ssw0rd.1234"
}

resource "azurerm_role_assignment" "aks_cluster_admin" {
  scope                = var.aks_cluster_resource_id
  role_definition_name = "Azure Kubernetes Service RBAC Cluster Admin"
  principal_id         = azuread_user.aks_cluster_admin.id
}

resource "azurerm_role_assignment" "storage" {
  scope                = var.storage_account_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azuread_user.aks_cluster_admin.id
}
