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
      length(google_logging_project_sink.integration.exclusions) == 6 &&
      contains(
        [for exclusion in google_logging_project_sink.integration.exclusions : exclusion.filter if exclusion.name == "exclude-datadog-logs"],
        "protoPayload.authenticationInfo.principalEmail=\"mock-datadog@mock.iam.gserviceaccount.com\""
      )
    )
    error_message = "The sink must preserve the integration exclusion and configure the five narrowly scoped container-noise exclusions."
  }

  assert {
    condition = alltrue([
      for exclusion in google_logging_project_sink.integration.exclusions :
      strcontains(exclusion.filter, "resource.type=\"k8s_container\"") &&
      strcontains(
        exclusion.filter,
        exclusion.name == "exclude-authentik-proxy-duplicate-info" ? "resource.labels.namespace_name=\"authentik\"" : "resource.labels.namespace_name=\"kube-system\""
      ) &&
      strcontains(exclusion.filter, "severity=INFO") &&
      strcontains(exclusion.filter, "(LOG_ID(\"stdout\") OR LOG_ID(\"stderr\"))") &&
      strcontains(exclusion.filter, "NOT protoPayload:*") &&
      strcontains(exclusion.filter, "resource.labels.container_name=") &&
      (exclusion.name == "exclude-authentik-proxy-duplicate-info" || strcontains(exclusion.filter, "jsonPayload.message="))
      if exclusion.name != "exclude-datadog-logs"
    ])
    error_message = "Container-noise exclusions must be namespace/container scoped, preserve non-INFO logs and audits, and match messages unless removing a verified duplicate."
  }

  assert {
    condition = contains(
      [for exclusion in google_logging_project_sink.integration.exclusions : exclusion.filter if exclusion.name == "sample-konnectivity-connections"],
      "${local.logging_gke_success_filter} AND resource.labels.container_name=\"konnectivity-agent\" AND jsonPayload.message=~${jsonencode(local.logging_konnectivity_connection_pattern)} AND sample(insertId, 0.9)"
    )
    error_message = "Konnectivity connection chatter must retain a 10% sample rather than being completely excluded."
  }

  assert {
    condition = (
      alltrue([
        for message in [
          "\"Calling node registrar to check if it still responds\"",
          "\"Health check succeeded\"",
          "\"Attempting to open a gRPC connection\" socketfile=\"/registration/pd.csi.storage.gke.io-reg.sock\"",
          "\"Connecting\" address=\"unix:///registration/pd.csi.storage.gke.io-reg.sock\"",
          "\"GRPC call\" method=\"/pluginregistration.Registration/GetInfo\" request=\"{}\"",
          "\"Received GetInfo call\" request=\"\"",
          "\"GRPC response\" response=\"{\\\"name\\\":\\\"pd.csi.storage.gke.io\\\"}\" err=null"
        ] : can(regex(local.logging_csi_success_pattern, message))
      ]) &&
      alltrue([
        for message in [
          "\"GRPC response\" response=\"{}\" err=\"rpc error: unavailable\"",
          "\"GRPC response\" response=\"{}\" err=null retry failed",
          "\"GRPC call\" method=\"/pluginregistration.Registration/NotifyRegistrationStatus\" request=\"{}\"",
          "\"Health check failed\""
        ] : !can(regex(local.logging_csi_success_pattern, message))
      ])
    )
    error_message = "CSI filtering must match observed successful polling messages without matching failures or unrelated RPCs."
  }

  assert {
    condition = (
      can(regex(local.logging_konnectivity_connection_pattern, "\"Connect to server\" serverID=\"c4c44172-d22f-46e5-93d0-3c5862c019e7\"")) &&
      !can(regex(local.logging_konnectivity_connection_pattern, "\"Connect to server\" serverID=\"c4c44172-d22f-46e5-93d0-3c5862c019e7\" error=\"connection refused\"")) &&
      can(regex(local.logging_metadata_success_pattern, "[conn-id:123 rpc-id:456 remote-addr:10.0.0.104:54516 pod:pt-pneuma-istio-test/istio-test time-left:unlimited] \"/computeMetadata/v1/instance/attributes/cluster-name\" HTTP/200, started at 2026-11-07 14:02:00 +0000 UTC")) &&
      !can(regex(local.logging_metadata_success_pattern, "[conn-id:123] \"/computeMetadata/v1/instance/attributes/cluster-name\" HTTP/500, started at 2026-11-07 14:02:00 +0000 UTC")) &&
      !can(regex(local.logging_metadata_success_pattern, "[conn-id:123] \"/computeMetadata/v1/instance/service-accounts/default/token\" HTTP/200, started at 2026-11-07 14:02:00 +0000 UTC"))
    )
    error_message = "Only routine Konnectivity connections and successful cluster-name metadata polling may match; connection failures and identity-token activity must remain."
  }
}

variables {
  enable_cloud_cost_management = true
  project                      = "mock-project"
}
