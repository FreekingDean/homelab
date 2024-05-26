terraform {
  cloud {
    organization = "deangalvin3"

    workspaces {
      name = "homelab"
    }
  }

  required_providers {
    proxmox = {
      source  = "FreekingDean/proxmox"
      version = "0.0.9"
    }
    null = {
      source = "hashicorp/null"
    }
    ignition = {
      source = "community-terraform-providers/ignition"
    }
  }
}

provider "proxmox" {
  #pm_debug    = true
  host     = "https://10.0.0.101:8006/api2/json"
  username = "root@pam"
  #pm_password = local.root_password
}
