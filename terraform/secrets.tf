locals {
  secrets_yaml         = file("${path.module}${var.secrets_file}")
  secrets_yaml_decoded = yamldecode(local.secrets_yaml)
}

module "value" {
  depends_on = [
    azurerm_key_vault_access_policy.terraform_user,
    azurerm_key_vault_access_policy.key_vault_user
  ]

  source = "./modules/key-vault-value"

  key_vault_id = azurerm_key_vault.default.id
  name         = each.key
  value        = try(each.value.options.default, "")

  for_each = {
    for secret in local.secrets_yaml_decoded.secrets :
    secret.name => secret
    if secret.type == "value"
  }
}

module "file" {
  depends_on = [
    azurerm_key_vault_access_policy.terraform_user,
    azurerm_key_vault_access_policy.key_vault_user
  ]

  source = "./modules/key-vault-value"

  key_vault_id = azurerm_key_vault.default.id
  name         = each.key
  value        = file(each.value.options.path)

  for_each = {
    for secret in local.secrets_yaml_decoded.secrets :
    secret.name => secret
    if secret.type == "file"
  }
}

module "password" {
  depends_on = [
    azurerm_key_vault_access_policy.terraform_user,
    azurerm_key_vault_access_policy.key_vault_user
  ]

  source = "./modules/key-vault-password"

  key_vault_id = azurerm_key_vault.default.id
  name         = each.key

  for_each = {
    for secret in local.secrets_yaml_decoded.secrets :
    secret.name => secret
    if secret.type == "password"
  }
}

module "certificate_authority" {
  depends_on = [
    azurerm_key_vault_access_policy.terraform_user,
    azurerm_key_vault_access_policy.key_vault_user
  ]

  source = "./modules/key-vault-certificate-authority"

  key_vault_id = azurerm_key_vault.default.id
  name         = each.key
  common_name  = each.value.options.common_name
  organization = each.value.options.organization

  for_each = {
    for secret in local.secrets_yaml_decoded.certificate_authorities :
    secret.name => secret
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
    azurerm_key_vault_access_policy.terraform_user,
    azurerm_key_vault_access_policy.key_vault_user
  ]

  for_each = {
    for secret in local.secrets_yaml_decoded.certificates :
    secret.name => secret
  }
}