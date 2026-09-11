resource "aws_vpc" "oficina" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = { Name = "fiap-tc3-oficina-${var.ambiente}" }
}

resource "aws_internet_gateway" "oficina" {
  vpc_id = aws_vpc.oficina.id
  tags   = { Name = "fiap-tc3-oficina-${var.ambiente}" }
}

resource "aws_subnet" "public" {
  for_each = { for idx, az in var.azs : az => idx }

  vpc_id                  = aws_vpc.oficina.id
  availability_zone       = each.key
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, each.value)
  map_public_ip_on_launch = true

  tags = {
    Name                     = "fiap-tc3-oficina-${var.ambiente}-public-${each.key}"
    "kubernetes.io/role/elb" = "1"
  }
}

resource "aws_subnet" "private" {
  for_each = { for idx, az in var.azs : az => idx }

  vpc_id            = aws_vpc.oficina.id
  availability_zone = each.key
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, each.value + 100)

  tags = {
    Name                              = "fiap-tc3-oficina-${var.ambiente}-private-${each.key}"
    "kubernetes.io/role/internal-elb" = "1"
  }
}

resource "aws_eip" "nat" {
  domain = "vpc"
}

# Um único NAT Gateway para as duas AZs: reduz custo, aceitável para o escopo do
# desafio (produção real teria um NAT por AZ para não perder saída à internet se
# a AZ do NAT cair).
resource "aws_nat_gateway" "oficina" {
  allocation_id = aws_eip.nat.id
  subnet_id     = values(aws_subnet.public)[0].id
  tags          = { Name = "fiap-tc3-oficina-${var.ambiente}" }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.oficina.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.oficina.id
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.oficina.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.oficina.id
  }
}

resource "aws_route_table_association" "public" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  for_each       = aws_subnet.private
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}
