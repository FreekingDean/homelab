locals {
  k3s = {
    version    = "v1.26.1"
    subversion = "k3s1"
  }
  coreos = {
    version = "37.20230218.3.0"
  }
}

#module "ds9_servers" {
#  source  = "./modules/k3s_node"
#  count   = 3
#  node    = "ds9"
#  id      = count.index
#  node_id = 3
#  memory  = 8 * 1024
#  cpus    = 4
#
#
#  coreos_volid = "local:999/fedora-coreos-${local.coreos.version}-qemu.x86_64.qcow2"
#  storage_name = "etcd-storage"
#  storage_size = 16
#
#  k3s_version    = local.k3s.version
#  k3s_subversion = local.k3s.subversion
#  k3s_type       = "server"
#
#  github_user = "FreekingDean"
#  #password    = "testpass"
#}
#
##module "enterprise_agents_ceph" {
##  source  = "./modules/k3s_node"
##  node    = "enterprise"
##  id      = 4
##  node_id = 1
##  memory  = 5 * disks.enterprise.count * 1024
##  cpus    = 8
##
##
##  coreos_volid = module.enterprise.coreos_volid
##  storage_name = "local-thin"
##  storage_size = 16
##
##  k3s_version    = local.k3s.version
##  k3s_subversion = local.k3s.subversion
##  k3s_type       = "agent"
##
##  github_user = "FreekingDean"
##  #password    = "testpass"
##  additional_disks = [
##    "/dev/disks/by-path/pci-0000:03:00.0-sas-phy0-lun-0"
##  ]
##}
#
#output "ip_addresses" {
#  value = "test"
#}
#
#output "disks" {
#  value = "test2"
#}
