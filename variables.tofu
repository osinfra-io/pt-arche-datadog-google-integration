# Input Variables
# https://opentofu.org/docs/language/values/variables

variable "api_key" {
  description = "Datadog API key"
  type        = string
  sensitive   = true
}

variable "cloud_cost_management_location" {
  description = "The location for the cloud cost management bucket and Bigquery dataset, only used if enable_cloud_cost_management is true"
  type        = string
  default     = "US"
}

variable "enable_cloud_cost_management" {
  description = "Whether Datadog collects cloud cost management data from your GCP project, this should only be set to true in a single project"
  type        = bool
  default     = false
}

variable "host_filters" {
  description = "A list of host filters to apply to the Datadog GCP integration"
  type        = list(string)
  default     = []
}

variable "is_cspm_enabled" {
  description = "Whether Datadog collects cloud security posture management resources from your GCP project"
  type        = bool
  default     = true
}

variable "is_resource_change_collection_enabled" {
  description = "When enabled, Datadog scans for all resource change data in your Google Cloud environment"
  type        = bool
  default     = true
}

variable "is_security_command_center_enabled" {
  description = "When enabled, Datadog will attempt to collect Security Command Center Findings. Note: This requires additional permissions on the service account"
  type        = bool
  default     = true
}

variable "labels" {
  description = "A map of key/value pairs to assign to the resources being created"
  type        = map(string)
  default = {
    system = "datadog"
  }
}

variable "project" {
  description = "The ID of the project in which the resource belongs"
  type        = string
}

variable "resource_collection_enabled" {
  description = "When enabled, Datadog scans for all resources in your GCP environment"
  type        = bool
  default     = true
}
