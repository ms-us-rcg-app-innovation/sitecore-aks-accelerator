terraform {
  required_providers {
    pkcs12 = {
      source  = "chilicat/pkcs12"
      version = ">= 0.0.7"
    }
  }
}

resource "tls_private_key" "cert" {
  algorithm = "RSA"
}

resource "tls_cert_request" "cert" {
  private_key_pem = tls_private_key.cert.private_key_pem

  subject {
    common_name  = var.common_name
    organization = var.organization
  }
}


data "azurerm_key_vault_certificate_data" "ca" {
  name         = var.ca
  key_vault_id = var.key_vault_id
}

# when you create a certificate 
# a secret with the same name is created
data "azurerm_key_vault_secret" "ca" {
  name         = var.ca
  key_vault_id = var.key_vault_id
}


resource "tls_locally_signed_cert" "cert" {

  cert_request_pem = tls_cert_request.cert.cert_request_pem

  ca_private_key_pem = data.azurerm_key_vault_secret.ca.value
  ca_cert_pem        = data.azurerm_key_vault_certificate_data.ca.pem

  validity_period_hours = 17520

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
  ]
}

resource "pkcs12_from_pem" "cert" {
  cert_pem        = tls_locally_signed_cert.cert.cert_pem
  private_key_pem = tls_private_key.cert.private_key_pem
  password        = ""
}

resource "azurerm_key_vault_certificate" "cert" {
  name         = var.name
  key_vault_id = var.key_vault_id

  certificate {
    contents = pkcs12_from_pem.cert.result
  }
}