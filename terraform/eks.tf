# Neste ambiente (AWS Academy Learner Lab) o usuário não tem permissão para
# iam:CreateRole/iam:AttachRolePolicy nem para criar o OIDC provider exigido
# por IRSA — só iam:PassRole para a role pré-existente "LabRole", que já vem
# com AmazonEKSClusterPolicy, AmazonEKSWorkerNodePolicy e
# AmazonEC2ContainerRegistryReadOnly anexadas pelo próprio AWS Academy.
data "aws_iam_role" "lab_role" {
  name = "LabRole"
}

resource "aws_eks_cluster" "oficina" {
  name     = "fiap-tc3-oficina-${var.ambiente}"
  role_arn = data.aws_iam_role.lab_role.arn
  version  = var.kubernetes_version

  vpc_config {
    subnet_ids              = concat(values(aws_subnet.public)[*].id, values(aws_subnet.private)[*].id)
    endpoint_public_access  = true
    endpoint_private_access = true
  }
}

# Sem OIDC provider (IRSA) neste ambiente: pods normalmente não alcançam o
# IMDS do nó (AMIs EKS otimizadas usam hop-limit 1 por padrão). Hop-limit 2
# deixa qualquer pod assumir a LabRole do nó via IMDS — é o substituto de IRSA
# usado pelo AWS Load Balancer Controller (ver alb-controller.tf).
resource "aws_launch_template" "eks_nodes" {
  name_prefix = "fiap-tc3-oficina-${var.ambiente}-"

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      ambiente = var.ambiente
      projeto  = "fiap-tc3-oficina"
    }
  }
}

# Node group gerenciado com autoscaling nativo (min/max) — junto com o HPA já
# configurado no Deployment da aplicação (fiap-TC1-oficina/k8s/06-hpa.yaml), cobre
# escalabilidade tanto de pods quanto de capacidade de nós.
resource "aws_eks_node_group" "oficina" {
  cluster_name    = aws_eks_cluster.oficina.name
  node_group_name = "fiap-tc3-oficina-${var.ambiente}"
  node_role_arn   = data.aws_iam_role.lab_role.arn
  subnet_ids      = values(aws_subnet.private)[*].id
  instance_types  = var.node_instance_types
  # AL2 (o ami_type default) não tem mais AMI válida para clusters recentes;
  # AL2023 é o padrão atual do EKS.
  ami_type = "AL2023_x86_64_STANDARD"

  launch_template {
    id      = aws_launch_template.eks_nodes.id
    version = aws_launch_template.eks_nodes.latest_version
  }

  scaling_config {
    min_size     = var.node_min_size
    max_size     = var.node_max_size
    desired_size = var.node_desired_size
  }

  update_config {
    max_unavailable = 1
  }
}
