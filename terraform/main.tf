terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.40.0"
    }
  }

  backend "azurerm" {
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
    storage_account_name = "stasitecorelsxhg"
    resource_group_name  = "sitecore-tfstate"
  }
}

provider "azurerm" {
  # Configuration options
  features {

  }
}

resource "azurerm_resource_group" "default" {
  name     = var.name
  location = var.location
}

# The current client configuration for the az cli
# use az login to ensure you are connected to the correct subscription
data "azurerm_client_config" "current" {}

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

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Create",
      "Get",
    ]

    secret_permissions = [
      "Set",
      "Get",
      "Delete",
      "Purge",
      "Recover",
      "List"
    ]

    storage_permissions = [
      "Get",
    ]
  }
}

resource "random_password" "windows" {
  length = 16
}

resource "azurerm_key_vault_secret" "password" {
  name         = "windows-password"
  value        = random_password.windows.result
  key_vault_id = azurerm_key_vault.default.id
}

resource "azurerm_kubernetes_cluster" "default" {
  name                = "sitecore"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  dns_prefix          = "sitecore"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2_v2"
  }

  windows_profile {
    admin_password = azurerm_key_vault_secret.password.value
    admin_username = "${var.name}admin"
  }

  network_profile {
    network_plugin = "azure"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Production"
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "windows" {
  name                  = "win19"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.default.id
  vm_size               = "Standard_D2_v2"
  node_count            = 1
  os_type               = "Windows"
  os_sku                = "Windows2019"

  windows_profile {

  }
}

resource "azurerm_key_vault_secret" "kubeconfig" {
  name         = "kubeconfig"
  value        = azurerm_kubernetes_cluster.default.kube_config_raw
  key_vault_id = azurerm_key_vault.default.id
}

locals {
  // name: the name of the secret
  // type: one of ("value", "password", "certificate")
  secrets = [
    {
      name     = "sitecore-license",
      type     = "value",
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

resource "time_offset" "ca" {
  offset_years = 2
}

resource "tls_private_key" "ca" {
  algorithm = "RSA"
}

resource "tls_self_signed_cert" "ca" {
  private_key_pem = tls_private_key.ca.private_key_pem

  subject {
    common_name  = "globalhost"
    organization = "Sitecore Azure Accelerator"
  }

  validity_period_hours = time_offset.ca.hour
  allowed_uses = [
    "cert_signing",
    "key_encipherment",
    "digital_signature",
  ]
  is_ca_certificate = true
}

resource "time_offset" "cert" {
  offset_years = 2
}

resource "tls_private_key" "cert" {
  algorithm = "RSA"
}

resource "tls_cert_request" "cert" {
  private_key_pem = tls_private_key.cert.private_key_pem

  subject {
    common_name  = "example.com"
    organization = "ACME Examples, Inc"
  }
}

resource "tls_locally_signed_cert" "cert" {

  cert_request_pem = tls_cert_request.cert.cert_request_pem

  ca_private_key_pem = tls_private_key.ca.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.ca.cert_pem

  validity_period_hours = time_offset.cert.hour
  allowed_uses = [
    "key_encipherment",
    "digital_signature",
  ]
}