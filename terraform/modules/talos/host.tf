locals {
  talos_download_url = "https://factory.talos.dev/image/ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515/${var.talos_version}/metal-amd64.iso"
}

#data "proxmox_storage" "local" {
#  name = "local"
#}
#
#data "proxmox_node" "node" {
#  name = var.node
#}

resource "proxmox_node_storage_content" "iso" {
  storage  = "${var.node}/local"
  filename = "talos-${var.talos_version}-amd64.iso"
  iso {
    url = local.talos_download_url
  }
}

locals {
  servers = [for i in range(var.servers) : "talos-server-${var.node}-${i + 1}"]
  workers = [for i in range(var.workers) : "talos-worker-${var.node}-${i + 1}"]
}

module "talos_servers" {
  count  = length(local.servers)
  source = "../../modules/talos_vm"

  node       = var.node
  name       = local.servers[count.index]
  node_index = var.index + 1
  index      = count.index + 1

  memory     = 4096
  cpus       = 4
  disk_size  = 32
  vlan_tag   = var.vlan_tag
  network_id = var.network_id

  talos_client_configuration = var.talos_client_configuration
  talos_machine_secrets      = var.talos_machine_secrets
  talos_machine_type         = "controlplane"
  talos_cluster_name         = var.talos_cluster_name
  talos_version              = var.talos_version
  talos_cluster_endpoint     = var.talos_cluster_endpoint
}

module "talos_workers" {
  count  = length(local.workers)
  source = "../../modules/talos_vm"

  node       = var.node
  name       = local.workers[count.index]
  node_index = var.index + 1
  index      = count.index + 2

  memory     = 4096
  cpus       = 12
  disk_size  = 64
  vlan_tag   = var.vlan_tag
  network_id = var.network_id

  talos_client_configuration = var.talos_client_configuration
  talos_machine_secrets      = var.talos_machine_secrets
  talos_machine_type         = "worker"
  talos_cluster_name         = var.talos_cluster_name
  talos_version              = var.talos_version
  talos_cluster_endpoint     = var.talos_cluster_endpoint == "" ? "https://${module.talos_servers[0].vm_ip}:6443" : var.talos_cluster_endpoint
}

output "ips" {
  value = flatten(
    [
      [for vm in module.talos_servers : vm.vm_ip],
      [for vm in module.talos_workers : vm.vm_ip]
    ]
  )
}
