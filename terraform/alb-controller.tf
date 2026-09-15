# AWS Load Balancer Controller: permite que a aplicação principal (fiap-TC1-oficina)
# exponha um Service/Ingress e ganhe automaticamente um ALB gerenciado pela AWS,
# sem depender do NodePort usado no cluster kind local da Fase 2.
#
# Sem IRSA (o Learner Lab não permite criar OIDC provider nem roles IAM
# novas): o controller assume a LabRole do próprio nó via IMDS (hop-limit 2
# configurado no launch template em eks.tf), que já tem as permissões de
# ELB/EC2 necessárias — por isso não há service account/role dedicados aqui.
resource "helm_release" "alb_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"

  set {
    name  = "clusterName"
    value = aws_eks_cluster.oficina.name
  }

  depends_on = [aws_eks_node_group.oficina]
}
