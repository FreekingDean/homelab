module "enterprise" {
  source = "./modules/host"

  node = "enterprise"
  id   = 1

  coreos_version = local.coreos.version
  k3s_version    = local.k3s.version
  k3s_subversion = local.k3s.subversion

  cluster_server = module.ds9.cluster_server_ip

  servers = 0
  agents  = 0
}

module "voyager" {
  source = "./modules/host"

  node = "voyager"
  id   = 2

  coreos_version = local.coreos.version
  k3s_version    = local.k3s.version
  k3s_subversion = local.k3s.subversion

  cluster_server = module.ds9.cluster_server_ip

  servers = 0
  agents  = 0
}

module "ds9" {
  source = "./modules/host"

  node = "ds9"
  id   = 3

  coreos_version = local.coreos.version
  k3s_version    = local.k3s.version
  k3s_subversion = local.k3s.subversion


  servers = 3
  agents  = 0
}

module "defiant" {
  source = "./modules/host"

  node = "defiant"
  id   = 4

  coreos_version = local.coreos.version
  k3s_version    = local.k3s.version
  k3s_subversion = local.k3s.subversion

  cluster_server = module.ds9.cluster_server_ip

  servers = 1
  agents  = 3

  primary_storage = "local"
  server_storage  = "local"
}

module "discovery" {
  source = "./modules/host"

  node = "discovery"
  id   = 5

  coreos_version = local.coreos.version
  k3s_version    = local.k3s.version
  k3s_subversion = local.k3s.subversion

  cluster_server = module.ds9.cluster_server_ip

  servers = 1
  agents  = 3

  primary_storage = "local"
  server_storage  = "local"
}

module "cerritos" {
  source = "./modules/host"

  node = "cerritos"
  id   = 6

  coreos_version = local.coreos.version
  k3s_version    = local.k3s.version
  k3s_subversion = local.k3s.subversion

  cluster_server = module.ds9.cluster_server_ip

  servers = 1
  agents  = 3

  primary_storage = "local"
  server_storage  = "local"
}

module "protostar" {
  source = "./modules/host"

  node = "protostar"
  id   = 7

  coreos_version = local.coreos.version
  k3s_version    = local.k3s.version
  k3s_subversion = local.k3s.subversion

  cluster_server = module.ds9.cluster_server_ip

  servers = 1
  agents  = 3

  primary_storage = "local"
  server_storage  = "local"
}

locals {
  hosts = [
    module.enterprise,
    module.voyager,
    module.ds9,
  ]
}
