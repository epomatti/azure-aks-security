output "aks_cluster_id" {
  value = azurerm_kubernetes_cluster.main.id
}

output "client_certificate" {
  value     = azurerm_kubernetes_cluster.main.kube_config[0].client_certificate
  sensitive = true
}
