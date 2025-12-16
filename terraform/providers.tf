terraform {
  cloud {
    organization = "deangalvin3"

    workspaces {
      name = "homelab"
    }
  }

  required_providers {
    talos = {
      source  = "siderolabs/talos"
      version = "0.9.0"
    }
    unifi = {
      source  = "paultyng/unifi"
      version = "0.41.0"
    }
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.89.1"
    }
    null = {
      source = "hashicorp/null"
    }
    ignition = {
      version = "~>2.4.0"
      source  = "community-terraform-providers/ignition"
    }
  }
}

provider "proxmox" {
  #pm_debug    = true
  endpoint = "https://10.0.0.108:8006/api2/json"
  username = "root@pam"
  insecure = true
}

provider "unifi" {
  api_url        = "https://192.168.2.1"
  allow_insecure = true
}
