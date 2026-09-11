output "eks_cluster_name" {
  value = aws_eks_cluster.oficina.name
}

output "eks_cluster_endpoint" {
  value = aws_eks_cluster.oficina.endpoint
}

output "vpc_id" {
  value = aws_vpc.oficina.id
}
