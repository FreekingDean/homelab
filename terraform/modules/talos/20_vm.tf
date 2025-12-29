locals {
  servers = [for i in range(var.servers) : "talos-server-${var.node}-${i + 1}"]
  workers = [for i in range(var.workers) : "talos-worker-${var.node}-${i + 1}"]
}

module "talos_servers" {
  count  = length(local.servers)
  source = "../../modules/talos_vm"
  depends_on = [
    proxmox_virtual_environment_download_file.iso
  ]

  node       = var.node
  name       = local.servers[count.index]
  node_index = var.index + 1
  index      = count.index + 1

  memory        = 4096
  cpus          = 4
  disk_size     = 64
  vlan_tag      = var.vlan_tag
  ceph_vlan_tag = var.ceph_vlan_tag
  network_id    = var.network_id
  iso           = "local:iso/talos-${var.talos_version}-amd64.iso"
}

module "talos_workers" {
  count  = length(local.workers)
  source = "../../modules/talos_vm"
  depends_on = [
    proxmox_virtual_environment_download_file.iso
  ]

  node       = var.node
  name       = local.workers[count.index]
  node_index = var.index + 1
  index      = count.index + 2

  memory        = (96 / var.workers) * 1024
  cpus          = 36 / var.workers
  disk_size     = 128
  vlan_tag      = var.vlan_tag
  ceph_vlan_tag = var.ceph_vlan_tag
  network_id    = var.network_id
  iso           = "local:iso/talos-${var.talos_version}-amd64.iso"
}

output "control_plane" {
  description = "The Control Plane VMs"
  value       = tolist(module.talos_servers)
}

output "workers" {
  description = "The Worker VMs"
  value       = tolist(module.talos_workers)
}

output "ips" {
  value = flatten(
    [
      [for vm in module.talos_servers : vm.vm_ip],
      [for vm in module.talos_workers : vm.vm_ip]
    ]
  )
}
