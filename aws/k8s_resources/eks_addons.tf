
resource "aws_eks_addon" "blk_ebs_csi_driver" {
  cluster_name      = local.blk_cluster_name
  addon_name        = "aws-ebs-csi-driver"
  resolve_conflicts = "PRESERVE"
}

resource "aws_eks_addon" "app_ebs_csi_driver" {
  cluster_name      = local.app_cluster_name
  addon_name        = "aws-ebs-csi-driver"
  resolve_conflicts = "PRESERVE"
}