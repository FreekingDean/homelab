variable "k3s_version" {
  description = "The version of k3s to install"
  type        = string
}

variable "k3s_subversion" {
  description = "The subversion of k3s to install"
  type        = string
}

variable "k3s_type" {
  description = "The type of the node (server | agent)"
  type        = string
  validation {
    condition     = contains(["server", "agent"], var.k3s_type)
    error_message = "Allowed values for k3s_type parameter are \"agent\" or \"server\"."
  }
}

variable "node_id" {
  description = "The number id of the node"
  type        = number
}

variable "id" {
  description = "The number id of the vm"
  type        = number
}

variable "node" {
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

variable "storage_name" {
  description = "The name of the storage device to use for persistent storage"
  type        = string
}

variable "storage_size" {
  description = "The size in GB to use for storage"
  type        = number
}

#variable "password" {
#  description = "The password for the coreos user"
#  type        = string
#}

variable "github_user" {
  description = "The github user for the coreos user to fetch keys for"
  type        = string
}

variable "coreos_volid" {
  description = "The coreos volume id"
  type        = string
}

variable "taints" {
  type    = list(string)
  default = []
}

variable "direct_disks" {
  type    = list(string)
  default = []
}

variable "hostname_type" {
  type    = string
  default = ""
}

variable "additional_storages" {
  type = list(object({
    mount   = string
    size    = number
    label   = string
    storage = string
  }))
  default = []
}

variable "ip" {
  type = string
}

variable "server_ip" {
  type = string
}

variable "primary_storage" {
  type    = string
  default = "local-thin"
}
