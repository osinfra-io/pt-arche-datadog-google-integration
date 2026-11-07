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

run "gke_success_export_policy" {
  command = apply

  variables {
    api_key                      = "mock"
    enable_cloud_cost_management = false
  }

  assert {
    condition = (
      length(google_logging_project_sink.integration.exclusions) == 3 &&
      contains(
        [for exclusion in google_logging_project_sink.integration.exclusions : exclusion.filter if exclusion.name == "exclude-datadog-logs"],
        "protoPayload.authenticationInfo.principalEmail=\"mock-datadog@mock.iam.gserviceaccount.com\""
      )
    )
    error_message = "The sink must preserve the existing integration exclusion and add only the two successful-controller exclusions."
  }

  assert {
    condition = alltrue([
      for exclusion in google_logging_project_sink.integration.exclusions :
      strcontains(exclusion.filter, "resource.type=\"k8s_container\"") &&
      strcontains(exclusion.filter, "resource.labels.namespace_name=\"kube-system\"") &&
      strcontains(exclusion.filter, "severity=INFO") &&
      strcontains(exclusion.filter, "(LOG_ID(\"stdout\") OR LOG_ID(\"stderr\"))") &&
      strcontains(exclusion.filter, "NOT protoPayload:*") &&
      strcontains(exclusion.filter, "resource.labels.container_name=") &&
      strcontains(exclusion.filter, "jsonPayload.message=")
      if exclusion.name != "exclude-datadog-logs"
    ])
    error_message = "Successful-controller exclusions must be container/message scoped, preserve non-INFO logs, and never suppress audit payloads."
  }
}

variables {
  enable_cloud_cost_management = true
  project                      = "mock-project"
}
