output "result" {
  value = random_password.password.result
}

output "id" {
  value = azurerm_key_vault_secret.password.id
}

output "resource_id" {
  value = azurerm_key_vault_secret.password.resource_id
}

output "version" {
  value = azurerm_key_vault_secret.password.version
}