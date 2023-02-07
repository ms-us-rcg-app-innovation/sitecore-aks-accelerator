# the azure deployment location aka "region"
variable "location" {
  description = "Azure region to deploy"
  type        = string
}

# the common name used in all azure resources
variable "name" {
  description = "Common name used in all resources"
  type        = string
}