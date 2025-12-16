locals {
  cluster_endpoint = "https://${var.talos_control_plane_virtual_ip}:6443"
  control_plane_patch = {
    machine = {
      network = {
        interfaces = [
          {
            deviceSelector = {
              driver = "virtio*"
            }
            dhcp = true
            vip = {
              ip = var.talos_control_plane_virtual_ip
            }
          }
        ]
      }
    }
  }
  common_patch = {
    machine = {
      kubelet = {
        extraArgs = {
          "feature-gates" = "EnvFiles=true"
        }
      }
      kernel = {
        modules = [
          { name = "ceph" },
          { name = "nbd" },
          { name = "rbd" },
        ]
      }
      install = {
        image = "factory.talos.dev/installer/${local.talos_build_id}:${var.talos_version}"
      }
    }
    cluster = {
      controllerManager = {
        extraArgs = {
          "feature-gates" = "EnvFiles=true"
        }
      }
      proxy = {
        extraArgs = {
          "feature-gates" = "EnvFiles=true"
        }
      }
      scheduler = {
        extraArgs = {
          "feature-gates" = "EnvFiles=true"
        }
      }
      apiServer = {
        extraArgs = {
          "feature-gates" = "EnvFiles=true"
        }
      }
      network = {
        podSubnets = [
          var.kubernetes_pod_cidr
        ],
        serviceSubnets = [
          var.kubernetes_service_cidr
        ]
      }
    }
  }
  worker_patches = [
    yamlencode(local.common_patch)
  ]
  control_plane_patches = [
    yamlencode(local.control_plane_patch),
    yamlencode(local.common_patch)
  ]
}

data "talos_machine_configuration" "control_plane" {
  cluster_name     = var.talos_cluster_name
  machine_type     = "controlplane"
  cluster_endpoint = local.cluster_endpoint
  machine_secrets  = var.talos_machine_secrets
}


resource "talos_machine_configuration_apply" "control_plane" {
  count                       = length(module.talos_servers)
  client_configuration        = var.talos_client_configuration
  machine_configuration_input = data.talos_machine_configuration.control_plane.machine_configuration
  node                        = module.talos_servers[count.index].vm_ip
  config_patches              = local.control_plane_patches
}

data "talos_machine_configuration" "worker" {
  cluster_name     = var.talos_cluster_name
  machine_type     = "worker"
  cluster_endpoint = local.cluster_endpoint
  machine_secrets  = var.talos_machine_secrets
}


resource "talos_machine_configuration_apply" "worker" {
  count                       = length(module.talos_workers)
  client_configuration        = var.talos_client_configuration
  machine_configuration_input = data.talos_machine_configuration.worker.machine_configuration
  node                        = module.talos_workers[count.index].vm_ip
  config_patches              = local.worker_patches
}
