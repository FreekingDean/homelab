module "enterprise" {
  source = "./modules/host"

  node = "enterprise"
  id   = 1

  coreos_version = local.coreos.version
  k3s_version    = local.k3s.version
  k3s_subversion = local.k3s.subversion

  cluster_server = module.ds9.cluster_server_ip

  servers    = 0
  agents     = 2
  ceph_nodes = []
}

module "voyager" {
  source = "./modules/host"

  node = "voyager"
  id   = 2

  coreos_version = local.coreos.version
  k3s_version    = local.k3s.version
  k3s_subversion = local.k3s.subversion

  cluster_server = module.ds9.cluster_server_ip

  servers    = 0
  agents     = 2
  ceph_nodes = []
}

module "ds9" {
  source = "./modules/host"

  node = "ds9"
  id   = 3

  coreos_version = local.coreos.version
  k3s_version    = local.k3s.version
  k3s_subversion = local.k3s.subversion


  servers    = 3
  agents     = 0
  ceph_nodes = []
}
