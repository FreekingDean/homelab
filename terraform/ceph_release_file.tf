locals {
  entries_start_text = "## NODE ENTRIES ##"
  entries_end_text   = "## NODE ENTRIES END ##"
  helmrelease_file   = "${path.module}/../kubernetes/apps/rook-ceph/rook-ceph/cluster/helmrelease.yaml"
  existing_file_data = file(local.helmrelease_file)
  first_halfs        = split(local.entries_start_text, local.existing_file_data)
  last_halfs         = split(local.entries_end_text, local.first_halfs[1])
  node_data          = <<TEMPLATEEND
%{~for host in local.hosts}
%{~for node in host.ceph_nodes}
          - name: ${node.hostname}
            devices:
%{~for disk in node.direct_disks}
              - name: ${disk}
%{~endfor~}
%{~endfor~}
%{~endfor}
TEMPLATEEND
}
resource "local_file" "ceph_helmrelease" {
  content         = format("%s%s%s    %s%s", local.first_halfs[0], local.entries_start_text, local.node_data, local.entries_end_text, local.last_halfs[1])
  file_permission = "0644"
  filename        = local.helmrelease_file
}
