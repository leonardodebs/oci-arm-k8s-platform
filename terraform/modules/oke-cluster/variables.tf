variable "compartment_ocid" {
  description = "OCID do compartment"
  type        = string
}

variable "cluster_name" {
  description = "Nome do cluster OKE"
  type        = string
}

variable "kubernetes_version" {
  description = "Versão do Kubernetes"
  type        = string
  default     = "1.30"
}

variable "vcn_id" {
  description = "OCID da VCN"
  type        = string
}

variable "subnet_id" {
  description = "OCID da subnet para Load Balancer"
  type        = string
}