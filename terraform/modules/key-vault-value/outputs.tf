output "result" {
  value = azurerm_key_vault_secret.value.value
}

output "id" {
  value = azurerm_key_vault_secret.value.id
}

output "resource_id" {
  value = azurerm_key_vault_secret.value.resource_id
}

output "version" {
  value = azurerm_key_vault_secret.value.version
}