/* AVAILABILITY SET */
resource "azurerm_availability_set" "web-ays" {
  name                = join("-", [var.stage.short, var.location.short, local.project, "web"])
  location            = var.location.long
  resource_group_name = azurerm_resource_group.proj-rg.name
  proximity_placement_group_id = azurerm_proximity_placement_group.webdb.id
  platform_fault_domain_count = 2
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
  location            = var.location.long
  resource_group_name = azurerm_resource_group.proj-rg.name
  accelerated_networking_enabled  = var.web-accnic

  ip_configuration {
    name                          = "testconfiguration${count.index + 1}"
    subnet_id                     = azurerm_subnet.subnets["sn-pub"].id
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
  proximity_placement_group_id = azurerm_proximity_placement_group.webdb.id
  delete_os_disk_on_termination = true

  storage_image_reference {
    publisher = var.os_map.x86_64.publisher
    offer     = var.os_map.x86_64.offer
    sku       = var.os_map.x86_64.sku
    version   = "latest"
  }

  storage_os_disk {
    name              = "osdisk-${local.project}-web${count.index + 1}"
    caching           = var.web-os-disk-caching
    create_option     = "FromImage"
    managed_disk_type = var.web-os-disk-type
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

resource "azurerm_managed_disk" "web-data" {
  count                 = var.web-count * var.web-data-disk-count
  name = "${local.project}-web${ceil((count.index+1) / var.web-data-disk-count)}-data${(count.index+1) - var.web-data-disk-count*floor((count.index+1)/var.web-data-disk-count)}"
  location              = azurerm_resource_group.proj-rg.location
  resource_group_name   = azurerm_resource_group.proj-rg.name
  storage_account_type  = var.web-data-disk-type
  disk_size_gb          = var.web-data-disk-size
  create_option         = "Empty"
}

resource "azurerm_virtual_machine_data_disk_attachment" "web-data-datt" {
  count                 = var.web-count * var.web-data-disk-count
  managed_disk_id       = azurerm_managed_disk.web-data[count.index].id
  virtual_machine_id    = azurerm_virtual_machine.vm-web[ceil((count.index+1)/var.web-data-disk-count)-1].id
  lun                   = (count.index+1) - var.web-data-disk-count*floor((count.index+1)/var.web-data-disk-count)
  caching               = var.web-data-disk-caching
}
