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

variable "user_ids" {
  description = "the list of user ids of users that need read access policies created for things like key vault"
  type        = list(string)
  default     = []
}

variable "secrets_file" {
  description = "Path to secrets yml file relative to path.module"
  type        = string
  default     = "/../kubernetes/sitecore_10_3/xm1/values.secrets.yaml"
}