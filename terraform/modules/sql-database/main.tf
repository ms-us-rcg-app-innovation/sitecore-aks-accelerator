terraform {
  required_providers {
    mssql = {
      source  = "betr-io/mssql" #"betr.io/betr/mssql"
      version = ">= 0.2.7"
    }
  }
}

resource "azurerm_mssql_database" "database" {
  name           = var.name
  server_id      = var.server_id
  collation      = "SQL_Latin1_General_CP1_CI_AS"
  license_type   = "LicenseIncluded"
  max_size_gb    = 10
  read_scale     = false
  sku_name       = "S1"
  zone_redundant = false
}

resource "mssql_login" "database" {
  server {
    host = var.server_fqdn
    login {
      username = var.admin_user_name
      password = var.admin_password
    }
  }

  login_name = var.user_name
  password   = var.password
}

# attempt to address race condition on creating login and then user 
# resulting in failed login for admin user when attempting to create user
resource "time_sleep" "wait_5_seconds" {
  depends_on = [mssql_login.database]

  create_duration = "5s"
}

resource "mssql_user" "database" {
  depends_on = [time_sleep.wait_5_seconds]

  server {
    host = var.server_fqdn
    login {
      username = var.admin_user_name
      password = var.admin_password
    }
  }

  database   = var.name
  username   = var.user_name
  login_name = var.user_name
  roles      = ["db_owner"]
}