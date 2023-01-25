#Setting up ha proxy in app cluster
resource "helm_release" "app_nginx_external" {
  depends_on = [data.aws_eks_cluster.app_eks_cluster, data.aws_eks_cluster_auth.app_eks_cluster_auth, kubernetes_config_map.app_config_map]
  provider = helm.app_cluster
  namespace = "nginx-external"
  create_namespace = true
  cleanup_on_fail = true
  name = "nginx-external"
  chart ="resources/nginx-app-cluster"
  timeout = 900
  force_update = true
  wait = true
  wait_for_jobs = true
  values = ["${file("resources/nginx-app-cluster/values-external.yaml")}"]
}
#Setting up ha proxy in blk cluster
resource "helm_release" "blk_nginx_external" {
  depends_on = [data.aws_eks_cluster.blk_eks_cluster, data.aws_eks_cluster_auth.blk_eks_cluster_auth, kubernetes_config_map.blk_config_map]
  provider = helm.blk_cluster
  namespace = "nginx-external"
  create_namespace = true
  cleanup_on_fail = true
  name = "nginx-external"
  chart ="resources/nginx-blk-cluster"
  timeout = 900
  force_update = true
  wait = true
  wait_for_jobs = true
  values = ["${file("resources/nginx-blk-cluster/values-external.yaml")}"]
}
resource "helm_release" "cert-manager" {
  depends_on = [data.aws_eks_cluster.app_eks_cluster, data.aws_eks_cluster_auth.app_eks_cluster_auth, kubernetes_config_map.app_config_map]
  provider = helm.app_cluster
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = "1.10.0"

  namespace        = "cert-manager"
  create_namespace = true

  #values = [file("cert-manager-values.yaml")]

  set {
    name  = "installCRDs"
    value = "true"
  }

}
/*
#Setting up ha proxy in app cluster
resource "helm_release" "app_nginx_internal" {
  depends_on = [data.aws_eks_cluster.app_eks_cluster, data.aws_eks_cluster_auth.app_eks_cluster_auth, kubernetes_config_map.app_config_map]
  provider = helm.app_cluster
  namespace = "nginx-internal"
  create_namespace = true
  cleanup_on_fail = true
  name = "nginx-internal"
  chart ="resources/nginx-app-cluster"
  timeout = 900
  force_update = true
  wait = true
  wait_for_jobs = true
  values = ["${file("resources/nginx-app-cluster/values-internal.yaml")}"]
}
#Setting up ha proxy in blk cluster
resource "helm_release" "blk_nginx_internal" {
  depends_on = [data.aws_eks_cluster.blk_eks_cluster, data.aws_eks_cluster_auth.blk_eks_cluster_auth, kubernetes_config_map.blk_config_map]
  provider = helm.blk_cluster
  namespace = "nginx-internal"
  create_namespace = true
  cleanup_on_fail = true
  name = "nginx-internal"
  chart ="resources/nginx-blk-cluster"
  timeout = 900
  force_update = true
  wait = true
  wait_for_jobs = true
  values = ["${file("resources/nginx-blk-cluster/values-internal.yaml")}"]
}
*/