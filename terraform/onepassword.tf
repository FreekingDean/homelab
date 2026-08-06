# Restic repository password, generated once and tracked in Terraform state.
resource "random_password" "restic" {
  length  = 48
  special = false
}

# Publish the restic credentials to the 1Password "restic" item that the
# kubernetes/components/volsync ExternalSecret reads (dataFrom extract key:
# restic). The field labels here must match the keys that ExternalSecret
# templates: repository_template, restic_password, gcp_access_key,
# gcp_access_secret.
#
# NOTE: if a "restic" item already exists in the vault, import it first:
#   terraform import onepassword_item.restic <vault>/<item-uuid>
resource "onepassword_item" "restic" {
  vault    = var.onepassword_vault
  title    = "restic"
  category = "password"

  section {
    label = "volsync"

    field {
      label = "repository_template"
      value = "s3:https://storage.googleapis.com/${google_storage_bucket.volsync_backups.name}"
    }
    field {
      label = "restic_password"
      type  = "CONCEALED"
      value = random_password.restic.result
    }
    field {
      label = "gcp_access_key"
      value = google_storage_hmac_key.volsync.access_id
    }
    field {
      label = "gcp_access_secret"
      type  = "CONCEALED"
      value = google_storage_hmac_key.volsync.secret
    }
  }
}
