# Input Variables
# https://opentofu.org/docs/language/values/variables

variable "enable_cloud_cost_management" {
  description = "Whether to enable cloud cost management features"
  type        = bool
}

variable "project" {
  description = "The GCP project ID"
  type        = string
}
