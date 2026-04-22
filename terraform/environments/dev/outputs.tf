output "cluster_id" {
  description = "OCID do cluster OKE"
  value       = oci_containerengine_cluster.oke_cluster.id
}

output "cluster_endpoint" {
  description = "Endpoint do cluster OKE"
  value       = oci_containerengine_cluster.oke_cluster.endpoint
}

output "node_pool_id" {
  description = "OCID do node pool"
  value       = oci_containerengine_node_pool.oke_nodepool.id
}

output "vcn_id" {
  description = "OCID da VCN"
  value       = oci_core_vcn.oke_vcn.id
}

output "subnet_id" {
  description = "OCID da subnet"
  value       = oci_core_subnet.oke_subnet.id
}

output "ad_name" {
  description = "Nome do Availability Domain"
  value       = data.oci_identity_availability_domain.oke_ad.name
}