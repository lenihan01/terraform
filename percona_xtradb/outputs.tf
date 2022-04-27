# (C) Copyright 2021 Hewlett Packard Enterprise Development LP
output "boot_node_ip" {
  description = "boot node IP"
  value       = [hpegl_vmaas_instance.boot_node.containers[0].ip]
}

output "node1_ip" {
  description = "node1 IP"
  value       = [hpegl_vmaas_instance.node1.containers[0].ip]
}

output "node2_ip" {
  description = "node2 IP"
  value       = [hpegl_vmaas_instance.node2.containers[0].ip]
}
