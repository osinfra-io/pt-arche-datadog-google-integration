# Local Values
# https://opentofu.org/docs/language/values/locals

locals {
  cloud_cost_management_bucket_name = "datadog-cloud-cost-management-${random_id.this.hex}"
  cloud_cost_management_roles       = var.enable_cloud_cost_management ? toset(["roles/storage.legacyObjectReader", "roles/storage.legacyBucketWriter"]) : toset([])
  delegate_account_member           = "serviceAccount:${datadog_integration_gcp_sts.this.delegate_account_email}"
  logging_exclusion_filter          = "protoPayload.authenticationInfo.principalEmail=\"${google_service_account.integration.email}\""
  logging_gke_success_filter        = "resource.type=\"k8s_container\" AND resource.labels.namespace_name=\"kube-system\" AND severity=INFO AND (LOG_ID(\"stdout\") OR LOG_ID(\"stderr\")) AND NOT protoPayload:*"
  logging_gke_success_filters = {
    exclude-csi-successful-health-checks = "${local.logging_gke_success_filter} AND resource.labels.container_name=\"csi-driver-registrar\" AND jsonPayload.message=\"\\\"Health check succeeded\\\"\""
    exclude-filestore-lease-renewals     = "${local.logging_gke_success_filter} AND resource.labels.container_name=\"filestore-lock-release-controller\" AND jsonPayload.message=\"successfully renewed lease gke-managed-filestorecsi/filestore-csi-storage-gke-io-node\""
  }

  logging_sink_destination = "pubsub.googleapis.com/projects/${var.project}/topics/${google_pubsub_topic.integration.name}"

  # Push endpoint URL for Datadog log ingestion (contains sensitive api_key)
  pubsub_push_endpoint = "https://gcp-intake.logs.datadoghq.com/api/v2/logs?dd-api-key=${var.api_key}&dd-protocol=gcp"

  service_account_member = "serviceAccount:${google_service_account.integration.email}"
}
