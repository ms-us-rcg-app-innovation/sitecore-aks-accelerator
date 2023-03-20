output "name" {
  value = azurerm_mssql_database.database.name
}

output "id" {
  value = azurerm_mssql_database.database.id
}

output "user_name" {
  value = mssql_login.database.login_name
}