
resource "random_password" "password" {
  length = var.length
}

resource "azurerm_key_vault_secret" "password" {
  name         = var.name
  value        = random_password.password.result
  key_vault_id = var.key_vault_id
}