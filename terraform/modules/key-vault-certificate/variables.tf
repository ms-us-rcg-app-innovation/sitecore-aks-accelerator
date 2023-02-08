variable "name" {
  type = string
}

variable "common_name" {
  type = string
}

variable "organization" {
  type = string
}

variable "key_vault_id" {
  type = string
}

# the key vault secret id of the certificate authority
variable "ca" {
  type = string
}

variable "validity_period_hours" {
  type    = number
  default = 17520
}