# Test
# https://opentofu.org/docs/cli/commands/test

# Mock Providers
# https://opentofu.org/docs/cli/commands/test/#the-mock_provider-blocks

mock_provider "datadog" {}
mock_provider "google" {
  mock_resource "google_service_account" {
    defaults = {
      name  = "projects/mock/serviceAccounts/mock-datadog@mock.iam.gserviceaccount.com"
      email = "mock-datadog@mock.iam.gserviceaccount.com"
    }
  }
  mock_resource "google_logging_project_sink" {
    defaults = {
      writer_identity = "serviceAccount:mock-datadog@mock.iam.gserviceaccount.com"
    }
  }
}

run "default" {
  command = apply

  module {
    source = "./tests/fixtures/default"
  }
}

variables {
  enable_cloud_cost_management = true
  project                      = "mock-project"
}
