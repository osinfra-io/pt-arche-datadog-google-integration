# Moved Blocks
# https://opentofu.org/docs/language/moved

moved {
  from = google_storage_bucket_iam_member.cloud_cost_management
  to   = google_storage_bucket_iam_member.cloud_cost_managements
}
