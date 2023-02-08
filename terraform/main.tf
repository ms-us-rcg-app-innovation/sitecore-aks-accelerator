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
data "azurerm_client_config" "current" {}
