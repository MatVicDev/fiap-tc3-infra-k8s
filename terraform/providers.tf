terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.31"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.14"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }

  # backend "s3" {
  #   bucket         = "fiap-tc3-terraform-state"
  #   key            = "infra-k8s/terraform.tfstate"
  #   region         = "us-east-1"
  #   dynamodb_table = "fiap-tc3-terraform-locks"
  #   encrypt        = true
  # }
}

provider "aws" {
  region = var.aws_region
}

# kubernetes/helm autenticam no cluster recém-criado via token de curta duração
# (aws eks get-token) — não precisa de kubeconfig estático em lugar nenhum.
provider "kubernetes" {
  host                   = aws_eks_cluster.oficina.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.oficina.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.oficina.token
}

provider "helm" {
  kubernetes {
    host                   = aws_eks_cluster.oficina.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.oficina.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.oficina.token
  }
}

data "aws_eks_cluster_auth" "oficina" {
  name = aws_eks_cluster.oficina.name
}
