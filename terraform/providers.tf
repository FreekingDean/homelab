terraform {
  cloud {
    organization = "deangalvin3"

    workspaces {
      name = "homelab"
    }
  }

  required_providers {
    proxmox = {
      source = "FreekingDean/proxmox"
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
  #pm_api_url  = "https://10.0.0.103:8006/api2/json"
  #pm_user     = "root@pam"
  #pm_password = local.root_password
}
