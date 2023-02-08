locals{
  secrets_yaml = file("${path.module}/secrets.yml")
  secrets = yamldecode(secrets_yaml)
}

module "password" {
  source = "./modules/key-vault-password"
  for_each = {
    for secret in local.secrets :
    secret.name => secret
    if secret.type == "password"
  }
}

module "certificate" {  
  source = "./modules/key-vault-certificate"

  name = each.key
  common_name = each.value.options.common_name
  organization = each.value.options.organization
  key_vault_id = azurerm_key_vault.default.id

  for_each = {
    for secret in local.secrets :
    secret.name => secret
    if secret.type == "certificate"
  }
}

module "value" {
  source = "./modules/key-vault-value"

  name = each.key
  common_name = each.value.options.common_name
  organization = each.value.options.organization
  key_vault_id = azurerm_key_vault.default.id


  for_each = {
    for secret in local.secrets :
    secret.name => secret
    if secret.type == "value"
  }
}

module "certificate_authority"{
  source = "./modules/key-vault-certificate-authority"



  for_each = {
    for secret in local.secrets :
    secret.name => secret
    if secret.type == "certificate-authority"
  }
}
