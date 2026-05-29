# GCS Bucket for Volsync backups
resource "google_storage_bucket" "volsync_backups" {
  name          = "${var.gcp_project_id}-${var.gcp_bucket_name_suffix}"
  location      = var.gcp_region
  project       = var.gcp_project_id
  
  uniform_bucket_level_access = true
  
  # Enable versioning for additional safety
  versioning {
    enabled = true
  }

  # No object lifecycle rules: restic/volsync owns retention (forget/prune).
  # Age-based GCS transitions/deletes operate per-object and would interfere
  # with restic's content-addressed packs (corruption risk on Delete, and
  # COLDLINE retrieval/min-duration costs on restic's frequent reads).

  # Encryption
  encryption {
    default_kms_key_name = null  # Use Google-managed encryption
  }
  
  # Tags for organization
  labels = {
    environment = "homelab"
    purpose     = "volsync-backups"
    managed_by  = "terraform"
  }
}

# Service Account for Volsync
resource "google_service_account" "volsync" {
  account_id   = "volsync-backup"
  display_name = "Volsync Backup Service Account"
  project      = var.gcp_project_id
}

# Service Account Key (stored in 1Password externally, this is just the SA)
# The key will be created manually and stored in 1Password

# IAM Policy: Grant service account access to the bucket
resource "google_storage_bucket_iam_member" "volsync" {
  bucket = google_storage_bucket.volsync_backups.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.volsync.email}"
}

# Additional IAM: Grant access to list buckets (for Volsync)
resource "google_storage_bucket_iam_member" "volsync_list" {
  bucket = google_storage_bucket.volsync_backups.name
  role   = "roles/storage.legacyBucketReader"
  member = "serviceAccount:${google_service_account.volsync.email}"
}

# Output the service account email for 1Password integration
output "service_account_email" {
  value       = google_service_account.volsync.email
  description = "Service account email to use in Volsync configuration"
}

output "bucket_name" {
  value       = google_storage_bucket.volsync_backups.name
  description = "GCS bucket name for Volsync backups"
}

output "service_account_id" {
  value       = google_service_account.volsync.id
  description = "Full resource ID of the service account"
}
