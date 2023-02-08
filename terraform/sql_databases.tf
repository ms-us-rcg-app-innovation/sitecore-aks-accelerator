resource "random_string" "sql" {
  length  = 5
  special = false
  upper   = false
}

resource "azurerm_mssql_server" "default" {
  name                         = "${var.name}${random_string.sql.result}-sqlserver"
  resource_group_name          = azurerm_resource_group.default.name
  location                     = azurerm_resource_group.default.location
  version                      = "12.0"
  administrator_login          = "${var.name}-admin"
  administrator_login_password = module.password["sitecore-database-password"].result
}

resource "azurerm_mssql_database" "default" {
  name           = "${var.name}-db"
  server_id      = azurerm_mssql_server.default.id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  license_type   = "LicenseIncluded"
  max_size_gb    = 10
  read_scale     = false
  sku_name       = "S1"
  zone_redundant = false
}