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
variable "ceph_vlan_tag" {
  description = "The VLAN tag to use for the ceph frontend network"
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

variable "iso" {
  description = "The ISO file to use for the node"
  type        = string
}
