### Tailscale subnet router VM
# The public IP is kept ONLY for outbound Internet (Tailscale, apt); NSG denies all inbound.
# Taiscale can send traffic directly not using Relay servers
# Microsoft recommends using a public ip or nat gateway, nva for stable outbound traffic. 

resource "azurerm_public_ip" "pip_vpn" {
  name                = "pip-${var.name}-vpn"
  location            = azurerm_resource_group.RG-KK-Backups.location
  resource_group_name = azurerm_resource_group.RG-KK-Backups.name
  sku                 = "Standard"
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "vpn_nic" {
  name                  = "nic-${var.name}-vpn"
  location              = azurerm_resource_group.RG-KK-Backups.location
  resource_group_name   = azurerm_resource_group.RG-KK-Backups.name
  ip_forwarding_enabled = true

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.vnet_vm_subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.vm_ip_address
    public_ip_address_id          = azurerm_public_ip.pip_vpn.id
  }
}

resource "azurerm_linux_virtual_machine" "vpn_vm" {
  name                  = "vm-${var.name}-vpn"
  computer_name         = "kk-vpn"
  location              = azurerm_resource_group.RG-KK-Backups.location
  resource_group_name   = azurerm_resource_group.RG-KK-Backups.name
  size                  = "Standard_B2ts_v2"
  admin_username        = var.username
  network_interface_ids = [azurerm_network_interface.vpn_nic.id]

  disable_password_authentication = true

  admin_ssh_key {
    username   = var.username
    public_key = var.public_key
  }

  os_disk {
    name                 = "osdisk-${var.name}-vpn"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }

  boot_diagnostics {}

custom_data = base64encode(
  replace(
    replace(templatefile("${path.module}/cloud-init.yaml", {
      pe_ip      = var.pe_ip_address
      ts_authkey = var.tailscale_authkey
    }), "\r\n", "\n"),
  "\uFEFF", "")
)

}


