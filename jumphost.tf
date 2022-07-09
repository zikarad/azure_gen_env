locals {
  project  = "exaproject"
  location = var.location

  tags = {
    stage     = var.stage
    project   = local.project
    managedby = "terraform"
    author    = "zikar"
  }
}

resource "azurerm_resource_group" "proj-rg" {
  name     = join("-", [var.stage_sh, var.location_sh, local.project])
  location = local.location
}


/* AVAILABILITY SET */
resource "azurerm_availability_set" "jh-ays" {
  name                = join("-", [var.stage_sh, var.location_sh, local.project, "jh"])
  location            = local.location
  resource_group_name = azurerm_resource_group.proj-rg.name
}


/* Virtual machines */

resource "azurerm_public_ip" "pip-jh" {
  count               = var.jh-count
  name                = "pip-jh${count.index + 1}"
  location            = azurerm_resource_group.proj-rg.location
  resource_group_name = azurerm_resource_group.proj-rg.name
  #  public_ip_address_allocation = "Dynamic"
  idle_timeout_in_minutes = 30
  allocation_method       = "Static"

  tags = local.tags
}

resource "azurerm_network_interface" "nic-jh" {
  count               = var.jh-count
  name                = "${local.project}-nic-jh${count.index + 1}"
  location            = var.location
  resource_group_name = azurerm_resource_group.proj-rg.name
  enable_accelerated_networking = var.jh-accnic

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
  name                  = "${local.project}-jh${count.index + 1}"
  location              = azurerm_resource_group.proj-rg.location
  resource_group_name   = azurerm_resource_group.proj-rg.name
  network_interface_ids = [element(azurerm_network_interface.nic-jh.*.id, count.index)]
  vm_size               = var.jh-size
  availability_set_id   = azurerm_availability_set.jh-ays.id
  delete_os_disk_on_termination = true

  storage_image_reference {
    publisher = var.os_publisher
    offer     = var.os_offer
    sku       = var.os_sku
    version   = "latest"
  }

  storage_os_disk {
    name              = "osdisk-${local.project}-jh${count.index + 1}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "${local.project}-jh${count.index + 1}"
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
