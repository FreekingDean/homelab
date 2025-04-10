locals {
  nodes = [
    "cerritos",
    "discovery",
    #"defiant",
    "protostar",
  ]
  talos_version      = "v1.9.5"
  talos_cluster_name = "example-cluster"
}

#module "cerritos_talos_server" {
#  source = "./modules/talos"
#  node   = "cerritos"
#  index  = 1
#
#  servers = 1
#  workers = 3
#
#  network_id = unifi_network.talos_network.id
#  vlan_tag   = unifi_network.talos_network.vlan_id
#
#  talos_version              = local.talos_version
#  talos_machine_secrets      = talos_machine_secrets.this.machine_secrets
#  talos_client_configuration = talos_machine_secrets.this.client_configuration
#  talos_cluster_name         = local.talos_cluster_name
#  talos_cluster_endpoint     = "https://${module.discovery_talos_server.control_node_ip}:6443"
#}
##
##module "protostar_talos_server" {
##  source = "./modules/talos"
##  node   = "protostar"
##  index  = 2
##
##  servers = 1
##  workers = 3
##
##  talos_version = local.talos_version
##  arch          = "amd64"
##
##  network_id = unifi_network.talos_network.id
##}
#
#module "discovery_talos_server" {
#  source = "./modules/talos"
#  node   = "discovery"
#  index  = 3
#
#  servers = 1
#  workers = 3
#
#  network_id = unifi_network.talos_network.id
#  vlan_tag   = unifi_network.talos_network.vlan_id
#
#  talos_version              = local.talos_version
#  talos_machine_secrets      = talos_machine_secrets.this.machine_secrets
#  talos_client_configuration = talos_machine_secrets.this.client_configuration
#  talos_cluster_name         = local.talos_cluster_name
#}
#
##module "defiant_talos_server" {
##  source = "./modules/talos"
##  node  = "defiant"
##  index = count.index
##
##  servers = 1
##  workers = 3
##
##  talos_version = local.talos_version
##  arch          = "amd64"
##
##  network_id = unifi_network.talos_network.id
##  talos_version              = local.talos_version
##  talos_machine_secrets      = talos_machine_secrets.this.machine_secrets
##  talos_client_configuration = talos_machine_secrets.this.client_configuration
##  talos_cluster_name         = local.talos_cluster_name
##  talos_cluster_endpoint     = "https://${module.discovery_talos_server.control_node_ip}:6443"
##}
#resource "talos_machine_secrets" "this" {}
#
#data "talos_client_configuration" "this" {
#  cluster_name         = "example-cluster"
#  client_configuration = talos_machine_secrets.this.client_configuration
#  nodes = flatten(
#    [
#      module.discovery_talos_server.ips,
#      module.cerritos_talos_server.ips,
#      #module.protostar_talos_server.ips,
#      #module._talos_server.ips,
#    ]
#  )
#}
#
#
#resource "talos_cluster_kubeconfig" "this" {
#  client_configuration = talos_machine_secrets.this.client_configuration
#  node                 = module.discovery_talos_server.control_node_ip
#}
#
#output "kubeconfig" {
#  value     = talos_cluster_kubeconfig.this.kubeconfig_raw
#  sensitive = true
#}
