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

variable "user_ids"{
  description = "the list of user ids of users that need read access policies created for things like key vault"
  type = list(string)
  default = [ ]
}