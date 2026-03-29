# Local Values
# https://opentofu.org/docs/language/values/locals

locals {
  cloud_cost_management_bucket_name = "datadog-cloud-cost-management-${random_id.this.hex}"
  cloud_cost_management_roles       = var.enable_cloud_cost_management ? toset(["roles/storage.legacyObjectReader", "roles/storage.legacyBucketWriter"]) : toset([])
  delegate_account_member           = "serviceAccount:${datadog_integration_gcp_sts.this.delegate_account_email}"
  logging_exclusion_filter          = "protoPayload.authenticationInfo.principalEmail=\"${google_service_account.integration.email}\""
  logging_sink_destination          = "pubsub.googleapis.com/projects/${var.project}/topics/${google_pubsub_topic.integration.name}"

  # Push endpoint URL for Datadog log ingestion (contains sensitive api_key)
  pubsub_push_endpoint = "https://gcp-intake.logs.datadoghq.com/api/v2/logs?dd-api-key=${var.api_key}&dd-protocol=gcp"

  service_account_member = "serviceAccount:${google_service_account.integration.email}"
}
