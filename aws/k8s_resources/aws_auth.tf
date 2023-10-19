 #Setting up configmap/aws-auth for app cluster
resource "kubernetes_config_map_v1_data" "app_config_map" {
  provider = kubernetes.app_cluster
  depends_on = [data.aws_eks_cluster.app_eks_cluster]
  force = true
  metadata {
    name = "aws-auth"
    namespace = "kube-system"
  }
  data = {
      mapRoles = yamlencode(distinct(concat(local.app_cluster_map_roles, local.app_cluster_map_roles_list)))
      mapUsers = yamlencode(distinct(concat(local.app_cluster_map_users, local.app_cluster_map_users_list)))
  }
}
#Setting up configmap/aws-auth for blk cluster
resource "kubernetes_config_map" "blk_config_map" {
  provider = kubernetes.blk_cluster
  depends_on = [data.aws_eks_cluster.blk_eks_cluster]
  metadata {
    name = "aws-auth"
    namespace = "kube-system"
    labels = {
      "app.kubernetes.io/managed-by" = "Terraform"
      "terraform.io/module" = "terraform-aws-modules.eks.aws"
    }
  }
  data = {
      mapRoles = yamlencode(distinct(concat(local.blk_cluster_map_roles, local.blk_cluster_map_roles_list)))
      mapUsers = yamlencode(distinct(concat(local.blk_cluster_map_users, local.blk_cluster_map_users_list)))
  }
}
