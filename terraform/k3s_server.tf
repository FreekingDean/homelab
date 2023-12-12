locals {
  k3s = {
    version    = "v1.28.4"
    subversion = "k3s2"
  }
  coreos = {
    version = "39.20231119.3.0"
  }
}

variable "private_key_path" {
  type    = string
  default = "~/.ssh/id_ed25519"
}
