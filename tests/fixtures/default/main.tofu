# Required Providers
# https://opentofu.org/docs/language/providers/requirements

terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
    }

    datadog = {
      source = "datadog/datadog"
    }
  }
}

provider "datadog" {
  api_key = "mock"
  app_key = "mock"
}

# Datadog Google Integration
# https://github.com/osinfra-io/pt-arche-datadog-google-integration

module "test" {
  source = "../../../"

  api_key                      = "mock"
  enable_cloud_cost_management = var.enable_cloud_cost_management
  is_cspm_enabled              = true

  labels = {
    "mock-key" = "mock-value"
  }

  project = var.project
}
