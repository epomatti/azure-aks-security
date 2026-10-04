output "key_vault_id" {
  value = azurerm_key_vault.default.id
}

output "key_vault_uri" {
  value = azurerm_key_vault.default.vault_uri
}

output "kubernetes_cluster_key_id" {
  value = azurerm_key_vault_key.kubernetes_cluster.id
}
