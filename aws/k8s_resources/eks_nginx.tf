#Setting up ha proxy in app cluster
/*
resource "helm_release" "app_nginx" {
  depends_on = [data.aws_eks_cluster.app_eks_cluster, data.aws_eks_cluster_auth.app_eks_cluster_auth, kubernetes_config_map.app_config_map]
  provider = helm.app_cluster
  namespace = "nginx"
  create_namespace = true
  cleanup_on_fail = true
  name = "nginx-ingress"
  chart ="resources/nginx-app-cluster"
  timeout = 900
  force_update = true
  wait = true
  wait_for_jobs = true
  values = ["${file("resources/nginx-app-cluster/values.yaml")}"]
}
#Setting up ha proxy in blk cluster
resource "helm_release" "blk_nginx" {
  depends_on = [data.aws_eks_cluster.blk_eks_cluster, data.aws_eks_cluster_auth.blk_eks_cluster_auth, kubernetes_config_map.blk_config_map]
  provider = helm.blk_cluster
  namespace = "nginx"
  create_namespace = true
  cleanup_on_fail = true
  name = "nginx-ingress"
  chart ="resources/nginx-blk-cluster"
  timeout = 900
  force_update = true
  wait = true
  wait_for_jobs = true
  values = ["${file("resources/nginx-blk-cluster/values.yaml")}"]
}*/
