resource "unifi_network" "talos_network" {
  name    = "TalosNetwork"
  purpose = "corporate"


  subnet       = "10.1.21.1/24"
  vlan_id      = 6
  dhcp_start   = "10.1.21.1"
  dhcp_stop    = "10.1.21.254"
  dhcp_enabled = true
}
