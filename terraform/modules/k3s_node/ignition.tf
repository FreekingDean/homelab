data "http" "github_keys" {
  url = "https://github.com/${var.github_user}.keys"
}

data "ignition_user" "deangalvin" {
  name                = "k3suser"
  password_hash       = "$1$Sum2f7dz$aErp/G3mUuHH2diPBP/ZV." #bcrypt(var.password)
  ssh_authorized_keys = compact(split("\n", data.http.github_keys.response_body))

  groups = [
    "wheel",
    "sudo",
  ]
}

data "ignition_config" "k3s" {
  users = [
    data.ignition_user.deangalvin.rendered,
  ]

  files = concat([
    data.ignition_file.k3s.rendered,
    data.ignition_file.partition.rendered,
    data.ignition_file.qemu_ga_installer.rendered,
    data.ignition_file.hostname.rendered,
    data.ignition_file.network_interface.rendered,
    data.ignition_file.node_password.rendered,
  ], [for o in data.ignition_file.additional_partition : o.rendered])

  systemd = concat([
    data.ignition_systemd_unit.qemu_ga_install_service.rendered,
    data.ignition_systemd_unit.k3s_service.rendered,
    data.ignition_systemd_unit.var_lib_k3sdata_mount.rendered,
    data.ignition_systemd_unit.k3s_partition_service.rendered,
    ],
    [for o in data.ignition_systemd_unit.extra_disk_partition : o.rendered],
    [for o in data.ignition_systemd_unit.extra_disk_mount : o.rendered],
  )

  links = [
    data.ignition_link.timezone.rendered,
  ]
}

locals {
  ign_rendered = replace(
    data.ignition_config.k3s.rendered, ",", ",,",
  )
}
