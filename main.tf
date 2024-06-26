provider "azurerm" {
  features {}
}

module "resourcegroup" {
  source   = "/modules/resourcegroup"
  name     = var.name
  location = var.location
}

module "networking" {
  source         = "/modules/networking"
  location       = var.name
  resource_group = var.name
  vnetcidr       = ["10.0.0.0/16"]
  websubnetcidr  = var.websubnetcidr
  appsubnetcidr  = var.appsubnetcidr
  dbsubnetcidr   = var.dbsubnetcidr
}

module "securitygroup" {
  source         = "/modules/securitygroup"
  location       = var.location
  resource_group = var.name
  web_subnet_id  = module.networking.websubnet_id
  app_subnet_id  = module.networking.appsubnet_id
  db_subnet_id   = module.networking.dbsubnet_id
}

module "compute" {
  source          = "/modules/compute"
  location        = var.location
  resource_group  = var.name
  web_subnet_id   = module.networking.websubnet_id
  app_subnet_id   = module.networking.appsubnet_id
  web_host_name   = var.web_host_name
  web_username    = var.web_username
  web_os_password = var.web_os_password
  app_host_name   = var.app_host_name
  app_username    = var.app_username
  app_os_password = var.app_os_password
}

module "database" {
  source                    = "/modules/database"
  location                  = var.location
  resource_group            = var.name
  primary_database          = var.primary_database
  primary_database_version  = var.primary_database_version
  primary_database_admin    = var.primary_database_admin
  primary_database_password = var.primary_database_password
}

module "keyvault" {
  source                    = "/modules/keyvault"
  location                  = var.location
  resource_group            = var.name
}