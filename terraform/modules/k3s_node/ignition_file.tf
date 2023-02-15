data "http" "k3s_sha256" {
  url = local.k3s_shasum_url
}

locals {
  shasums = compact(split(" ",
    compact(split("\n", data.http.k3s_sha256.response_body))[0],
  ))[0]
}

data "ignition_file" "hostname" {
  path      = "/etc/hostname"
  overwrite = true
  uid       = 0
  gid       = 0
  mode      = 420

  content {
    content = local.hostname
  }
}

data "ignition_file" "k3s" {
  path      = "/usr/local/bin/k3s"
  overwrite = true
  uid       = 0
  gid       = 0
  mode      = 493

  source {
    source       = local.k3s_binary_url
    verification = "sha256-${local.shasums}"
  }
}

data "ignition_file" "partition" {
  path = "/usr/local/bin/var-lib-k3s-data-partition"

  overwrite = true
  uid       = 0
  gid       = 0
  mode      = 493
  content {
    content = templatefile("${path.module}/files/partition", {
      label   = "K3S_DATA"
      scsi_id = 1
    })
  }
}

data "ignition_file" "qemu_ga_installer" {
  path = "/usr/local/bin/qemu-ga-installer"

  overwrite = true
  uid       = 0
  gid       = 0
  mode      = 493
  content {
    content = file("${path.module}/files/qemu-ga-installer")
  }
}

data "ignition_link" "timezone" {
  path   = "/etc/localtime"
  target = "/usr/share/zoneinfo/America/New_York"
}

data "ignition_file" "node_password" {
  path = "/etc/rancher/node/password"
  mode = 384
  content {
    content = local.hostname
  }
}

data "ignition_file" "network_interface" {
  path = "/etc/NetworkManager/system-connections/ens18.nmconnection"
  mode = 384
  content {
    content = templatefile("${path.module}/files/ens18.nmconnection", {
      ip_addr  = var.ip
      hostname = local.hostname
    })
  }
}

data "ignition_file" "additional_partition" {
  for_each = {
    for index, disk in var.additional_storages :
    index => disk
  }
  path = "/usr/local/bin/${join("-", compact(split("/", each.value.mount)))}-partition"

  overwrite = true
  uid       = 0
  gid       = 0
  mode      = 493
  content {
    content = templatefile("${path.module}/files/partition", {
      label   = each.value.label
      scsi_id = each.key + 2
    })
  }
}
