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

variable "secrets_file" {
  description = "Path to secrets yml file relative to path.module"
  type        = string
  default     = "/../kubernetes/sitecore_10_3/xm1/values.secrets.yml"
}