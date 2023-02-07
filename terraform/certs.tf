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