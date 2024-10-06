/* AVAILABILITY SET */
resource "azurerm_availability_set" "be-ays" {
  name                = join("-", [var.stage.short, var.location.short, local.project, "be"])
  location            = var.location.long
  resource_group_name = azurerm_resource_group.proj-rg.name
  proximity_placement_group_id = azurerm_proximity_placement_group.webdb.id
  platform_fault_domain_count = 2
}

/* VIRTUAL MACHINES */
resource "azurerm_network_interface" "inic-be" {
  count               = var.be-count
  name                = "${local.project}-inic-be${count.index + 1}"
  location            = var.location.long
  resource_group_name = azurerm_resource_group.proj-rg.name
  enable_accelerated_networking = var.web-accnic

  ip_configuration {
    name                          = "privipconf${count.index + 1}"
    subnet_id                     = azurerm_subnet.subnets["sn-priv"].id
    private_ip_address_allocation = "Dynamic"
  }

  tags = local.tags
}

resource "azurerm_virtual_machine" "vm-be" {
  count                 = var.be-count
  name                  = "${local.project}-be${count.index + 1}"
  location              = azurerm_resource_group.proj-rg.location
  resource_group_name   = azurerm_resource_group.proj-rg.name
  network_interface_ids = [element(azurerm_network_interface.inic-be.*.id, count.index)]
  vm_size               = var.be-size
  availability_set_id   = azurerm_availability_set.be-ays.id
  proximity_placement_group_id = azurerm_proximity_placement_group.webdb.id
  delete_os_disk_on_termination = true

  identity {
    type = "SystemAssigned"
  }

  storage_image_reference {
    publisher = var.os_map.x86_64.publisher
    offer     = var.os_map.x86_64.offer
    sku       = var.os_map.x86_64.sku
    version   = "latest"
  }

  storage_os_disk {
    name              = "osdisk-${local.project}-be${count.index + 1}"
    caching           = var.be-os-disk-caching
    create_option     = "FromImage"
    managed_disk_type = var.be-os-disk-type
  }

  os_profile {
    computer_name  = "${local.project}-be${count.index + 1}"
    admin_username = var.azure_admin_username
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path     = "/home/${var.azure_admin_username}/.ssh/authorized_keys"
      key_data = file(var.sshkey_path)
    }
  }
}

resource "azurerm_managed_disk" "be-data" {
  count                 = var.be-count * var.be-data-disk-count
  name = "${local.project}-be${ceil((count.index+1) / var.be-data-disk-count)}-data${(count.index+1) - var.be-data-disk-count*floor((count.index+1)/var.be-data-disk-count)}"
  location              = azurerm_resource_group.proj-rg.location
  resource_group_name   = azurerm_resource_group.proj-rg.name
  storage_account_type  = var.be-data-disk-type
  disk_size_gb          = var.be-data-disk-size
  create_option         = "Empty"
}

resource "azurerm_virtual_machine_data_disk_attachment" "be-data-datt" {
  count                 = var.be-count * var.be-data-disk-count
  managed_disk_id       = azurerm_managed_disk.be-data[count.index].id
  virtual_machine_id    = azurerm_virtual_machine.vm-be[ceil((count.index+1)/var.be-data-disk-count)-1].id
  lun                   = (count.index+1) - var.be-data-disk-count*floor((count.index+1)/var.be-data-disk-count)
  caching               = var.be-data-disk-caching
}
