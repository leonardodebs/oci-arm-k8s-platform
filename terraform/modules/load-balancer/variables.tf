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