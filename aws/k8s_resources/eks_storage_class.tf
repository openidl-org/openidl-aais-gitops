#Storage class for the application cluster
resource "kubernetes_storage_class" "app_storage_class_aws_ebs" {
  provider   = kubernetes.app_cluster
  depends_on = [data.aws_eks_cluster.app_eks_cluster, data.aws_eks_cluster_auth.app_eks_cluster_auth, kubernetes_config_map_v1_data.app_config_map]
  metadata {
    name        = "openidl-sc"
    annotations = { "storageclass.kubernetes.io/is-default-class" = "true" }
  }
  storage_provisioner    = "kubernetes.io/aws-ebs"
  reclaim_policy         = "Retain"
  volume_binding_mode    = "WaitForFirstConsumer"
  allow_volume_expansion = "true"
  parameters = {
    type      = "gp2"
    encrypted = "true"
    fsType    = "ext4"
  }
}
#Storage class for the blockchain cluster
resource "kubernetes_storage_class" "blk_storage_class_aws_ebs" {
  provider   = kubernetes.blk_cluster
  depends_on = [data.aws_eks_cluster.blk_eks_cluster, data.aws_eks_cluster_auth.blk_eks_cluster_auth, kubernetes_config_map_v1_data.blk_config_map]
  metadata {
    name        = "openidl-sc"
    annotations = { "storageclass.kubernetes.io/is-default-class" = "true" }
  }
  storage_provisioner    = "kubernetes.io/aws-ebs"
  reclaim_policy         = "Retain"
  volume_binding_mode    = "WaitForFirstConsumer"
  allow_volume_expansion = "true"
  parameters = {
    type      = "gp2"
    encrypted = "true"
    fsType    = "ext4"
  }
}