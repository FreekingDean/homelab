#output "coreos_volid" {
#  value = "local:999/${local.coreos_filename}"
#}

output "cluster_server_ip" {
  value = var.servers > 0 ? "10.0.${var.id}1.101" : ""
}
