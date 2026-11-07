# Local Values
# https://opentofu.org/docs/language/values/locals

locals {
  cloud_cost_management_bucket_name = "datadog-cloud-cost-management-${random_id.this.hex}"
  cloud_cost_management_roles       = var.enable_cloud_cost_management ? toset(["roles/storage.legacyObjectReader", "roles/storage.legacyBucketWriter"]) : toset([])
  delegate_account_member           = "serviceAccount:${datadog_integration_gcp_sts.this.delegate_account_email}"
  logging_container_success_filter  = "resource.type=\"k8s_container\" AND severity=INFO AND (LOG_ID(\"stdout\") OR LOG_ID(\"stderr\")) AND NOT protoPayload:*"
  logging_csi_success_pattern = join("|", [
    "^\"Calling node registrar to check if it still responds\"$",
    "^\"Health check succeeded\"$",
    "^\"Attempting to open a gRPC connection\" socketfile=\"/registration/pd.csi.storage.gke.io-reg.sock\"$",
    "^\"Connecting\" address=\"unix:///registration/pd.csi.storage.gke.io-reg.sock\"$",
    "^\"GRPC call\" method=\"/pluginregistration.Registration/GetInfo\" request=\"\\{\\}\"$",
    "^\"Received GetInfo call\" request=\"\"$",
    "^\"GRPC response\" response=\".*\" err=null$"
  ])

  logging_exclusion_filter   = "protoPayload.authenticationInfo.principalEmail=\"${google_service_account.integration.email}\""
  logging_gke_success_filter = "${local.logging_container_success_filter} AND resource.labels.namespace_name=\"kube-system\""
  logging_gke_success_filters = {
    exclude-authentik-proxy-duplicate-info = "${local.logging_container_success_filter} AND resource.labels.namespace_name=\"authentik\" AND resource.labels.container_name=\"cloud-sql-proxy\""
    exclude-csi-successful-health-checks   = "${local.logging_gke_success_filter} AND resource.labels.container_name=\"csi-driver-registrar\" AND jsonPayload.message=~${jsonencode(local.logging_csi_success_pattern)}"
    exclude-filestore-lease-renewals       = "${local.logging_gke_success_filter} AND resource.labels.container_name=\"filestore-lock-release-controller\" AND jsonPayload.message=\"successfully renewed lease gke-managed-filestorecsi/filestore-csi-storage-gke-io-node\""
    exclude-gke-metadata-cluster-name      = "${local.logging_gke_success_filter} AND resource.labels.container_name=\"gke-metadata-server\" AND jsonPayload.message=~${jsonencode(local.logging_metadata_success_pattern)}"
    sample-konnectivity-connections        = "${local.logging_gke_success_filter} AND resource.labels.container_name=\"konnectivity-agent\" AND jsonPayload.message=~${jsonencode(local.logging_konnectivity_connection_pattern)} AND sample(insertId, 0.9)"
  }

  logging_konnectivity_connection_pattern = "^\"Connect to server\" serverID=\"[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\"$"
  logging_metadata_success_pattern        = "^\\[.*\\] \"/computeMetadata/v1/instance/attributes/cluster-name\" HTTP/200, started at .*$"
  logging_sink_destination                = "pubsub.googleapis.com/projects/${var.project}/topics/${google_pubsub_topic.integration.name}"

  # Push endpoint URL for Datadog log ingestion (contains sensitive api_key)
  pubsub_push_endpoint = "https://gcp-intake.logs.datadoghq.com/api/v2/logs?dd-api-key=${var.api_key}&dd-protocol=gcp"

  service_account_member = "serviceAccount:${google_service_account.integration.email}"
}
