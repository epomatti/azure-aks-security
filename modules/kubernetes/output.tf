output "aks_cluster_id" {
  value = azurerm_kubernetes_cluster.default.id
}

output "client_certificate" {
  value     = azurerm_kubernetes_cluster.default.kube_config[0].client_certificate
  sensitive = true
}
