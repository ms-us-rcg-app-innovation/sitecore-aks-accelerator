terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.40.0"
    }
    pkcs12 = {
      source = "chilicat/pkcs12"
      version = "0.0.7"
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
<<<<<<< Updated upstream
data "azurerm_client_config" "current" {}
=======
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
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  enabled_for_disk_encryption = true

  sku_name = "standard"
}

data "azuread_group" "key_valult_users" {
  display_name     = "sitecore-aks-accelerator-keyvault-reader"
  security_enabled = true
}

locals {
  userids = concat(data.azuread_group.key_valult_users.members, data.azuread_group.key_valult_users.owners)
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

module "windows_password" {
  source       = "./modules/key-vault-password"
  length       = 16
  name         = "windows-password"
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
    admin_password = module.windows_password.result
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
>>>>>>> Stashed changes
