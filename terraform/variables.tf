variable "talos_version" {
  description = "Talos Linux version for nodes and generated machine configs."
  type        = string
  # renovate: datasource=github-releases depName=siderolabs/talos
  default = "v1.13.7"
}

variable "kubernetes_version" {
  description = "Kubernetes version to deploy via Talos."
  type        = string
  # renovate: datasource=github-releases depName=kubernetes/kubernetes
  default = "v1.36.3"
}

variable "cilium_migrated_nodes" {
  description = <<-EOT
    VM names handed over from flannel to Cilium. Add exactly one name per apply,
    verify the node, then add the next -- see docs/cilium-migration-plan.md.
    Listed nodes get the io.cilium.migration/cilium-default label and are applied
    with apply_mode "reboot"; every other node is untouched.

    Valid names: talos-{server,worker}-{cerritos,protostar,discovery}-1,
    talos-worker-defiant-1.
  EOT
  type        = set(string)
  default     = []
}
