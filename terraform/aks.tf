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
    admin_password = azurerm_key_vault_secret.windowspassword.value
    admin_username = "${var.name}admin"
  }

  network_profile {
    network_plugin = "azure"
  }

  identity {
    type = "SystemAssigned"
  }

  key_vault_secrets_provider {
     secret_rotation_enabled = false
  }

  tags = {
    Environment = "Production"
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "windows" {
  name                  = "win19"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.default.id
  vm_size               = "Standard_D4_v2"
  node_count            = 1
  os_type               = "Windows"
  os_sku                = "Windows2019"

  windows_profile {

  }
}

resource "azurerm_key_vault_secret" "windowspassword" {
  depends_on = [
    azurerm_key_vault_access_policy.terraform_user
  ]

  name         = "windows-password"
  value        = random_password.windows.result
  key_vault_id = azurerm_key_vault.default.id
}

resource "azurerm_key_vault_secret" "kubeconfig" {
  depends_on = [
    azurerm_key_vault_access_policy.terraform_user
  ]

  name         = "kubeconfig"
  value        = azurerm_kubernetes_cluster.default.kube_config_raw
  key_vault_id = azurerm_key_vault.default.id
}

resource "azurerm_key_vault_access_policy" "aks_identity" {
  depends_on = [
    azurerm_key_vault_access_policy.terraform_user
  ]

  key_vault_id    = azurerm_key_vault.default.id
  tenant_id       = data.azurerm_client_config.current.tenant_id
  object_id       = azurerm_kubernetes_cluster.default.key_vault_secrets_provider[0].secret_identity[0].object_id 

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