# EBS CSI Driver: sem ele não existe StorageClass dinâmica no cluster, e o
# Postgres (fiap-tc3-infra-db, StatefulSet com PVC) não consegue provisionar
# volume. Sem IRSA neste ambiente (ver eks.tf): o driver assume a LabRole do
# nó via IMDS (hop-limit 2), que já tem as permissões de EBS necessárias
# (ec2:CreateVolume/AttachVolume/DetachVolume/DeleteVolume).
resource "aws_eks_addon" "ebs_csi_driver" {
  cluster_name = aws_eks_cluster.oficina.name
  addon_name   = "aws-ebs-csi-driver"

  depends_on = [aws_eks_node_group.oficina]
}

resource "kubernetes_storage_class" "gp3" {
  metadata {
    name = "gp3"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }

  storage_provisioner    = "ebs.csi.aws.com"
  reclaim_policy         = "Delete"
  volume_binding_mode    = "WaitForFirstConsumer"
  allow_volume_expansion = true

  parameters = {
    type = "gp3"
  }

  depends_on = [aws_eks_addon.ebs_csi_driver]
}
