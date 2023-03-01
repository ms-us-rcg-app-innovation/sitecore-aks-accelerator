locals {
  secrets_yaml = file("${path.module}/secrets.yml")
  secrets      = yamldecode(local.secrets_yaml)
}

module "password" {
  source = "./modules/key-vault-password"

  key_vault_id = azurerm_key_vault.default.id

  name = each.key

  depends_on = [
    azurerm_key_vault_access_policy.key_vault_user
  ]

  for_each = {
    for secret in local.secrets :
    secret.name => secret
    if secret.type == "password"
  }
}


module "certificate_authority" {
  source = "./modules/key-vault-certificate-authority"

  key_vault_id = azurerm_key_vault.default.id

  name         = each.key
  common_name  = each.value.options.common_name
  organization = each.value.options.organization

  depends_on = [
    azurerm_key_vault_access_policy.key_vault_user
  ]

  for_each = {
    for secret in local.secrets :
    secret.name => secret
    if secret.type == "certificate-authority"
  }
}


module "certificate" {
  source = "./modules/key-vault-certificate"

  name         = each.key
  common_name  = each.value.options.common_name
  organization = each.value.options.organization
  ca           = each.value.options.ca
  key_vault_id = azurerm_key_vault.default.id

  depends_on = [
    module.certificate_authority,
    azurerm_key_vault_access_policy.key_vault_user
  ]

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

  depends_on = [
    azurerm_key_vault_access_policy.key_vault_user
  ]

  for_each = {
    for secret in local.secrets :
    secret.name => secret
    if secret.type == "value"
  }
}