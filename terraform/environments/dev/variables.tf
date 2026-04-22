terraform {
  required_version = ">= 1.5"
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 5.0"
    }
  }
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

variable "node_boot_volume_size" {
  description = "Tamanho do volume boot em GB"
  type        = number
  default     = 50
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