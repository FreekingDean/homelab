locals {
  taint_args = [for taint in var.taints : "--node-taint \"${taint}\""]
  base_args = concat([
    "--data-dir /var/lib/k3sdata",
    "--token spinthedata",
  ], local.taint_args)

  agent_args = join(" ", concat(local.base_args, ["--server https://${var.server_ip}:6443"]))

  server_arg = var.server_ip == var.ip ? "--cluster-init" : "--server https://${var.server_ip}:6443"
  server_args = join(" ", concat(local.base_args, [
    local.server_arg,
    "--disable traefik",
    "--disable-helm-controller",
    "--node-taint \"CriticalAddonsOnly=true:NoExecute\"",
    "--etcd-expose-metrics true",
  ]))

  k3s_args = var.k3s_type == "server" ? local.server_args : local.agent_args
}

data "ignition_systemd_unit" "k3s_service" {
  name    = "k3s.service"
  enabled = true
  content = templatefile(
    "${path.module}/units/k3s.service",
    {
      k3s_command = var.k3s_type
      args        = local.k3s_args
    },
  )
}

data "ignition_systemd_unit" "qemu_ga_install_service" {
  name    = "qemu-ga-install.service"
  enabled = true
  content = file("${path.module}/units/qemu-ga-install.service")
}

data "ignition_systemd_unit" "k3s_partition_service" {
  name    = "var-lib-k3sdata-partition.service"
  enabled = true
  content = templatefile("${path.module}/units/partition.service", {
    label = "K3S_DATA"
    file  = "var-lib-k3s-data-partition"
  })
}

data "ignition_systemd_unit" "var_lib_k3sdata_mount" {
  name    = "var-lib-k3sdata.mount"
  enabled = true
  content = templatefile("${path.module}/units/disk.mount", {
    mount             = "/var/lib/k3sdata"
    label             = "K3S_DATA"
    partition_service = "var-lib-k3sdata-partition.service"
  })
}

data "ignition_systemd_unit" "extra_disk_partition" {
  for_each = {
    for index, disk in var.additional_storages :
    index => disk
  }

  name    = "${join("-", compact(split("/", each.value.mount)))}-partition.service"
  enabled = true
  content = templatefile("${path.module}/units/partition.service", {
    label = each.value.label
    file  = "${join("-", compact(split("/", each.value.mount)))}-partition"
  })
}

data "ignition_systemd_unit" "extra_disk_mount" {
  for_each = {
    for index, disk in var.additional_storages :
    index => disk
  }

  name    = "${join("-", compact(split("/", each.value.mount)))}.mount"
  enabled = true
  content = templatefile("${path.module}/units/disk.mount", {
    mount             = each.value.mount
    label             = each.value.label
    partition_service = "${join("-", compact(split("/", each.value.mount)))}-partition.service"
  })
}
