resource "azurerm_resource_group" "azure_project" {
  name     = var.name
  location = var.location
}

provider "azurerm" {
  features {}
}


resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  location            = var.location
  resource_group_name = var.name
  address_space       = ["10.0.0.0/16"]
}



resource "azurerm_subnet" "websub" {
  name                 = var.websubnetname
  resource_group_name  = var.name
  virtual_network_name = var.vnet_name
  address_prefixes     = [var.websubnetcidr]
}

resource "azurerm_network_interface" "webnetif" {
  name                = "webnetif"
  location            = var.location
  resource_group_name = var.name

  ip_configuration {
    name                          = "web-ip-config"
    subnet_id                     = azurerm_subnet.websub.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}

resource "azurerm_public_ip" "pip" {
  name                = "pip"
  resource_group_name = var.name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_linux_virtual_machine" "webserver" {
  name                = var.web_host_name
  resource_group_name = var.name
  location            = var.location
  size                = "Standard_B1ls"
  admin_username      = var.web_username
  network_interface_ids = [
    azurerm_network_interface.webnetif.id
  ]
 
  admin_ssh_key {
    username   = var.web_username
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "bansirllc1619470302579"
    offer     = "006-com-centos-9-stream"
    sku       = "id-product-plan-centos-idstream"
    version   = "latest"
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

resource "azurerm_subnet_network_security_group_association" "web-secg" {
  subnet_id                 = azurerm_subnet.websub.id
  network_security_group_id = azurerm_network_security_group.web-secg.id
}



resource "azurerm_subnet" "app-subnet" {
  name                 = "app-subnet"
  virtual_network_name = var.vnet_name
  resource_group_name  = var.name
  address_prefixes     = [var.appsubnetcidr]
}

resource "azurerm_network_interface" "appnetif" {
  name                = "appnetif"
  location            = var.location
  resource_group_name = var.name

  ip_configuration {
    name = "app-ip-config"
    subnet_id = azurerm_subnet.app-subnet.id
    private_ip_address_allocation = "Dyamic"
  }
}

resource "azurerm_linux_virtual_machine" "appserver" {
  name                = var.app_host_name
  resource_group_name = var.name
  location            = var.location
  size                = "Standard_B1ls"
  admin_username      = var.app_username
  network_interface_ids = [
    azurerm_network_interface.appnetif.id
  ]
 
  admin_ssh_key {
    username   = var.app_username
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "bansirllc1619470302579"
    offer     = "006-com-centos-9-stream"
    sku       = "id-product-plan-centos-idstream"
    version   = "latest"
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

resource "azurerm_subnet_network_security_group_association" "app-secg" {
  subnet_id                 = azurerm_subnet.app-subnet.id
  network_security_group_id = azurerm_network_security_group.app-secg.id
}



  resource "azurerm_linux_virtual_machine_scale_set" "vmss" {
  name                 = "vmss"
  computer_name_prefix = "vm"
  resource_group_name  = var.name
  location             = var.location
  sku                  = "Standard_B2ms"
  instances            = 1
  overprovision        = true
  zone_balance         = true
  zones                = [1, 2, 3]
  upgrade_mode         = "Automatic"
  admin_username       = var.web_host_name
  user_data            = base64encode(file("webserver.sh"))

  rolling_upgrade_policy {
    max_batch_instance_percent              = 50
    max_unhealthy_instance_percent          = 50
    max_unhealthy_upgraded_instance_percent = 0
    pause_time_between_batches              = "PT0S"
  }

  admin_ssh_key {
    username   = var.web_username
    public_key = file("~/.ssh/id_rsa.pub")
  }

  source_image_reference {
    publisher = "bansirllc1619470302579"
    offer     = "006-com-centos-9-stream"
    sku       = "id-product-plan-centos-idstream"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name    = azurerm_network_interface.webnetif.name
    primary = true

    ip_configuration {
      name                                   = "internal"
      primary                                = true
      subnet_id                              = var.websubnetcidr
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.lb.id]
    }
  }
}

resource "azurerm_lb" "lb" {
  name                = "loadbalancer"
  location            = var.location
  resource_group_name = var.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = azurerm_public_ip.pip.name
    public_ip_address_id = azurerm_public_ip.pip.id
  }
}

resource "azurerm_lb_backend_address_pool" "lb" {
  loadbalancer_id = azurerm_lb.lb.id
  name            = "backendpool"
}

resource "azurerm_traffic_manager_profile" "traffic_manager" {
  name                   = random_id.server.hex
  resource_group_name    = var.name
  traffic_routing_method = "Weighted"

  dns_config {
    relative_name = random_id.server.hex
    ttl           = 100
  }

  monitor_config {
    protocol                     = "HTTP"
    port                         = 80
    path                         = "/"
    interval_in_seconds          = 30
    timeout_in_seconds           = 9
    tolerated_number_of_failures = 3
  }

  }

  resource "random_id" "server" {
  keepers = {
    azi_id = 1
  }

  byte_length = 8
}