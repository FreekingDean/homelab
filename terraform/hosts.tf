#module "defiant" {
#  source = "./modules/host"
#
#  node = "defiant"
#  id   = 4
#
#  coreos_version = local.coreos.version
#  k3s_version    = local.k3s.version
#  k3s_subversion = local.k3s.subversion
#
#  cluster_server = module.discovery.cluster_server_ip
#
#  servers = 1
#  agents  = 3
#
#  primary_storage = "local"
#  server_storage  = "local"
#
#  private_key_path = var.private_key_path
#}

module "discovery" {
  source = "./modules/host"

  node = "discovery"
  id   = 5

  coreos_version = local.coreos.version
  k3s_version    = local.k3s.version
  k3s_subversion = local.k3s.subversion

  servers = 1
  agents  = 3

  primary_storage = "local"
  server_storage  = "local"

  private_key_path = var.private_key_path
}

module "cerritos" {
  source = "./modules/host"

  node = "cerritos"
  id   = 6

  coreos_version = local.coreos.version
  k3s_version    = local.k3s.version
  k3s_subversion = local.k3s.subversion

  cluster_server = module.discovery.cluster_server_ip

  servers = 1
  agents  = 3

  primary_storage = "local"
  server_storage  = "local"

  private_key_path = var.private_key_path
}

module "protostar" {
  source = "./modules/host"

  node = "protostar"
  id   = 7

  coreos_version = local.coreos.version
  k3s_version    = local.k3s.version
  k3s_subversion = local.k3s.subversion

  cluster_server = module.discovery.cluster_server_ip

  servers = 1
  agents  = 3

  primary_storage = "local"
  server_storage  = "local"

  private_key_path = var.private_key_path
}

locals {
  hosts = [
    #module.defiant,
    module.discovery,
    module.cerritos,
    module.protostar,
  ]
}
