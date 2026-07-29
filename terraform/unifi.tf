resource "unifi_network" "talos_network" {
  name    = "TalosNetwork"
  purpose = "corporate"


  subnet  = "10.1.21.1/24"
  vlan_id = 6

  # The dynamic pool deliberately excludes two carved-out ranges:
  #   .10-.100  load balancer VIPs (MetalLB today, Cilium LB-IPAM after the
  #             migration) -- previously inside the pool, so DHCP could hand a
  #             live VIP to a client.
  #   .200-.254 reserved, and covers the Talos control plane VIP on .253.
  # Node fixed-IP reservations (.132-.163, see modules/talos_vm) stay inside the
  # pool and are unaffected.
  dhcp_start   = "10.1.21.101"
  dhcp_stop    = "10.1.21.199"
  dhcp_enabled = true
}
