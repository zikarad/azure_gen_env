locals {
  project  = "proj1"
  location = var.location

  tags = {
    stage     = var.stage
    project   = local.project
    managedby = "terraform"
    author    = "zikar"
  }
}

resource "azurerm_resource_group" "rg-proj1" {
  name     = join("-", [var.stage_sh, var.location_sh, local.project])
  location = local.location
}


/* Virtual machines */

resource "azurerm_public_ip" "pip-jh" {
  count               = var.jh-count
  name                = "pip-jh${count.index + 1}"
  location            = azurerm_resource_group.rg-proj1.location
  resource_group_name = azurerm_resource_group.rg-proj1.name
  #  public_ip_address_allocation = "Dynamic"
  idle_timeout_in_minutes = 30
  allocation_method       = "Static"

  tags = local.tags
}

resource "azurerm_network_interface" "nic-jh" {
  count               = var.jh-count
  name                = "${var.project}-nic-jh${count.index + 1}"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg-proj1.name

  ip_configuration {
    name                          = "testconfiguration${count.index + 1}"
    subnet_id                     = azurerm_subnet.sn-pub.id
    public_ip_address_id          = element(azurerm_public_ip.pip-jh.*.id, count.index)
    private_ip_address_allocation = "Dynamic"
  }

  tags = local.tags
}


/* Jumphosts */

resource "azurerm_virtual_machine" "vm-jh" {
  count                 = var.jh-count
  name                  = "${var.project}-jh${count.index + 1}"
  location              = azurerm_resource_group.rg-proj1.location
  resource_group_name   = azurerm_resource_group.rg-proj1.name
  network_interface_ids = [element(azurerm_network_interface.nic-jh.*.id, count.index)]
  vm_size               = var.jh-size

  storage_image_reference {
    publisher = var.os_publisher
    offer     = var.os_offer
    sku       = var.os_sku
    version   = "latest"
  }

  storage_os_disk {
    name              = "osdisk-${var.project}-jh${count.index + 1}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "${var.project}-jh${count.index + 1}"
    admin_username = var.azure_admin_username
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path     = "/home/${var.azure_admin_username}/.ssh/authorized_keys"
      key_data = file("${var.sshkey_path}")
    }
  }

  tags = local.tags
}


/* ASSOCIATE NICs with NSG */

resource "azurerm_network_interface_security_group_association" "nsgassoc-jh" {
  count                     = var.jh-count
  network_interface_id      = azurerm_network_interface.nic-jh[count.index].id
  network_security_group_id = azurerm_network_security_group.nsg-jh.id
}
