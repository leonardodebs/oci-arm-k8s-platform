resource "oci_containerengine_cluster" "oke_cluster" {
  compartment_id     = var.compartment_ocid
  name               = var.cluster_name
  kubernetes_version = var.kubernetes_version
  vcn_id             = var.vcn_id

  cluster_pod_network_options {
    cni_type = "FLANNEL_OVERLAY"
  }

  options {
    service_lb_subnet_ids = [var.subnet_id]
  }
}

resource "oci_containerengine_addon" "oke_addon_vnid" {
  cluster_id = oci_containerengine_cluster.oke_cluster.id
  name       = "oci-vnid"
  config     = jsonencode({})
}