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