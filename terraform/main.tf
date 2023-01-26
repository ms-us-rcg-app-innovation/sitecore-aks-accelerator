terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.40.0"
    }
  }

  backend "azurerm" {
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

resource "random_password" "windows" {
  length = 16
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