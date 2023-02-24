locals {
  secrets_yaml = file("${path.module}${var.secrets_file}")
  secrets      = yamldecode(local.secrets_yaml).secrets
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


module "certificate" {
  source = "./modules/key-vault-certificate"

  name         = each.key
  common_name  = each.value.options.common_name
  organization = each.value.options.organization
  ca           = each.value.options.ca
  key_vault_id = azurerm_key_vault.default.id

  depends_on = [
    module.certificate_authority
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

  for_each = {
    for secret in local.secrets :
    secret.name => secret
    if secret.type == "value"
  }
}

module "file" {
  source = "./modules/key-vault-value"

  key_vault_id = azurerm_key_vault.default.id

  name  = each.key
  value = file(each.value.options.path)

  for_each = {
    for secret in local.secrets :
    secret.name => secret
    if secret.type == "file"
  }
}