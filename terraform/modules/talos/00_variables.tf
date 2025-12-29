variable "node" {
  description = "The name of the node"
  type        = string
}

variable "index" {
  description = "The index of the node"
  type        = number
}

variable "network_id" {
  description = "The network id to use for the node"
  type        = string
}

variable "servers" {
  description = "The number of servers to create"
  type        = number
}

variable "workers" {
  description = "The number of workers to create"
  type        = number
}

variable "vlan_tag" {
  description = "The VLAN tag to use for the network"
  type        = number
}

variable "ceph_vlan_tag" {
  description = "The VLAN tag to use for the ceph frontend network"
  type        = number
}

variable "talos_version" {
  description = "Talos version to use eg. v1.9.5"
  type        = string
}

variable "talos_cluster_name" {
  description = "The name of the talos cluster"
  type        = string
}

variable "talos_machine_secrets" {
  description = "The talos machine secrets"
  type        = any
}

variable "talos_client_configuration" {
  description = "The talos client configuration"
  type        = any
}

variable "talos_control_plane_virtual_ip" {
  description = "The control plane Virtual IP address"
  type        = string
}

variable "kubernetes_service_cidr" {
  description = "The CIDR range for the Kubernetes service IPs"
  type        = string
}

variable "kubernetes_pod_cidr" {
  description = "The CIDR range for the Kubernetes pods"
  type        = string
}
