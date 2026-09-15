variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "ambiente" {
  description = "homologacao | producao — usado em nomes/tags e no caminho dos parâmetros SSM publicados"
  type        = string
  default     = "homologacao"
}

variable "vpc_cidr" {
  type    = string
  default = "10.20.0.0/16"
}

variable "azs" {
  description = "Duas zonas de disponibilidade — mínimo exigido pelo EKS"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "kubernetes_version" {
  type    = string
  default = "1.30"
}

variable "node_instance_types" {
  type    = list(string)
  default = ["t3.medium"]
}

variable "node_min_size" {
  type    = number
  default = 2
}

variable "node_max_size" {
  type    = number
  default = 5
}

variable "node_desired_size" {
  type    = number
  default = 2
}

variable "datadog_api_key" {
  description = "API key do Datadog — vem de secrets.DATADOG_API_KEY no pipeline, nunca commitada. Vazia desativa o Datadog Agent (helm_release.datadog)."
  type        = string
  sensitive   = true
  default     = ""
}
