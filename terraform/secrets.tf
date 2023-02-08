locals {
  // name: the name of the secret
  // type: one of ("value", "password", "certificate")
  secrets = [
    {
      name     = "sitecore-license",
      type     = "license", // changed from "value" since license needs to be a specific/static value
      topology = ["XM1", "XP1"]
    },
    {
      name     = "sitecore-admin-password",
      type     = "password",
      topology = ["XM1", "XP1"]
    },
    {
      name     = "sitecore-telerik-encryption-key",
      type     = "value",
      topology = ["XM1", "XP1"]
    },
    {
      name     = "sitecore-identity-certificate",
      type     = "certificate",
      topology = ["XM1", "XP1"]
    },
    {
      name     = "sitecore-identity-certificate-password",
      type     = "password",
      topology = ["XM1", "XP1"]
    },
    {
      name     = "sitecore-identity-secret",
      type     = "password",
      topology = ["XM1", "XP1"]
    },
    {
      name     = "sitecore-reporting-api-key",
      type     = "password",
      topology = ["XP1"]
    },
    {
      name     = "sitecore-solr-connection-string",
      type     = "value",
      topology = ["XM1", "XP1"]
    },
    {
      name     = "sitecore-solr-connection-string-xdb",
      type     = "value",
      topology = ["XP1"]
    },
    {
      name     = "sitecore-database-username",
      type     = "value",
      topology = ["XM1", "XP1"]
    },
    {
      name     = "sitecore-database-server-name",
      type     = "value",
      topology = ["XM1", "XP1"]
    },
    {
      name     = "sitecore-database-password",
      type     = "password",
      topology = ["XM1", "XP1"]
    },
    {
      name     = "sitecore-database-elastic-pool-name",
      type     = "value",
      topology = ["XM1", "XP1"]
    },
    {
      name     = "sitecore-core-database-username",
      type     = "value",
      topology = ["XM1", "XP1"]
    },
    {
      name     = "sitecore-core-database-password",
      type     = "password",
      topology = ["XM1", "XP1"]
    },
    {
      name     = "sitecore-master-database-username",
      type     = "value",
      topology = ["XM1", "XP1"]
    },
    {
      name     = "sitecore-master-database-password",
      type     = "password",
      topology = ["XM1", "XP1"]
    },
    {
      name     = "sitecore-web-database-username",
      type     = "value",
      topology = ["XM1", "XP1"]
    },
    {
      name     = "sitecore-web-database-password",
      type     = "password",
      topology = ["XM1", "XP1"]
    },
    {
      name     = "sitecore-forms-database-username",
      type     = "value",
      topology = ["XM1", "XP1"]
    },
    {
      name     = "sitecore-forms-database-password",
      type     = "password",
      topology = ["XM1", "XP1"]
    },
    {
      name     = "sitecore-exm-master-database-username",
      type     = "value",
      topology = ["XP1"]
    },
    {
      name     = "sitecore-exm-master-database-password",
      type     = "password",
      topology = ["XP1"]
    },
    {
      name     = "sitecore-messaging-database-username",
      type     = "value",
      topology = ["XP1"]
    },
    {
      name     = "sitecore-messaging-database-password",
      type     = "password",
      topology = ["XP1"]
    },
    {
      name     = "sitecore-marketing-automation-username",
      type     = "value",
      topology = ["XP1"]
    },
    {
      name     = "sitecore-marketing-automation-password",
      type     = "password",
      topology = ["XP1"]
    },
    {
      name     = "sitecore-processing-engine-storage-database-username",
      type     = "value",
      topology = ["XP1"]
    },
    {
      name     = "sitecore-processing-engine-storage-database-password",
      type     = "password",
      topology = ["XP1"]
    },
    {
      name     = "sitecore-processing-engine-tasks-database-password",
      type     = "password",
      topology = ["XP1"]
    },
    {
      name     = "sitecore-processing-engine-tasks-database-username",
      type     = "value",
      topology = ["XP1"]
    },
    {
      name     = "sitecore-processing-pools-database-password",
      type     = "password",
      topology = ["XP1"]
    },
    {
      name     = "sitecore-processing-pools-database-username",
      type     = "value",
      topology = ["XP1"]
    },
    {
      name     = "sitecore-processing-tasks-database-password",
      type     = "password",
      topology = ["XP1"]
    },
    {
      name     = "sitecore-processing-tasks-database-username",
      type     = "value",
      topology = ["XP1"]
    },
    {
      name     = "sitecore-reference-data-database-password",
      type     = "password",
      topology = ["XP1"]
    },
    {
      name     = "sitecore-reference-data-database-username",
      type     = "value",
      topology = ["XP1"]
    },
    {
      name     = "sitecore-reporting-database-password",
      type     = "password",
      topology = ["XP1"]
    },
    {
      name     = "sitecore-reporting-database-username",
      type     = "value",
      topology = ["XP1"]
    },
    {
      name     = "sitecore-collection-shardmapmanager-database-username",
      type     = "value",
      topology = ["XP1"]
    },
    {
      name     = "sitecore-collection-shardmapmanager-database-password",
      type     = "password",
      topology = ["XP1"]
    }
  ]
}

resource "random_password" "secrets" {
  for_each = {
    for secret in local.secrets:
    secret.name => secret
    if secret.type == "password"
  }
  length = 16
}

resource "azurerm_key_vault_secret" "secrets_passwords" {
  for_each = {
    for secret in local.secrets:
    secret.name => secret
    if secret.type == "password"
  }
  name         = each.value.name
  value        = random_password.secrets[each.value.name].result
  key_vault_id = azurerm_key_vault.default.id
}