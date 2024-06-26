provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "azure-task" {
  name     =    var.name
  location =    var.location
}

resource "azurerm_network_security_group" "vnet-secg" {
  name                = "vnet-secg"
  location            = var.location
  resource_group_name = var.name
 security_rule {
    name                       = "vnet-secg"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_security_group" "app-secg" {
  name                = "app-secg"
  location            = var.location
  resource_group_name = var.name

  security_rule {
    name                       = "SSH"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "22"
    destination_port_range     = "22"
    source_address_prefix      = "0.0.0.0/0"
    destination_address_prefix = "0.0.0.0/0"
  }
}

resource "azurerm_network_security_group" "web-secg" {
  name                = "web-secg"
  location            = var.location
  resource_group_name = var.name

  security_rule {
    name                       = "HTTP"
    priority                   = 102
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "80"
    destination_port_range     = "80"
    source_address_prefix      = "0.0.0.0/0"
    destination_address_prefix = "0.0.0.0/0"
  }

   security_rule {
    name                       = "HTTPS"
    priority                   = 103
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "443"
    destination_port_range     = "443"
    source_address_prefix      = "0.0.0.0/0"
    destination_address_prefix = "0.0.0.0/0"
  }
}

resource "azurerm_network_security_group" "db-secg" {
  name                = "db-secg"
  location            = var.location
  resource_group_name = var.name

  security_rule {
    name                       = "MYSQL"
    priority                   = 104
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "3306"
    destination_port_range     = "3306"
    source_address_prefix      = "0.0.0.0/0"
    destination_address_prefix = "0.0.0.0/0"
  }
}