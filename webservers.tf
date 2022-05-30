/* AVAILABILITY SET */
resource "azurerm_availability_set" "web-ays" {
  name                = join("-", [var.stage_sh, var.location_sh, local.project, "web"])
  location            = local.location
  resource_group_name = azurerm_resource_group.proj-rg.name
}

/* VIRTUAL MACHINES */
resource "azurerm_public_ip" "pip-web" {
  count               = var.web-count
  name                = "pip-web${count.index + 1}"
  location            = azurerm_resource_group.proj-rg.location
  resource_group_name = azurerm_resource_group.proj-rg.name
  #  public_ip_address_allocation = "Dynamic"
  idle_timeout_in_minutes = 30
  allocation_method       = "Static"

  tags = local.tags
}

resource "azurerm_network_interface" "nic-web" {
  count               = var.web-count
  name                = "${var.project}-nic-web${count.index + 1}"
  location            = var.location
  resource_group_name = azurerm_resource_group.proj-rg.name

  ip_configuration {
    name                          = "testconfiguration${count.index + 1}"
    subnet_id                     = azurerm_subnet.sn-pub.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = element(azurerm_public_ip.pip-web.*.id, count.index)
  }

  tags = local.tags
}

resource "azurerm_virtual_machine" "vm-web" {
  count                 = var.web-count
  name                  = "${var.project}-web${count.index + 1}"
  location              = azurerm_resource_group.proj-rg.location
  resource_group_name   = azurerm_resource_group.proj-rg.name
  network_interface_ids = ["${element(azurerm_network_interface.nic-web.*.id, count.index)}"]
  vm_size               = var.web-size
  availability_set_id   = azurerm_availability_set.web-ays.id

  storage_image_reference {
    publisher = var.os_publisher
    offer     = var.os_offer
    sku       = var.os_sku
    version   = "latest"
  }

  storage_os_disk {
    name              = "osdisk-${var.project}-web${count.index + 1}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "${var.project}-web${count.index + 1}"
    admin_username = var.azure_admin_username
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path     = "/home/${var.azure_admin_username}/.ssh/authorized_keys"
      key_data = file("${var.sshkey_path}")
    }
  }
}

/* STORAGE ACCOUNT */

resource "azurerm_storage_account" "proj-sa" {
  count                    = var.sa-enable-bool ? 1 : 0
  name                     = "sarztest"
  resource_group_name      = azurerm_resource_group.proj-rg.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  tags = local.tags
}
