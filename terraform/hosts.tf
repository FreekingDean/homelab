module "enterprise" {
  source = "./modules/host"

  node = "enterprise"
  id   = 1

  coreos_version = local.coreos.version
  k3s_version    = local.k3s.version
  k3s_subversion = local.k3s.subversion

  cluster_server = module.ds9.cluster_server_ip

  servers = 0
  agents  = 3
  ceph_nodes = [
    {
      disks = [
        "/dev/disk/by-path/pci-0000:03:00.0-sas-phy3-lun-0",
        "/dev/disk/by-path/pci-0000:03:00.0-sas-phy0-lun-0",
        "/dev/disk/by-path/pci-0000:03:00.0-sas-phy1-lun-0",
      ]
    }
  ]
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
  agents  = 2
  ceph_nodes = [
    {
      disks = [
        "/dev/disk/by-path/pci-0000:03:00.0-sas-phy7-lun-0"
      ]
    }
  ]
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
  ceph_nodes = [
    {
      disks = [
        "/dev/disk/by-path/pci-0000:05:00.0-sas-exp0x500c04f2efd2d03f-phy31-lun-0",
        "/dev/disk/by-path/pci-0000:05:00.0-sas-exp0x500c04f2efd2d03f-phy33-lun-0"
      ],
    },
  ]
}

locals {
  hosts = [
    module.enterprise,
    module.voyager,
    module.ds9,
  ]
}
