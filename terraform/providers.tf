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
      version = "0.10.0"
    }
    unifi = {
      source  = "paultyng/unifi"
      version = "0.41.0"
    }
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.91.0"
    }
    null = {
      source = "hashicorp/null"
    }
    ignition = {
      version = "~> 2.6.0"
      source  = "community-terraform-providers/ignition"
    }
  }
}

provider "proxmox" {
  endpoint = "https://10.0.0.104:8006/api2/json"
  username = "root@pam"
  insecure = true
}

provider "unifi" {
  api_url        = "https://unifi.deangalvin.dev"
  allow_insecure = true
}
