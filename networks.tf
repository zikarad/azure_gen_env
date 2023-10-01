resource "azurerm_resource_group" "rg-net" {
  name     = join("-", [var.stage.short, var.location.short, "net"])
  location = var.location.long

  tags = local.tags
}


/* VNET */

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-${var.stage.long}"
  address_space       = ["10.0.0.0/16"]
  location            = var.location.long
  resource_group_name = azurerm_resource_group.rg-net.name
}


/* SUBNETS */

resource "azurerm_subnet" "subnets" {
  for_each = var.subnets_map
  name                 = join("-", [var.stage.long, each.value.name])
  resource_group_name  = azurerm_resource_group.rg-net.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = each.value.cidr_block
  service_endpoints    = ["Microsoft.KeyVault"]
}


/* PROXIMITY */

resource "azurerm_proximity_placement_group" "webdb" {
  name                = join("-", [var.stage.short, "pxg", "webdb"])
  location            = azurerm_resource_group.rg-net.location
  resource_group_name = azurerm_resource_group.proj-rg.name

  tags = local.tags
}

/* NETWORK SECURITY GROUPS */

resource "azurerm_network_security_group" "nsg-jh" {
  name                = join("-", [var.stage.long, "jh"])
  location            = var.location.long
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
  name                = join("-", [var.stage.long, "dbms"])
  location            = var.location.long
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
  name                = join("-", [var.stage.long, "web"])
  location            = var.location.long
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
