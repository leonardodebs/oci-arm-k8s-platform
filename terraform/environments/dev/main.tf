resource "oci_containerengine_cluster" "oke_cluster" {
  compartment_id     = var.compartment_ocid
  name               = "${var.project_name}-${var.environment}"
  kubernetes_version = var.oke_version
  vcn_id             = oci_core_vcn.oke_vcn.id

  cluster_pod_network_options {
    cni_type = "FLANNEL_OVERLAY"
  }

  options {
    service_lb_subnet_ids = [oci_core_subnet.oke_subnet.id]
  }
}

resource "oci_core_vcn" "oke_vcn" {
  compartment_id = var.compartment_ocid
  display_name   = "${var.project_name}-${var.environment}-vcn"
  cidr_blocks    = ["10.0.0.0/16"]
}

resource "oci_core_internet_gateway" "oke_igw" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.oke_vcn.id
  display_name   = "${var.project_name}-igw"
  enabled        = true
}

resource "oci_core_nat_gateway" "oke_nat" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.oke_vcn.id
  display_name   = "${var.project_name}-nat"
}

resource "oci_core_route_table" "oke_rt_public" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.oke_vcn.id
  display_name   = "${var.project_name}-public-rt"

  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.oke_igw.id
  }
}

resource "oci_core_route_table" "oke_rt_private" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.oke_vcn.id
  display_name   = "${var.project_name}-private-rt"

  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_nat_gateway.oke_nat.id
  }
}

resource "oci_core_subnet" "oke_subnet" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.oke_vcn.id
  display_name   = "${var.project_name}-oke-subnet"
  cidr_block     = "10.0.1.0/24"
  route_table_id = oci_core_route_table.oke_rt_public.id
}

resource "oci_core_security_list" "oke_security_list" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.oke_vcn.id
  display_name   = "${var.project_name}-security-list"

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
  }

  ingress_security_rules {
    source   = "0.0.0.0/0"
    protocol = "all"
  }
}

data "oci_core_images" "oracle_linux_arm" {
  compartment_id           = var.compartment_ocid
  operating_system         = "Oracle Linux"
  operating_system_version = "8"
  shape                    = "VM.Standard.A1.Flex"
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

resource "oci_containerengine_node_pool" "oke_nodepool" {
  cluster_id         = oci_containerengine_cluster.oke_cluster.id
  compartment_id     = var.compartment_ocid
  name               = "${var.project_name}-nodepool"
  kubernetes_version = var.oke_version
  node_source_details {
    source_type = "IMAGE"
    image_id    = data.oci_core_images.oracle_linux_arm.images[0].id
  }
  node_shape         = "VM.Standard.A1.Flex"

  node_shape_config {
    ocpus         = var.node_ocpus
    memory_in_gbs = var.node_memory
  }
}
