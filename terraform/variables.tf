variable "talos_version" {
  description = "Talos Linux version for nodes and generated machine configs."
  type        = string
  # renovate: datasource=github-releases depName=siderolabs/talos
  default = "v1.13.3"
}

variable "kubernetes_version" {
  description = "Kubernetes version to deploy via Talos."
  type        = string
  # renovate: datasource=github-releases depName=kubernetes/kubernetes
  default = "v1.36.1"
}

variable "gcp_project_id" {
  description = "GCP Project ID for backup storage"
  type        = string
  # renovate: datasource=github-releases depName=hashicorp/google
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
