# Local Values
# https://opentofu.org/docs/language/values/locals

locals {
  cloud_cost_management_roles = var.enable_cloud_cost_management ? toset(["roles/storage.legacyObjectReader", "roles/storage.legacyBucketWriter"]) : toset([])
}
