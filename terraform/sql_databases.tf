data "http" "wan_ip" {
  url = "https://ipv4.icanhazip.com"
}

locals {
  prefix = module.value["sitecore-database-prefix"].result
  admin_user_name = module.value["sitecore-database-username"].result
  admin_password = module.password["sitecore-database-password"].result
  wan_ip = chomp(data.http.wan_ip.response_body)
  databases = [
    "Core",
    "Master",
    "Web",
    "Forms"
  ]
}

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
  administrator_login          = local.admin_user_name
  administrator_login_password = local.admin_password
}

resource "azurerm_mssql_firewall_rule" "localclient" {
  name             = "LocalClientAllowRule"
  server_id        = azurerm_mssql_server.default.id
  start_ip_address = local.wan_ip
  end_ip_address   = local.wan_ip
}

module "database" {
  source = "./modules/sql-database"

  for_each        = toset(local.databases)
  name            = "${local.prefix}.${each.key}"
  server_id       = azurerm_mssql_server.default.id
  server_fqdn     = azurerm_mssql_server.default.fully_qualified_domain_name
  user_name       = module.value["sitecore-${lower(each.key)}-database-username"].result
  password        = module.password["sitecore-${lower(each.key)}-database-password"].result
  admin_user_name = local.admin_user_name
  admin_password  = local.admin_password
}