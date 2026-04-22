resource "oci_containerengine_node_pool" "oke_nodepool" {
  cluster_id         = var.cluster_id
  compartment_id     = var.compartment_ocid
  name               = var.node_pool_name
  kubernetes_version = var.kubernetes_version
  node_image_name    = var.node_image_name
  node_shape         = var.node_shape

  node_shape_config {
    ocpus         = var.node_ocpus
    memory_in_gbs = var.node_memory
  }

  node_pool_placement_config {
    availability_domain = var.availability_domain
    subnet_id           = var.subnet_id
  }

  initial_node_labels {
    key   = "node.kubernetes.io/instance-type"
    value = var.node_shape
  }

  node_metadata = {
    role = "worker"
  }
}