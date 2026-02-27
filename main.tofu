# Datadog Provider
# https://search.opentofu.org/provider/DataDog/datadog/latest/docs

terraform {
  required_providers {
    datadog = {
      source = "datadog/datadog"
    }
  }
}

# Datadog Integration Google Resource
# https://search.opentofu.org/provider/DataDog/datadog/latest/docs/resources/integration_gcp_sts

resource "datadog_integration_gcp_sts" "this" {
  client_email                          = google_service_account.integration.email
  host_filters                          = var.host_filters
  is_cspm_enabled                       = var.is_cspm_enabled
  is_resource_change_collection_enabled = var.is_resource_change_collection_enabled
  is_security_command_center_enabled    = var.is_security_command_center_enabled
  resource_collection_enabled           = var.resource_collection_enabled
}

# Google BigQuery Dataset Resource
# https://search.opentofu.org/provider/hashicorp/google/latest/docs/resources/bigquery_dataset

resource "google_bigquery_dataset" "billing_export" {
  lifecycle {
    enabled = var.enable_cloud_cost_management
  }

  dataset_id    = "billing_export"
  description   = "Cloud Billing data to export to BigQuery"
  friendly_name = "Billing Export"
  labels        = var.labels
  location      = var.cloud_cost_management_location

  project = var.project
}

# Google BigQuery Dataset IAM Member Resource
# https://search.opentofu.org/provider/hashicorp/google/latest/docs/resources/bigquery_dataset_iam_member

resource "google_bigquery_dataset_iam_member" "billing_export" {
  lifecycle {
    enabled = var.enable_cloud_cost_management
  }

  dataset_id = google_bigquery_dataset.billing_export.dataset_id
  member     = "serviceAccount:${google_service_account.integration.email}"
  project    = var.project
  role       = "roles/bigquery.dataEditor"
}

# Google Cloud Asset Project Feed Resource
# https://search.opentofu.org/provider/hashicorp/google/latest/docs/resources/cloud_asset_project_feed

resource "google_cloud_asset_project_feed" "export_asset_changes_to_datadog" {
  asset_types = [".*"]

  feed_id = "export-asset-changes-to-datadog"

  feed_output_config {
    pubsub_destination {
      topic = google_pubsub_topic.export_asset_changes_to_datadog.id
    }
  }

  project = var.project
}

# Google Logging Project Sink Resource
# https://search.opentofu.org/provider/hashicorp/google/latest/docs/resources/logging_project_sink

resource "google_logging_project_sink" "integration" {
  destination = "pubsub.googleapis.com/projects/${var.project}/topics/${google_pubsub_topic.integration.name}"

  exclusions {
    filter = "protoPayload.authenticationInfo.principalEmail=\"${google_service_account.integration.email}\""
    name   = "exclude-datadog-logs"
  }

  name                   = "export-logs-to-datadog"
  project                = var.project
  unique_writer_identity = true
}

# Google Project IAM Member Resource
# https://search.opentofu.org/provider/hashicorp/google/latest/docs/resources/google_project_iam#google_project_iam_member

resource "google_project_iam_member" "this" {
  for_each = toset([
    "organizations/163313809793/roles/datadog.cloudCostManagement",
    "roles/browser",
    "roles/cloudasset.viewer",
    "roles/compute.viewer",
    "roles/monitoring.viewer",
    "roles/securitycenter.findingsViewer"
  ])

  member  = "serviceAccount:${google_service_account.integration.email}"
  project = var.project
  role    = each.key
}

# Google PubSub Subscription Resource
# https://search.opentofu.org/provider/hashicorp/google/latest/docs/resources/pubsub_subscription

resource "google_pubsub_subscription" "export_asset_changes_to_datadog" {
  labels  = var.labels
  name    = "export-asset-changes-to-datadog"
  project = var.project
  topic   = google_pubsub_topic.export_asset_changes_to_datadog.name
}

resource "google_pubsub_subscription" "integration" {
  labels  = var.labels
  name    = "export-logs-to-datadog"
  project = var.project
  topic   = google_pubsub_topic.integration.name

  push_config {
    push_endpoint = "https://gcp-intake.logs.datadoghq.com/api/v2/logs?dd-api-key=${var.api_key}&dd-protocol=gcp"
  }
}

resource "google_pubsub_subscription_iam_member" "export_asset_changes_to_datadog" {
  member       = "serviceAccount:${google_service_account.integration.email}"
  project      = var.project
  role         = "roles/pubsub.subscriber"
  subscription = google_pubsub_subscription.export_asset_changes_to_datadog.name
}

# Google PubSub Topic Resource
# https://search.opentofu.org/provider/hashicorp/google/latest/docs/resources/pubsub_topic

resource "google_pubsub_topic" "export_asset_changes_to_datadog" {
  labels  = var.labels
  name    = "export-asset-changes-to-datadog"
  project = var.project
}

resource "google_pubsub_topic" "integration" {
  labels  = var.labels
  name    = "export-logs-to-datadog"
  project = var.project
}

# Google PubSub Topic IAM Member Resource
# https://search.opentofu.org/provider/hashicorp/google/latest/docs/resources/pubsub_topic_iam#google_pubsub_topic_iam_member

resource "google_pubsub_topic_iam_member" "integration" {
  member  = google_logging_project_sink.integration.writer_identity
  project = var.project
  role    = "roles/pubsub.publisher"
  topic   = google_pubsub_topic.integration.name
}

# Google Service Account Resource
# https://search.opentofu.org/provider/hashicorp/google/latest/docs/resources/google_service_account

resource "google_service_account" "integration" {
  account_id   = "datadog"
  display_name = "Service Account for Datadog"
  project      = var.project
}

# Google Service Account IAM Member Resource
# https://search.opentofu.org/provider/hashicorp/google/latest/docs/resources/google_service_account_iam_member

resource "google_service_account_iam_member" "integration" {
  member             = "serviceAccount:${datadog_integration_gcp_sts.this.delegate_account_email}"
  role               = "roles/iam.serviceAccountTokenCreator"
  service_account_id = google_service_account.integration.name
}

# Google Storage Bucket Resource
# https://search.opentofu.org/provider/hashicorp/google/latest/docs/resources/storage_bucket

resource "google_storage_bucket" "cloud_cost_management" {
  lifecycle {
    enabled = var.enable_cloud_cost_management
  }

  labels                      = var.labels
  location                    = var.cloud_cost_management_location
  name                        = "datadog-cloud-cost-management-${random_id.this.hex}"
  project                     = var.project
  uniform_bucket_level_access = true
}

# Google Storage Bucket IAM Member Resource
# https://search.opentofu.org/provider/hashicorp/google/latest/docs/resources/storage_bucket_iam_member

resource "google_storage_bucket_iam_member" "cloud_cost_management" {
  for_each = var.enable_cloud_cost_management ? toset([
    "roles/storage.legacyObjectReader",
    "roles/storage.legacyBucketWriter"
  ]) : toset([])

  bucket = google_storage_bucket.cloud_cost_management.name
  member = "serviceAccount:${google_service_account.integration.email}"
  role   = each.key
}

# Random ID Resource
# https://search.opentofu.org/provider/hashicorp/random/latest/docs/resources/id

resource "random_id" "this" {
  byte_length = "2"
  prefix      = "tf"
}
