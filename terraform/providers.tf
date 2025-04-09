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
      version = "0.7.1"
    }
    unifi = {
      source  = "paultyng/unifi"
      version = "0.41.0"
    }
    proxmox = {
      source  = "freekingdean/proxmox"
      version = "0.0.9"
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
  host     = "https://10.0.0.101:8006/api2/json"
  username = "root@pam"
}

provider "unifi" {
  api_url        = "https://192.168.2.1"
  allow_insecure = true
}
