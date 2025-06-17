locals {
  name = "jump-server-${var.workload}"
}

resource "azurerm_public_ip" "main" {
  name                = "pip-${local.name}"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "main" {
  name                = "nic-${local.name}"
  resource_group_name = var.resource_group_name
  location            = var.location

  ip_configuration {
    name                          = "ipconfig001"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.main.id
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "azurerm_linux_virtual_machine" "main" {
  name                  = "vm-${local.name}"
  resource_group_name   = var.resource_group_name
  location              = var.location
  size                  = var.vm_size
  admin_username        = var.vm_admin_username
  network_interface_ids = [azurerm_network_interface.main.id]

  # Not supported for ARM64 images
  secure_boot_enabled = false
  vtpm_enabled        = false

  custom_data = filebase64("${path.module}/custom_data/ubuntu.sh")

  identity {
    type = "UserAssigned"
    identity_ids = [
      var.user_assigned_identity_id
    ]
  }

  admin_ssh_key {
    username   = var.vm_admin_username
    public_key = file(var.vm_public_key_path)
  }

  os_disk {
    name                 = "osdisk-${local.name}"
    caching              = "ReadOnly"
    storage_account_type = var.vm_osdisk_storage_account_type
  }

  source_image_reference {
    publisher = var.vm_image_publisher
    offer     = var.vm_image_offer
    sku       = var.vm_image_sku
    version   = var.vm_image_version
  }

  lifecycle {
    ignore_changes = [custom_data]
  }
}
