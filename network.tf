resource "azurerm_virtual_network" "vnet" {
  name                = var.name
  address_space       = [var.IP-CIDR]
  location            = azurerm_resource_group.RG-KK-Backups.location
  resource_group_name = azurerm_resource_group.RG-KK-Backups.name
}

resource "azurerm_subnet" "vnet_vm_subnet" {
  name                 = "subnet-${var.name}-vm"
  resource_group_name  = azurerm_resource_group.RG-KK-Backups.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.subnets["vm_subnet"]]
  default_outbound_access_enabled = true
}

resource "azurerm_subnet" "vnet_pe_subnet" {
  name                              = "subnet-${var.name}-pe"
  resource_group_name               = azurerm_resource_group.RG-KK-Backups.name
  virtual_network_name              = azurerm_virtual_network.vnet.name
  address_prefixes                  = [var.subnets["pe_subnet"]]
  private_endpoint_network_policies = "Enabled"
  default_outbound_access_enabled = true
}


resource "azurerm_private_endpoint" "pe_backups" {
  name                = "${var.name}-pe"
  location            = azurerm_resource_group.RG-KK-Backups.location
  resource_group_name = azurerm_resource_group.RG-KK-Backups.name
  subnet_id           = azurerm_subnet.vnet_pe_subnet.id

  ip_configuration {
    name               = "pe-backups-ipconfig"
    private_ip_address = var.pe_ip_address
    subresource_name   = "blob"
    member_name        = "blob"
  }

  private_service_connection {
    name                           = "pe-connection"
    private_connection_resource_id = azurerm_storage_account.kk_storage_account.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }

  private_dns_zone_group {
    name                 = "pe-backups-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.backups-zone.id]
  }
}


### DNS Zone for Private Endpoint

resource "azurerm_private_dns_zone" "backups-zone" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.RG-KK-Backups.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "private-zone-link-vnet-spoke" {
  name                 = "private-zone-link-${var.name}"
  private_dns_zone_id  = azurerm_private_dns_zone.backups-zone.id
  virtual_network_id   = azurerm_virtual_network.vnet.id
  registration_enabled = false
}