locals {
  talos_version      = "v1.11.5"
  talos_cluster_name = "main-cluster"

  talos_control_plane_virtual_ip = "10.1.21.253"

  kubernetes_pod_cidr     = "10.200.0.0/16"
  kubernetes_service_cidr = "10.100.0.0/16"
}

module "discovery" {
  source = "./modules/talos"
  node   = "discovery"
  index  = 3

  servers = 1
  workers = 1


  network_id    = unifi_network.talos_network.id
  vlan_tag      = unifi_network.talos_network.vlan_id
  ceph_vlan_tag = 2

  talos_version                  = local.talos_version
  talos_machine_secrets          = talos_machine_secrets.this.machine_secrets
  talos_client_configuration     = talos_machine_secrets.this.client_configuration
  talos_cluster_name             = local.talos_cluster_name
  talos_control_plane_virtual_ip = local.talos_control_plane_virtual_ip

  kubernetes_pod_cidr     = local.kubernetes_pod_cidr
  kubernetes_service_cidr = local.kubernetes_service_cidr
}

module "cerritos" {
  source = "./modules/talos"
  node   = "cerritos"
  index  = 1

  servers = 1
  workers = 1

  network_id    = unifi_network.talos_network.id
  vlan_tag      = unifi_network.talos_network.vlan_id
  ceph_vlan_tag = 2

  talos_version                  = local.talos_version
  talos_machine_secrets          = talos_machine_secrets.this.machine_secrets
  talos_client_configuration     = talos_machine_secrets.this.client_configuration
  talos_cluster_name             = local.talos_cluster_name
  talos_control_plane_virtual_ip = local.talos_control_plane_virtual_ip

  kubernetes_pod_cidr     = local.kubernetes_pod_cidr
  kubernetes_service_cidr = local.kubernetes_service_cidr
}

module "protostar" {
  source = "./modules/talos"
  node   = "protostar"
  index  = 2

  servers = 1
  workers = 1

  network_id    = unifi_network.talos_network.id
  vlan_tag      = unifi_network.talos_network.vlan_id
  ceph_vlan_tag = 2

  talos_version                  = local.talos_version
  talos_machine_secrets          = talos_machine_secrets.this.machine_secrets
  talos_client_configuration     = talos_machine_secrets.this.client_configuration
  talos_cluster_name             = local.talos_cluster_name
  talos_control_plane_virtual_ip = local.talos_control_plane_virtual_ip

  kubernetes_pod_cidr     = local.kubernetes_pod_cidr
  kubernetes_service_cidr = local.kubernetes_service_cidr
}


module "defiant" {
  source = "./modules/talos"
  node   = "defiant"
  index  = 4

  servers = 0
  workers = 1

  network_id    = unifi_network.talos_network.id
  vlan_tag      = unifi_network.talos_network.vlan_id
  ceph_vlan_tag = 2

  talos_version                  = local.talos_version
  talos_machine_secrets          = talos_machine_secrets.this.machine_secrets
  talos_client_configuration     = talos_machine_secrets.this.client_configuration
  talos_cluster_name             = local.talos_cluster_name
  talos_control_plane_virtual_ip = local.talos_control_plane_virtual_ip

  kubernetes_pod_cidr     = local.kubernetes_pod_cidr
  kubernetes_service_cidr = local.kubernetes_service_cidr
}

resource "talos_machine_secrets" "this" {}

data "talos_client_configuration" "this" {
  cluster_name         = "example-cluster"
  client_configuration = talos_machine_secrets.this.client_configuration
  nodes = flatten(
    [
      module.discovery.ips,
      module.cerritos.ips,
      module.protostar.ips,
    ]
  )
}

resource "talos_machine_bootstrap" "this" {
  node                 = module.discovery.control_plane[0].vm_ip
  client_configuration = talos_machine_secrets.this.client_configuration
}

resource "talos_cluster_kubeconfig" "this" {
  depends_on           = [talos_machine_bootstrap.this]
  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = local.talos_control_plane_virtual_ip
}

output "kubeconfig" {
  value     = talos_cluster_kubeconfig.this.kubeconfig_raw
  sensitive = true
}

output "talosconfig" {
  value     = data.talos_client_configuration.this.talos_config
  sensitive = true
}
