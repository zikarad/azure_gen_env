resource "azurerm_resource_group" "RG1" {
  name     = "rg-${var.prefix}"
  location = "${var.location}"

  tags {
    name = "${var.prefix}"
	  stage = "test"
  }
}

/* VNET - VLANs */

resource "azurerm_virtual_network" "vnet-rg1" {
  name			= "vnet-${var.prefix}"
  address_space	= ["10.0.0.0/16"]
  location		= "${var.location}"
  resource_group_name	= "${azurerm_resource_group.RG1.name}"
}

/* subnets */

resource "azurerm_subnet" "sn-dev-pub" {
  name					= "dev-public"
  resource_group_name	= "${azurerm_resource_group.RG1.name}"
  virtual_network_name 	= "${azurerm_virtual_network.vnet-rg1.name}"
  address_prefix		= "10.0.1.0/24"

	network_security_group_id = "${azurerm_network_security_group.devpub.id}"
}


resource "azurerm_subnet" "sn-dev-priv" {
  name					= "dev-private"
  resource_group_name 	= "${azurerm_resource_group.RG1.name}"
  virtual_network_name 	= "${azurerm_virtual_network.vnet-rg1.name}"
  address_prefix		= "10.0.2.0/24"

	network_security_group_id = "${azurerm_network_security_group.devpriv.id}"
}

resource "azurerm_subnet" "sn-prod-pub" {
  name					= "prod-public"
  resource_group_name	= "${azurerm_resource_group.RG1.name}"
  virtual_network_name  = "${azurerm_virtual_network.vnet-rg1.name}"
  address_prefix        = "10.0.3.0/24"

  network_security_group_id = "${azurerm_network_security_group.prodpub.id}"
}


resource "azurerm_subnet" "sn-prod-priv" {
  name					= "prod-private"
  resource_group_name	= "${azurerm_resource_group.RG1.name}"
  virtual_network_name  = "${azurerm_virtual_network.vnet-rg1.name}"
  address_prefix        = "10.0.4.0/24"

	network_security_group_id = "${azurerm_network_security_group.prodpriv.id}"

}

/* Network security groups */

resource "azurerm_network_security_group" "devpriv" {
	name = "nsg-devpriv"
	location = "${var.location}"
  resource_group_name	= "${azurerm_resource_group.RG1.name}"

	security_rule {
		name                       = "allow-ssh"
		priority                   = 1124
		direction                  = "Inbound"
		access                     = "Allow"
		protocol                   = "Tcp"
		source_port_range          = "*"
		destination_port_range     = "22"
		source_address_prefix      = "${azurerm_subnet.sn-dev-pub.address_prefix}"
		destination_address_prefix = "*"
	}

	security_rule	{
		name                       = "allow-db"
		priority                   = 1224
		direction                  = "Inbound"
		access                     = "Allow"
		protocol                   = "Tcp"
		source_port_range          = "*"
		destination_port_range     = "${var.db_port}"
		source_address_prefix      = "${azurerm_subnet.sn-dev-pub.address_prefix}"
		destination_address_prefix = "*"
	}
}

resource "azurerm_network_security_group" "devpub" {
	name = "nsg-devpub"
	location = "${var.location}"
	resource_group_name	= "${azurerm_resource_group.RG1.name}"

	security_rule {
		name                       = "allow-http"
		priority                   = 1124
		direction                  = "Inbound"
		access                     = "Allow"
		protocol                   = "Tcp"
		source_port_range          = "*"
		destination_port_range     = "80"
		source_address_prefix      = "*"
		destination_address_prefix = "*"
	}

	security_rule {
		name                       = "allow-https"
		priority                   = 1224
		direction                  = "Inbound"
		access                     = "Allow"
		protocol                   = "Tcp"
		source_port_range          = "*"
		destination_port_range     = "443"
		source_address_prefix      = "*"
		destination_address_prefix = "*"
	}

	security_rule {
		name                       = "allow-ssh"
		priority                   = 1324
		direction                  = "Inbound"
		access                     = "Allow"
		protocol                   = "Tcp"
		source_port_range          = "*"
		destination_port_range     = "22"
		source_address_prefix      = "*"
		destination_address_prefix = "*"
	}
}

resource "azurerm_network_security_group" "prodpriv" {
	name = "nsg-prodpriv"
	location = "${var.location}"
  resource_group_name   = "${azurerm_resource_group.RG1.name}"

  security_rule {
		name                       = "allow-ssh"
 		priority                   = 1124
 		direction                  = "Inbound"
 		access                     = "Allow"
 		protocol                   = "Tcp"
 		source_port_range          = "*"
 		destination_port_range     = "22"
 		source_address_prefix      = "${azurerm_subnet.sn-prod-pub.address_prefix}"
 		destination_address_prefix = "*"
  }

  security_rule   {
 		name                       = "allow-db"
		priority                   = 1224
		direction                  = "Inbound"
		access                     = "Allow"
		protocol                   = "Tcp"
		source_port_range          = "*"
		destination_port_range     = "${var.db_port}"
		source_address_prefix      = "${azurerm_subnet.sn-prod-pub.address_prefix}"
		destination_address_prefix = "*"
	}
}

resource "azurerm_network_security_group" "prodpub" {
  name = "nsg-prodpub"
  location = "${var.location}"
  resource_group_name = "${azurerm_resource_group.RG1.name}"

  security_rule {
    name                       = "allow-http"
    priority                   = 1124
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-https"
    priority                   = 1224
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-ssh"
    priority                   = 1324
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}
