/* Virtual machines */

resource "azurerm_public_ip" "pip-dev-web1" {
  name		= "pip1"
  location	= "${azurerm_resource_group.RG1.location}"
  resource_group_name = "${azurerm_resource_group.RG1.name}"
  public_ip_address_allocation = "Dynamic"
  idle_timeout_in_minutes      = 30

  tags {
    environment = "dev"
  }
}

resource "azurerm_public_ip" "pip-dev-web2" {
  name      = "pip2"
  location  = "${azurerm_resource_group.RG1.location}"
  resource_group_name = "${azurerm_resource_group.RG1.name}"
  public_ip_address_allocation = "Dynamic"
  idle_timeout_in_minutes      = 30 

  tags {
    environment = "dev"
  }  
}

resource "azurerm_network_interface" "nic1" {
  name                = "${var.prefix}-nic-jh1"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.RG1.name}"

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = "${azurerm_subnet.sn-dev-pub.id}"
    private_ip_address_allocation = "dynamic"
	public_ip_address_id          = "${azurerm_public_ip.pip-dev-web1.id}"
  }

  tags {
	environment = "dev"
  }

}

resource "azurerm_network_interface" "nic2" {
  name                = "${var.prefix}-nic-web1"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.RG1.name}"

  ip_configuration {
    name                          = "testconfiguration2"
    subnet_id                     = "${azurerm_subnet.sn-dev-pub.id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = "${azurerm_public_ip.pip-dev-web2.id}"
  }  

  tags {
    environment = "dev"
  }

}


resource "azurerm_virtual_machine" "dev-jh" {
  name                  = "${var.prefix}-dev-jh"
  location              = "${azurerm_resource_group.RG1.location}"
  resource_group_name   = "${azurerm_resource_group.RG1.name}"
  network_interface_ids = ["${azurerm_network_interface.nic1.id}"]
  vm_size               = "Standard_B1ms"

  storage_image_reference {
    publisher = "${var.os_publisher}"
    offer     = "${var.os_offer}"
    sku       = "${var.os_sku}"
    version   = "latest"
  }

  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "${azurerm_resource_group.RG1.name}-djh"
    admin_username = "${var.admin_user_username}"
  }

  os_profile_linux_config {
    disable_password_authentication = true
		ssh_keys = [{
			path			= "/home/${var.admin_user_username}/.ssh/authorized_keys"
			key_data	= "${file("~/.ssh/azure-test1.pub")}"
		}]
  }

  tags {
    environment = "dev"
	role = "jumphost"
  }
}

/* Webserver */

resource "azurerm_virtual_machine" "dev-web1" {
  name                  = "${var.prefix}-dev-web1"
  location              = "${azurerm_resource_group.RG1.location}"
  resource_group_name   = "${azurerm_resource_group.RG1.name}"
  network_interface_ids = ["${azurerm_network_interface.nic2.id}"]
  vm_size               = "Standard_B1ms"

  storage_image_reference {
    publisher = "${var.os_publisher}"
    offer     = "${var.os_offer}"
    sku       = "${var.os_sku}"
    version   = "latest"
  }

  storage_os_disk {
    name              = "myosdisk2"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "${azurerm_resource_group.RG1.name}-dweb1"
    admin_username = "${var.admin_user_username}"
  }

  os_profile_linux_config {
    disable_password_authentication = true
        ssh_keys = [{
            path            = "/home/${var.admin_user_username}/.ssh/authorized_keys"
            key_data    = "${file("~/.ssh/azure-test1.pub")}"
        }]
  }
}
