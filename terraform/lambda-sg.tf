# Security group da Lambda de autenticação (fiap-tc3-lambda-auth) — criado aqui
# porque é um recurso de rede, e este repositório já é o dono da VPC. Publicado
# via SSM para o repositório da Lambda consumir.
resource "aws_security_group" "lambda_auth" {
  name        = "fiap-tc3-lambda-auth-${var.ambiente}"
  description = "Egress da Lambda de autenticação por CPF (RDS + Secrets Manager via NAT)"
  vpc_id      = aws_vpc.oficina.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ssm_parameter" "lambda_security_group_id" {
  name  = "/fiap-tc3/${var.ambiente}/lambda-security-group-id"
  type  = "String"
  value = aws_security_group.lambda_auth.id
}
