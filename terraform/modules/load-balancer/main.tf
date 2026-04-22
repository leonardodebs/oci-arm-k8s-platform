resource "oci_core_subnet" "oke_subnet" {
  compartment_id = var.compartment_id
  vcn_id         = var.vcn_id

  display_name        = "${var.project_name}-oke-subnet"
  cidr_block          = var.subnet_cidr
  availability_domain = var.availability_domain
  security_list_ids   = [var.security_list_id]
}

resource "oci_core_route_table" "this" {
  compartment_id = var.compartment_id
  vcn_id         = var.vcn_id

  display_name = "${var.project_name}-oke-rt"

  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = var.internet_gateway_id
    description       = "Default route to internet"
  }
}

variable "project_name" {
  description = "Nome do projeto"
  type        = string
}

variable "compartment_id" {
  description = "OCID do compartment"
  type        = string
}

variable "vcn_id" {
  description = "OCID da VCN"
  type        = string
}

variable "availability_domain" {
  description = "Domínio de disponibilidade"
  type        = string
}

variable "subnet_cidr" {
  description = "CIDR da subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "route_table_id" {
  description = "OCID da route table"
  type        = string
}

variable "security_list_id" {
  description = "OCID da security list"
  type        = string
}

variable "internet_gateway_id" {
  description = "OCID do internet gateway"
  type        = string
}

output "subnet_id" {
  description = "OCID da subnet criada"
  value       = oci_core_subnet.oke_subnet.id
}