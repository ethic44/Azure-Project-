provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "azure_project" {
  name     = var.name
  location = var.location
}

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet"
  location            = var.location
  resource_group_name = var.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "web-subnet" {
  name                 = "web-subnet"
  virtual_network_name = var.virtual_network_name
  resource_group_name  = var.name
  address_prefixes     = [var.websubnetcidr]
}

resource "azurerm_subnet" "app-subnet" {
  name                 = "app-subnet"
  virtual_network_name = var.virtual_network_name
  resource_group_name  = var.name
  address_prefixes     = [var.appsubnetcidr]
}

resource "azurerm_subnet" "db-subnet" {
  name                 = "db-subnet"
  virtual_network_name = var.virtual_network_name
  resource_group_name  = var.name
  address_prefixes     = [var.dbsubnetcidr]
}

resource "azurerm_network_security_group" "vnet-secg" {
  name                = "vnet-secg"
  location            = var.location
  resource_group_name = var.name
   security_rule {
    name                       = "vnet-rule"
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