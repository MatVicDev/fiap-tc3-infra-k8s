# Publicados para fiap-tc3-infra-db e fiap-tc3-lambda-auth consumirem via
# `data "aws_ssm_parameter"`, evitando remote-state cruzado entre repositórios
# com pipelines/ciclos de vida independentes.
resource "aws_ssm_parameter" "vpc_id" {
  name  = "/fiap-tc3/${var.ambiente}/vpc-id"
  type  = "String"
  value = aws_vpc.oficina.id
}

resource "aws_ssm_parameter" "private_subnet_ids" {
  name  = "/fiap-tc3/${var.ambiente}/private-subnet-ids"
  type  = "String"
  value = join(",", values(aws_subnet.private)[*].id)
}

resource "aws_ssm_parameter" "private_subnets_cidr" {
  name  = "/fiap-tc3/${var.ambiente}/private-subnets-cidr"
  type  = "String"
  value = join(",", values(aws_subnet.private)[*].cidr_block)
}

resource "aws_ssm_parameter" "eks_cluster_name" {
  name  = "/fiap-tc3/${var.ambiente}/eks-cluster-name"
  type  = "String"
  value = aws_eks_cluster.oficina.name
}
