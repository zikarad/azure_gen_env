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
  name                = "${local.project}-nic-web${count.index + 1}"
  location            = var.location
  resource_group_name = azurerm_resource_group.proj-rg.name
  enable_accelerated_networking = var.web-accnic

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
  name                  = "${local.project}-web${count.index + 1}"
  location              = azurerm_resource_group.proj-rg.location
  resource_group_name   = azurerm_resource_group.proj-rg.name
  network_interface_ids = ["${element(azurerm_network_interface.nic-web.*.id, count.index)}"]
  vm_size               = var.web-size
  availability_set_id   = azurerm_availability_set.web-ays.id
  delete_os_disk_on_termination = true

  storage_image_reference {
    publisher = var.os_map.publisher
    offer     = var.os_map.offer
    sku       = var.os_map.sku
    version   = "latest"
  }

  storage_os_disk {
    name              = "osdisk-${local.project}-web${count.index + 1}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "${local.project}-web${count.index + 1}"
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
