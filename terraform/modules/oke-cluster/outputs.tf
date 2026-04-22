output "cluster_id" {
  description = "OCID do cluster OKE"
  value       = oci_containerengine_cluster.oke_cluster.id
}

output "cluster_endpoint" {
  description = "Endpoint do cluster OKE"
  value       = oci_containerengine_cluster.oke_cluster.endpoints[0].endpoint
}

output "cluster_name" {
  description = "Nome do cluster OKE"
  value       = oci_containerengine_cluster.oke_cluster.name
}