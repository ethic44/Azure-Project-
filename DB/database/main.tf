provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "azure_project" {
  name     = var.name
  location = var.location
}

resource "azurerm_mysql_server" "mysqlserver" {
  name                = var.server_name
  location            = var.location
  resource_group_name = var.name

  administrator_login          = var.primary_database_admin
  administrator_login_password = var.primary_database_password

  sku_name   = "GP_Gen5_2"
  storage_mb = 5120
  version    = "5.7"

  auto_grow_enabled                 = true
  backup_retention_days             = 7
  geo_redundant_backup_enabled      = true
  infrastructure_encryption_enabled = true
  public_network_access_enabled     = false
  ssl_enforcement_enabled           = true
  ssl_minimal_tls_version_enforced  = "TLS1_2"
}

resource "azurerm_mysql_database" "db" {
  name                = "db"
  resource_group_name = var.name
  server_name         = var.server_name
  charset             = "utf8"
  collation           = "utf8_unicode_ci"

  lifecycle {
    prevent_destroy = true
  }
}