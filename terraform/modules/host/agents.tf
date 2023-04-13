module "agents" {
  source  = "../../modules/k3s_node"
  count   = var.agents
  node    = var.node
  id      = count.index + 1 + 20
  node_id = var.id
  memory  = 32 * 1024
  cpus    = 8


  coreos_volid = local.coreos_volid
  storage_name = var.primary_storage
  storage_size = 16

  additional_storages = [
    {
      mount   = "/var/lib/rook"
      size    = 64
      label   = "ROOK_DATA"
      storage = var.primary_storage
    }
  ]

  ip        = "10.0.${var.id}2.1${format("%02d", count.index + 1)}"
  server_ip = var.cluster_server == "" ? "10.0.${var.id}1.101" : var.cluster_server

  k3s_version    = var.k3s_version
  k3s_subversion = var.k3s_subversion
  k3s_type       = "agent"

  github_user = "FreekingDean"
  #password    = "testpass"

  depends_on = [
    null_resource.download_qcow
  ]

  primary_storage = var.primary_storage
}
