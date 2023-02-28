# this random string is used to get a unique key vault name
# NOTE: terraform state is not saved so this will generate a unique account name each execution
resource "random_string" "keyvault" {
  length  = 5
  special = false
  upper   = false
}

# Create a Key Vault to hold the kubeconfig and sitecore license
resource "azurerm_key_vault" "default" {
  name                        = "${var.name}${random_string.keyvault.result}"
  location                    = azurerm_resource_group.default.location
  resource_group_name         = azurerm_resource_group.default.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"
}


locals {
  userids = distinct(sort(concat(var.user_ids, [data.azurerm_client_config.current.object_id])))
}


# key vault doesn't support using aad groups in policy enforcement
# they must be added individually
resource "azurerm_key_vault_access_policy" "key_vault_user" {
  for_each     = toset(local.userids)
  key_vault_id = azurerm_key_vault.default.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = each.key

  secret_permissions = [
    "Get",
    "List",
    "Set",
    "Delete",
    "Recover"
  ]

  certificate_permissions = [
    "Create",
    "Get",
    "Update",
    "List",
    "Delete"
  ]
}

resource "random_password" "windows" {
  length = 16
}

resource "random_password" "sql" {
  length = 16
}

