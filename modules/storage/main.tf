resource "azurerm_storage_account" "default" {
  name                          = "staksazcloudsh789"
  resource_group_name           = var.resource_group_name
  location                      = var.location
  account_tier                  = "Standard"
  account_replication_type      = "LRS"
  account_kind                  = "StorageV2"
  https_traffic_only_enabled    = true
  min_tls_version               = "TLS1_2"
  public_network_access_enabled = true

  network_rules {
    default_action = "Deny"
    ip_rules       = var.network_ip_rules
    bypass         = ["AzureServices"]
  }

  tags = {
    # This is added eventually by the Azure Cloud Shell
    ms-resource-usage = "azure-cloud-shell"
  }

  lifecycle {
    ignore_changes = [
      network_rules[0].private_link_access
    ]
  }
}

resource "azurerm_storage_share" "file_share" {
  name               = "cloud-shell"
  storage_account_id = azurerm_storage_account.default.id
  quota              = 50
}
