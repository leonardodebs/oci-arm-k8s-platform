terraform {
  required_version = ">= 1.5"
}

provider "oci" {
  region = var.region
}

variable "region" {
  description = "Região OCI"
  type        = string
  default     = "sa-saopaulo-1"
}

variable "tenancy_ocid" {
  description = "OCID do tenancy"
  type        = string
  sensitive   = true
}

variable "compartment_ocid" {
  description = "OCID do compartment"
  type        = string
}

variable "project_name" {
  description = "Nome do projeto"
  type        = string
  default     = "oci-arm-k8s"
}

variable "environment" {
  description = "Ambiente"
  type        = string
  default     = "dev"
}

variable "oke_version" {
  description = "Versão do Kubernetes para OKE"
  type        = string
  default     = "1.30"
}

variable "node_count" {
  description = "Quantidade de nodes no pool"
  type        = number
  default     = 2
}

variable "node_ocpus" {
  description = "OCPUs por node"
  type        = number
  default     = 2
}

variable "node_memory" {
  description = "Memória GB por node"
  type        = number
  default     = 12
}

variable "ocir_repo" {
  description = "Nome do repositório OCIR"
  type        = string
  default     = "nginx-demo"
}

variable "ssh_public_key" {
  description = "Chave pública SSH para nodes"
  type        = string
}

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

resource "oci_containerengine_node_pool" "oke_nodepool" {
  cluster_id         = oci_containerengine_cluster.oke_cluster.id
  compartment_id     = var.compartment_ocid
  name               = "${var.project_name}-nodepool"
  kubernetes_version = var.oke_version
  node_image_name    = "Oracle-Linux-8.x-ARM"
  node_shape         = "VM.Standard.A1.Flex"

  node_shape_config {
    ocpus         = var.node_ocpus
    memory_in_gbs = var.node_memory
  }
}

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