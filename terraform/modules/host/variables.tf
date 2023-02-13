variable "id" {
  type = number
}

variable "coreos_version" {
  description = "The version of coreos to install"
  type        = string
}

variable "node" {
  description = "The node to make adjustments to"
  type        = string
}

variable "k3s_version" {
  type = string
}

variable "k3s_subversion" {
  type = string
}

variable "agents" {
  type = number
}

variable "servers" {
  type = number
}

variable "ceph_nodes" {
  type = list(object({
    disks = list(string)
  }))
}

variable "cluster_server" {
  type    = string
  default = ""
}
