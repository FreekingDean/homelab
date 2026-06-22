variable "talos_version" {
  description = "Talos Linux version for nodes and generated machine configs."
  type        = string
  # renovate: datasource=github-releases depName=siderolabs/talos
  default = "v1.13.4"
}

variable "kubernetes_version" {
  description = "Kubernetes version to deploy via Talos."
  type        = string
  # renovate: datasource=github-releases depName=kubernetes/kubernetes
  default = "v1.36.2"
}

variable "gcp_project_id" {
  description = "GCP Project ID for backup storage"
  type        = string
}

variable "gcp_region" {
  description = "GCP Region for resources"
  type        = string
  default     = "us-central1"
}

variable "gcp_bucket_name_suffix" {
  description = "Suffix for backup bucket name (project will be prepended)"
  type        = string
  default     = "backups"
}

variable "onepassword_connect_host" {
  description = "1Password Connect host URL used to publish backup credentials."
  type        = string
  default     = "https://onepassword-connect.deangalvin.dev"
}

variable "onepassword_connect_token" {
  description = "1Password Connect API token (set via TF_VAR / workspace variable)."
  type        = string
  sensitive   = true
}

variable "onepassword_vault" {
  description = "1Password vault that holds the restic backup item."
  type        = string
  default     = "Homelab"
}
