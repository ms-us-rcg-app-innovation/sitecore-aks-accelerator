# the azure deployment location aka "region"
variable "location" {
  description = "the azure region to deploy"
  type        = string
}

# the common name used in all azure resources
variable "name" {
  description = "the common name used in all resources"
  type        = string
}