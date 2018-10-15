/* Virtual machines */

resource "azurerm_public_ip" "pip-dev-jh" {
  count = "${var.jh-count}"
  name		= "pip-dev-jh${count.index+1}"
  location	= "${azurerm_resource_group.RG1.location}"
  resource_group_name = "${azurerm_resource_group.RG1.name}"
  public_ip_address_allocation = "Dynamic"
  idle_timeout_in_minutes      = 30

  tags {
    environment = "dev"
  }
}

resource "azurerm_public_ip" "pip-dev-web" {
  count = "${var.web-count}"
  name		= "pip-dev-web${count.index+1}"
  location	= "${azurerm_resource_group.RG1.location}"
  resource_group_name = "${azurerm_resource_group.RG1.name}"
  public_ip_address_allocation = "Dynamic"
  idle_timeout_in_minutes      = 30

  tags {
    environment = "dev"
  }
}

resource "azurerm_network_interface" "nic-web" {
  count               = "${var.web-count}"
  name                = "${var.prefix}-nic-web${count.index+1}"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.RG1.name}"

  ip_configuration {
    name                          = "testconfiguration${count.index+1}"
    subnet_id                     = "${azurerm_subnet.sn-dev-pub.id}"
    private_ip_address_allocation = "dynamic"
	public_ip_address_id          = "${element(azurerm_public_ip.pip-dev-web.*.id, count.index)}"
  }

  tags {
	environment = "dev"
  }
}

resource "azurerm_network_interface" "nic-jh" {
  count               = "${var.jh-count}"
  name                = "${var.prefix}-nic-jh${count.index+1}"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.RG1.name}"

  ip_configuration {
    name                          = "testconfiguration${count.index+1}"
    subnet_id                     = "${azurerm_subnet.sn-dev-pub.id}"
    private_ip_address_allocation = "dynamic"
	public_ip_address_id          = "${element(azurerm_public_ip.pip-dev-jh.*.id, count.index)}"
  }

  tags {
	environment = "dev"
  }
}

/* Jumphosts */
resource "azurerm_virtual_machine" "vm-dev-jh" {
  count                 = "${var.jh-count}"
  name                  = "${var.prefix}-dev-jh${count.index+1}"
  location              = "${azurerm_resource_group.RG1.location}"
  resource_group_name   = "${azurerm_resource_group.RG1.name}"
  network_interface_ids = ["${element(azurerm_network_interface.nic-jh.*.id, count.index)}"]
  vm_size               = "${var.jh-size}"

  storage_image_reference {
    publisher = "${var.os_publisher}"
    offer     = "${var.os_offer}"
    sku       = "${var.os_sku}"
    version   = "latest"
  }

  storage_os_disk {
    name              = "osdisk-${var.prefix}-dev-jh${count.index+1}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "${var.prefix}-dev-jh${count.index+1}"
    admin_username = "${var.azure_admin_username}"
  }

  os_profile_linux_config {
    disable_password_authentication = true
		ssh_keys = [{
			path			= "/home/${var.azure_admin_username}/.ssh/authorized_keys"
			key_data	= "${file("${var.sshkey_path}")}"
		}]
  }

  tags {
    environment = "dev"
	  role        = "jumphost"
  }
}

/* Webservers */
resource "azurerm_virtual_machine" "vm-dev-web" {
  count                 = "${var.web-count}"
  name                  = "${var.prefix}-dev-web${count.index+1}"
  location              = "${azurerm_resource_group.RG1.location}"
  resource_group_name   = "${azurerm_resource_group.RG1.name}"
  network_interface_ids = ["${element(azurerm_network_interface.nic-web.*.id, count.index)}"]
  vm_size               = "${var.web-size}"

  storage_image_reference {
    publisher = "${var.os_publisher}"
    offer     = "${var.os_offer}"
    sku       = "${var.os_sku}"
    version   = "latest"
  }

  storage_os_disk {
    name              = "osdisk-${var.prefix}-dev-web${count.index+1}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "${var.prefix}-dev-web${count.index+1}"
    admin_username = "${var.azure_admin_username}"
  }

  os_profile_linux_config {
    disable_password_authentication = true
        ssh_keys = [{
            path            = "/home/${var.azure_admin_username}/.ssh/authorized_keys"
            key_data    = "${file("${var.sshkey_path}")}"
        }]
  }
}
