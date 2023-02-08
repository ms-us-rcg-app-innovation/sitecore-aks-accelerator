output "pem" {
  value = tls_locally_signed_cert.cert.cert_pem
}

output "id" {
  value = azurerm_key_vault_certificate.cert.id
}