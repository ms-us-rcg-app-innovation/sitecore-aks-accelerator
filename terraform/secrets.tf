locals {
  secrets_yaml = file("${path.module}/secrets.yml")
  secrets      = yamldecode(local.secrets_yaml)
}

module "password" {
  source = "./modules/key-vault-password"

  key_vault_id = azurerm_key_vault.default.id

  name = each.key


  for_each = {
    for secret in local.secrets :
    secret.name => secret
    if secret.type == "password"
  }
}

module "certificate" {
  source = "./modules/key-vault-certificate"

  name         = each.key
  common_name  = each.value.options.common_name
  organization = each.value.options.organization
  ca           = each.value.options.ca
  key_vault_id = azurerm_key_vault.default.id

  for_each = {
    for secret in local.secrets :
    secret.name => secret
    if secret.type == "certificate"
  }
}

module "value" {
  source = "./modules/key-vault-value"

  key_vault_id = azurerm_key_vault.default.id

  name  = each.key
  value = try(each.value.options.default, "")

  for_each = {
    for secret in local.secrets :
    secret.name => secret
    if secret.type == "value"
  }
}

module "certificate_authority" {
  source = "./modules/key-vault-certificate-authority"

  key_vault_id = azurerm_key_vault.default.id

  name         = each.key
  common_name  = each.value.options.common_name
  organization = each.value.options.organization

  for_each = {
    for secret in local.secrets :
    secret.name => secret
    if secret.type == "certificate-authority"
  }
}
