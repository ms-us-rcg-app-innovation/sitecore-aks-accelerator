data "http" "wan_ip" {
  url = "https://ipv4.icanhazip.com"
}

resource "random_string" "sql" {
  length  = 5
  special = false
  upper   = false
}

locals {
  prefix          = module.value["sitecore-database-prefix"].result
  admin_user_name = module.value["sitecore-database-username"].result
  admin_password  = module.password["sitecore-database-password"].result
  wan_ip          = chomp(data.http.wan_ip.response_body)
  server_prefix   = "${var.name}${random_string.sql.result}"
  databases = [
    "Core",
    "Master",
    "Web",
    "ExperienceForms"
  ]
}

resource "azurerm_mssql_server" "default" {
  name                         = "${local.server_prefix}-sqlserver"
  resource_group_name          = azurerm_resource_group.default.name
  location                     = azurerm_resource_group.default.location
  version                      = "12.0"
  administrator_login          = local.admin_user_name
  administrator_login_password = local.admin_password
}

module "dbserver" {
  depends_on = [
    azurerm_key_vault_access_policy.terraform_user
  ]

  source = "./modules/key-vault-value"

  key_vault_id = azurerm_key_vault.default.id
  name         = "sitecore-database-server-name"
  value        = azurerm_mssql_server.default.fully_qualified_domain_name
}

resource "azurerm_mssql_firewall_rule" "localclient" {
  name             = "LocalClientAllowRule"
  server_id        = azurerm_mssql_server.default.id
  start_ip_address = local.wan_ip
  end_ip_address   = local.wan_ip
}

# ref - https://github.com/hashicorp/terraform-provider-azurerm/issues/14849
data "azurerm_public_ip" "cluster_outbound" {
  name                = split("/",tolist(azurerm_kubernetes_cluster.default.network_profile[0].load_balancer_profile[0].effective_outbound_ips)[0])[8]
  resource_group_name = split("/",tolist(azurerm_kubernetes_cluster.default.network_profile[0].load_balancer_profile[0].effective_outbound_ips)[0])[4]
}

resource "azurerm_mssql_firewall_rule" "cluster_access" {
  name             = "ClusterAccessAllowRule"
  server_id        = azurerm_mssql_server.default.id
  start_ip_address = data.azurerm_public_ip.cluster_outbound.ip_address
  end_ip_address   = data.azurerm_public_ip.cluster_outbound.ip_address
}

module "dbelasticpool" {
  depends_on = [
    azurerm_key_vault_access_policy.terraform_user
  ]
  
  source = "./modules/key-vault-value"

  key_vault_id = azurerm_key_vault.default.id
  name         = "sitecore-database-elastic-pool-name"
  value        = "" # supply if using elastic pool
}

resource "mssql_login" "database" {
  depends_on = [
    azurerm_mssql_firewall_rule.localclient
  ]

  for_each        = toset(local.databases)

  server {
    host = azurerm_mssql_server.default.fully_qualified_domain_name
    login {
      username = local.admin_user_name
      password = local.admin_password
    }
  }

  login_name = module.value["sitecore-${lower(each.key)}-database-username"].result
  password   = module.password["sitecore-${lower(each.key)}-database-password"].result
}