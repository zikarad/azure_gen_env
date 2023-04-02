resource "azurerm_resource_group" "rg-net" {
  name     = join("-", [var.stage_sh, var.location_sh, "net"])
  location = var.location

  tags = local.tags
}


/* VNET */

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-${var.stage}"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.rg-net.name
}


/* SUBNETS */

resource "azurerm_subnet" "sn-pub" {
  name                 = join("-", [var.stage, "public"])
  resource_group_name  = azurerm_resource_group.rg-net.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
  service_endpoints    = ["Microsoft.KeyVault"]
}


resource "azurerm_subnet" "sn-priv" {
  name                 = join("-", [var.stage, "private"])
  resource_group_name  = azurerm_resource_group.rg-net.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
  service_endpoints    = ["Microsoft.KeyVault"]
}


/* NETWORK SECURITY GROUPS */

resource "azurerm_network_security_group" "nsg-jh" {
  name                = join("-", [var.stage, "jh"])
  location            = var.location
  resource_group_name = azurerm_resource_group.rg-net.name

  security_rule {
    name                       = "allow-ssh"
    priority                   = 1124
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.my_ip
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_security_group" "nsg-priv" {
  name                = join("-", [var.stage, "dbms"])
  location            = var.location
  resource_group_name = azurerm_resource_group.rg-net.name

  security_rule {
    name                       = "allow-db"
    priority                   = 1224
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = var.db_port
    source_address_prefix      = var.my_ip
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_security_group" "nsg-pub" {
  name                = join("-", [var.stage, "web"])
  location            = var.location
  resource_group_name = azurerm_resource_group.rg-net.name

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
    source_address_prefix      = var.my_ip
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "deny-ssh"
    priority                   = 1344
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}
