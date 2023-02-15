module "ceph_nodes" {
  source  = "../../modules/k3s_node"
  count   = length(var.ceph_nodes)
  node    = var.node
  id      = count.index + 1 + 80
  node_id = var.id
  memory  = length(var.ceph_nodes[count.index].disks) * 5 * 1024
  cpus    = length(var.ceph_nodes[count.index].disks) * 2


  coreos_volid = local.coreos_volid
  storage_name = "local-thin"
  storage_size = 16

  ip        = "10.0.${var.id}3.1${format("%02d", count.index + 1)}"
  server_ip = var.cluster_server == "" ? "10.0.${var.id}1.101" : var.cluster_server

  k3s_version    = var.k3s_version
  k3s_subversion = var.k3s_subversion
  k3s_type       = "agent"
  hostname_type  = "ceph"
  taints = [
    "CephOSDOnly=true:NoExecute"
  ]

  additional_storages = [
    {
      mount   = "/var/lib/rook"
      size    = 128
      label   = "ROOK_DATA"
      storage = "local-thin"
    }
  ]

  direct_disks = var.ceph_nodes[count.index].disks

  github_user = "FreekingDean"
  #password    = "testpass"

  depends_on = [
    null_resource.download_qcow
  ]
}
