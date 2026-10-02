# resource "azurerm_role_assignment" "kubernetes_cluster_admin_jump_server" {
#   scope                = var.vnet_id
#   role_definition_name = "Azure Arc Kubernetes Cluster Admin"
#   principal_id         = var.jump_server_identity_principal_id
# }