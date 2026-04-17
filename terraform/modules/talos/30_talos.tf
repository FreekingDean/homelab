locals {
  cluster_endpoint = "https://${var.talos_control_plane_virtual_ip}:6443"

  # Per-VM network patch builder.
  #
  # Both NICs are virtio on vmbr0, distinguished only by VLAN tag:
  #   net0 -> var.vlan_tag       (main k8s network; gateway 10.1.21.1)
  #   net1 -> var.ceph_vlan_tag  (ceph storage network)
  #
  # By default Talos runs DHCP on every interface and each lease installs a
  # default route with metric 1024. The kernel refuses to install two default
  # routes at the same metric, producing the recurring
  #   "error adding route: netlink receive: file exists"
  # log from network.RouteSpecController.
  #
  # Fix: match each NIC by its MAC (already known because Proxmox generates
  # it at VM-create time and we use it for the unifi DHCP reservation). Pin
  # the primary NIC to the normal metric and give the ceph NIC a much higher
  # metric so its default route loses to the primary. kubelet nodeIP is
  # pinned to the primary subnet so kube registers the correct address.
  server_network_patches = [
    for vm in module.talos_servers : yamlencode({
      machine = {
        kubelet = {
          nodeIP = {
            validSubnets = ["10.1.21.0/24"]
          }
        }
        network = {
          interfaces = [
            {
              deviceSelector = { hardwareAddr = lower(vm.primary_mac) }
              dhcp           = true
              dhcpOptions    = { routeMetric = 1024 }
              vip            = { ip = var.talos_control_plane_virtual_ip }
            },
            {
              deviceSelector = { hardwareAddr = lower(vm.ceph_mac) }
              dhcp           = true
              dhcpOptions    = { routeMetric = 4096 }
            },
          ]
        }
      }
    })
  ]
  worker_network_patches = [
    for vm in module.talos_workers : yamlencode({
      machine = {
        kubelet = {
          nodeIP = {
            validSubnets = ["10.1.21.0/24"]
          }
        }
        network = {
          interfaces = [
            {
              deviceSelector = { hardwareAddr = lower(vm.primary_mac) }
              dhcp           = true
              dhcpOptions    = { routeMetric = 1024 }
            },
            {
              deviceSelector = { hardwareAddr = lower(vm.ceph_mac) }
              dhcp           = true
              dhcpOptions    = { routeMetric = 4096 }
            },
          ]
        }
      }
    })
  ]

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
  common_patch_yaml = yamlencode(local.common_patch)
}

data "talos_machine_configuration" "control_plane" {
  cluster_name       = var.talos_cluster_name
  machine_type       = "controlplane"
  cluster_endpoint   = local.cluster_endpoint
  machine_secrets    = var.talos_machine_secrets
  talos_version      = var.talos_version
  kubernetes_version = var.kubernetes_version
}


resource "talos_machine_configuration_apply" "control_plane" {
  count                       = length(module.talos_servers)
  client_configuration        = var.talos_client_configuration
  machine_configuration_input = data.talos_machine_configuration.control_plane.machine_configuration
  node                        = module.talos_servers[count.index].vm_ip
  config_patches = [
    local.server_network_patches[count.index],
    local.common_patch_yaml,
  ]
}

data "talos_machine_configuration" "worker" {
  cluster_name       = var.talos_cluster_name
  machine_type       = "worker"
  cluster_endpoint   = local.cluster_endpoint
  machine_secrets    = var.talos_machine_secrets
  talos_version      = var.talos_version
  kubernetes_version = var.kubernetes_version
}


resource "talos_machine_configuration_apply" "worker" {
  count                       = length(module.talos_workers)
  client_configuration        = var.talos_client_configuration
  machine_configuration_input = data.talos_machine_configuration.worker.machine_configuration
  node                        = module.talos_workers[count.index].vm_ip
  config_patches = [
    local.worker_network_patches[count.index],
    local.common_patch_yaml,
  ]
}
