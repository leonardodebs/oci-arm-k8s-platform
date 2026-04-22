output "node_pool_id" {
  description = "OCID do node pool"
  value       = oci_containerengine_node_pool.oke_nodepool.id
}

output "node_pool_name" {
  description = "Nome do node pool"
  value       = oci_containerengine_node_pool.oke_nodepool.name
}

output "node_shape" {
  description = "Shape dos nós"
  value       = oci_containerengine_node_pool.oke_nodepool.node_shape
}