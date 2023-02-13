module "servers" {
  source = "../../modules/k3s_node"
  count  = var.servers
  id     = count.index + 1

  node    = var.node
  node_id = var.id

  memory = 8 * 1024
  cpus   = 8

  k3s_version    = var.k3s_version
  k3s_subversion = var.k3s_subversion
  k3s_type       = "server"

  ip        = "10.0.${var.id}1.1${format("%02d", count.index + 1)}"
  server_ip = var.cluster_server == "" ? "10.0.${var.id}1.101" : var.cluster_server

  coreos_volid = local.coreos_volid
  storage_name = "etcd-storage"
  storage_size = 16


  github_user = "FreekingDean"
  #password    = "testpass"

  depends_on = [
    null_resource.download_qcow
  ]
}
