locals {
  coreos = {
    version = var.coreos_version
    host    = "https://builds.coreos.fedoraproject.org"
    arch    = "x86_64"
  }
  gpg_url         = "https://getfedora.org/static/fedora.gpg"
  coreos_filename = "fedora-coreos-${local.coreos.version}-qemu.${local.coreos.arch}.qcow2"
  remote_url      = "${local.coreos.host}/prod/streams/stable/builds/${local.coreos.version}/${local.coreos.arch}/${local.coreos_filename}"
  coreos_volid    = "local:999/${local.coreos_filename}"
}

data "proxmox_node" "node" {
  name = var.node
}

data "template_file" "script" {
  template = file("${path.module}/scripts/download.sh")

  vars = {
    gpg_url    = local.gpg_url
    filename   = local.coreos_filename
    remote_url = local.remote_url
  }
}

data "http" "gpg_keys" {
  url = "https://getfedora.org/static/fedora.gpg"
}

resource "null_resource" "prep_gpg_keys" {
  triggers = {
    content_hash = sha256(data.http.gpg_keys.response_body)
  }
  connection {
    type        = "ssh"
    user        = "root"
    private_key = file(var.private_key_path)
    host        = "10.0.0.10${var.id}"
  }
  provisioner "remote-exec" {
    inline = [
      "mkdir -p .gpg"
    ]
    on_failure = fail
  }
  provisioner "file" {
    content     = data.http.gpg_keys.response_body
    destination = ".gpg/fedora.gpg"
  }
}

resource "null_resource" "download_qcow" {
  triggers = {
    gpg          = local.gpg_url
    path         = local.remote_url
    content_hash = sha256(data.template_file.script.rendered)
  }
  connection {
    type        = "ssh"
    user        = "root"
    private_key = file(var.private_key_path)
    host        = "10.0.0.10${var.id}"
  }
  provisioner "file" {
    content     = data.template_file.script.rendered
    destination = "download.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "sh download.sh",
    ]
    on_failure = fail
  }
  depends_on = [
    null_resource.prep_gpg_keys
  ]
}
