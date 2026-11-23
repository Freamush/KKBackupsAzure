resource "azuread_application" "restic" {
  display_name = "sp-kk-restic"
  owners       = [data.azuread_client_config.current.object_id]
}

resource "azuread_service_principal" "restic" {
  client_id = azuread_application.restic.client_id
  owners    = [data.azuread_client_config.current.object_id]
}

data "tls_certificate" "restic" {
  content = file("${path.module}/certs/kk-restic.crt")
}

resource "azuread_application_certificate" "restic" {
  application_id = azuread_application.restic.id
  type           = "AsymmetricX509Cert"
  value          = file("${path.module}/certs/kk-restic.crt")
  start_date     = data.tls_certificate.restic.certificates[0].not_before
  end_date       = data.tls_certificate.restic.certificates[0].not_after
}

resource "azurerm_role_assignment" "restic_blob_contributor" {
  scope                = azurerm_storage_container.kk_backups-container.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azuread_service_principal.restic.object_id
}

output "restic_tenant_id" {
  value = data.azuread_client_config.current.tenant_id
}
 
output "restic_client_id" {
  value = azuread_application.restic.client_id
}