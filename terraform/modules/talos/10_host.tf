locals {
  talos_build_id     = "ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515"
  talos_download_url = "https://factory.talos.dev/image/${local.talos_build_id}/${var.talos_version}/metal-amd64.iso"
}

resource "proxmox_virtual_environment_download_file" "iso" {
  content_type = "iso"
  datastore_id = "local"
  file_name    = "talos-${var.talos_version}-amd64.iso"
  node_name    = var.node
  url          = local.talos_download_url
}
