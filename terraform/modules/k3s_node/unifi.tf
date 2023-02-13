#data "unifi_network" "lan_network" {
#  name = "localcloud"
#}
#
#resource "unifi_user" "static_ip" {
#  mac  = generate_mac
#  name = local.hostname
#
#  fixed_ip   = "10.0.${host_id}.${vmid}"
#  network_id = data.unifi_network.lan_network.id
#}
