locals {
  k3s = {
    version    = var.k3s_version
    subversion = var.k3s_subversion
    arch       = "amd64"
    url_base   = "https://github.com/k3s-io/k3s/releases/download"
  }
  k3s_fullurl    = "${local.k3s.url_base}/${local.k3s.version}%2B${local.k3s.subversion}"
  k3s_shasum_url = "${local.k3s_fullurl}/sha256sum-${local.k3s.arch}.txt"
  k3s_binary_url = "${local.k3s_fullurl}/k3s"
  vmid           = "${var.node_id}${format("%02d", var.id)}"
  hostname_type  = var.hostname_type != "" ? var.hostname_type : var.k3s_type
  hostname       = "coreos-${local.hostname_type}-${local.vmid}"
}

resource "proxmox_node_virtual_machine" "guest" {
  id          = local.vmid
  fw_config   = "name=opt/com.coreos/config,string='${local.ign_rendered}'"
  reboot      = false
  name        = local.hostname
  node        = var.node
  memory      = var.memory
  cpus        = var.cpus
  guest_agent = true
  serials = [
    "socket"
  ]

  scsi {
    import_from = var.coreos_volid
    storage     = var.primary_storage
    readonly    = true
  }

  scsi {
    storage = var.storage_name
    size_gb = var.storage_size
  }

  dynamic "scsi" {
    for_each = {
      for index, disk in var.additional_storages :
      index => disk
    }

    content {
      storage = scsi.value.storage
      size_gb = scsi.value.size
    }
  }

  dynamic "scsi" {
    for_each = var.direct_disks

    content {
      content = scsi.value
      backup  = false
    }
  }

  network {
    bridge   = "vmbr0"
    firewall = true
  }
}

resource "null_resource" "reboot_if_update" {
  triggers = {
    ignition = local.ign_rendered
  }
  connection {
    type        = "ssh"
    user        = "k3suser"
    private_key = file(var.private_key_path)
    host        = var.ip
  }

  provisioner "remote-exec" {
    inline     = ["sudo touch /var/run/reboot-required"]
    on_failure = continue
  }
}
