variable "node" {
  description = "The name of the node"
  type        = string
}

variable "name" {
  description = "The name of the node"
  type        = string
}

variable "memory" {
  description = "The total mb of memory for the guest"
  type        = number
}

variable "cpus" {
  description = "The number of vCPUs"
  type        = number
}
variable "disk_size" {
  description = "The size in GB to use for the disk"
  type        = number
}
variable "vlan_tag" {
  description = "The VLAN tag to use for the network"
  type        = number
}
variable "network_id" {
  description = "The network id to use for the node"
  type        = string
}
variable "index" {
  description = "The index of the node"
  type        = number
}

variable "node_index" {
  description = "The index of the node"
  type        = number
}

variable "talos_client_configuration" {
  description = "The talos client configuration"
}

variable "talos_machine_secrets" {
  description = "The talos machine secrets"
  type        = any
}

variable "talos_machine_type" {
  description = "The talos machine type (worker or control-plane)"
  type        = string
}

variable "talos_cluster_name" {
  description = "The name of the talos cluster"
  type        = string
}

variable "talos_cluster_endpoint" {
  description = "The talos cluster endpoint"
  type        = string
  default     = ""
}

variable "talos_version" {
  description = "Talos version to use eg. v1.9.5"
  type        = string
}
