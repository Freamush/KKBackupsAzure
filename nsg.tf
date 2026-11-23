resource "azurerm_application_security_group" "asg_vpn" {
  name                = "asg-${var.name}-vpn"
  location            = azurerm_resource_group.RG-KK-Backups.location
  resource_group_name = azurerm_resource_group.RG-KK-Backups.name
}

resource "azurerm_application_security_group" "asg_pe" {
  name                = "asg-${var.name}-pe"
  location            = azurerm_resource_group.RG-KK-Backups.location
  resource_group_name = azurerm_resource_group.RG-KK-Backups.name
}

# Router (VM) NIC associated with asg-vpn
resource "azurerm_network_interface_application_security_group_association" "vpn_nic_asg" {
  network_interface_id          = azurerm_network_interface.vpn_nic.id
  application_security_group_id = azurerm_application_security_group.asg_vpn.id
}

# Private Endpoint associated with asg-pe
resource "azurerm_private_endpoint_application_security_group_association" "pe_asg" {
  private_endpoint_id           = azurerm_private_endpoint.pe_backups.id
  application_security_group_id = azurerm_application_security_group.asg_pe.id
}

##### VPN Route  NSG
resource "azurerm_network_security_group" "nsg_vpn" {
  name                = "nsg-${var.name}-vm"
  location            = azurerm_resource_group.RG-KK-Backups.location
  resource_group_name = azurerm_resource_group.RG-KK-Backups.name

  security_rule {
    name                       = "Deny-All-In"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "nsg_vpn_assoc" {
  subnet_id                 = azurerm_subnet.vnet_vm_subnet.id
  network_security_group_id = azurerm_network_security_group.nsg_vpn.id
}


##### PE NSG
resource "azurerm_network_security_group" "nsg_pe" {
  name                = "nsg-${var.name}-pe"
  location            = azurerm_resource_group.RG-KK-Backups.location
  resource_group_name = azurerm_resource_group.RG-KK-Backups.name

  security_rule {
    name                                       = "Allow-HTTPS-Router-to-PE"
    priority                                   = 100
    direction                                  = "Inbound"
    access                                     = "Allow"
    protocol                                   = "Tcp"
    source_port_range                          = "*"
    destination_port_range                     = "443"
    source_application_security_group_ids      = [azurerm_application_security_group.asg_vpn.id]
    destination_application_security_group_ids = [azurerm_application_security_group.asg_pe.id]
  }

  security_rule {
    name                       = "Deny-All-In"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "nsg_pe_assoc" {
  subnet_id                 = azurerm_subnet.vnet_pe_subnet.id
  network_security_group_id = azurerm_network_security_group.nsg_pe.id
}