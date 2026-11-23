resource "azurerm_storage_account" "kk_storage_account" {
  account_kind        = "StorageV2"
  name                = var.storage_account_name
  resource_group_name = azurerm_resource_group.RG-KK-Backups.name

  location                        = azurerm_resource_group.RG-KK-Backups.location
  account_tier                    = "Standard"
  account_replication_type        = "GRS"
  min_tls_version                 = "TLS1_2"
  default_to_oauth_authentication = true
  allow_nested_items_to_be_public = false
  local_user_enabled              = false
  public_network_access = "Disabled"
  shared_access_key_enabled       = false
  access_tier                     = "Hot"
  blob_properties {

    versioning_enabled = true
    delete_retention_policy {
      days = 30
    }
    container_delete_retention_policy {
      days = 30
    }
  }
}

resource "azurerm_storage_container" "kk_backups-container" {

  name                  = "kk-backups-container"
  storage_account_id    = azurerm_storage_account.kk_storage_account.id
  container_access_type = "private"

}