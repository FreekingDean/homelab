variable "talos_version" {
  description = "Talos Linux version for nodes and generated machine configs."
  type        = string
  # renovate: datasource=github-releases depName=siderolabs/talos
  default = "v1.12.6"
}

variable "kubernetes_version" {
  description = "Kubernetes version to deploy via Talos."
  type        = string
  # renovate: datasource=github-releases depName=kubernetes/kubernetes
  default = "v1.35.4"
}
