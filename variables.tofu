# Input Variables
# https://opentofu.org/docs/language/values/variables

variable "api_key" {
  description = "Datadog API key"
  sensitive   = true
  type        = string
}

variable "cloud_cost_management_location" {
  default     = "US"
  description = "The location for the cloud cost management bucket and Bigquery dataset, only used if enable_cloud_cost_management is true"
  type        = string
}

variable "enable_cloud_cost_management" {
  default     = false
  description = "Whether Datadog collects cloud cost management data from your GCP project, this should only be set to true in a single project"
  type        = bool
}

variable "is_cspm_enabled" {
  default     = true
  description = "Whether Datadog collects cloud security posture management resources from your GCP project"
  type        = bool
}

variable "is_resource_change_collection_enabled" {
  default     = true
  description = "When enabled, Datadog scans for all resource change data in your Google Cloud environment"
  type        = bool
}

variable "is_security_command_center_enabled" {
  default     = true
  description = "When enabled, Datadog will attempt to collect Security Command Center Findings. Note: This requires additional permissions on the service account"
  type        = bool
}

variable "labels" {
  default = {
    system = "datadog"
  }

  description = "A map of key/value pairs to assign to the resources being created"
  type        = map(string)
}

variable "project" {
  description = "The ID of the project in which the resource belongs"
  type        = string
}

variable "resource_collection_enabled" {
  default     = true
  description = "When enabled, Datadog scans for all resources in your GCP environment"
  type        = bool
}
