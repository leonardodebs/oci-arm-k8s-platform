variable "cluster_id" {
  description = "OCID do cluster OKE"
  type        = string
}

variable "compartment_ocid" {
  description = "OCID do compartment"
  type        = string
}

variable "node_pool_name" {
  description = "Nome do node pool"
  type        = string
}

variable "kubernetes_version" {
  description = "Versão do Kubernetes"
  type        = string
}

variable "node_image_name" {
  description = "Imagem do nó (Oracle Linux 8 ARM)"
  type        = string
  default     = "Oracle-Linux-8.x-ARM"
}

variable "node_shape" {
  description = "Shape da instância"
  type        = string
  default     = "VM.Standard.A1.Flex"
}

variable "node_ocpus" {
  description = "Quantidade de OCPUs por nó"
  type        = number
  default     = 2
}

variable "node_memory" {
  description = "Memória em GB por nó"
  type        = number
  default     = 12
}

variable "availability_domain" {
  description = "Domínio de disponibilidade"
  type        = string
}

variable "subnet_id" {
  description = "OCID da subnet"
  type        = string
}

variable "node_count" {
  description = "Quantidade de nós"
  type        = number
  default     = 2
}