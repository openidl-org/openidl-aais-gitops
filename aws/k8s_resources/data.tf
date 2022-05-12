#Active below code snippet when terraform uses S3 as backend
/*
data "terraform_remote_state" "base_setup" {
  backend = "s3"
  config = {
    bucket               = var.terraform_state_s3_bucket_name
    key                  = "aws/terraform.tfstate"
    region               = var.aws_region
   }
}
*/
#Active below code snippet when terraform uses TFC/TFE as environment
data "terraform_remote_state" "base_setup" {
  backend = "remote"
  config = {
    organization = var.tfc_org_name
    workspaces = {
      name = var.tfc_workspace_name_aws_resources
    }
  }
}
#-------------------------------------------------------------------------------------------------------------------
#The following code remains same irrespective of backend
#Reading NLB setup by ingress controller deployed in app EKS

data aws_alb "app_nlb_external" {
  tags = {
    "kubernetes.io/cluster/${local.app_cluster_name}" = "owned",
    #"kubernetes.io/service-name" = "nginx/nginx-ingress-ingress-nginx-nginx"
    "kubernetes.io/service-name" = "ingress-controller/haproxy-ingress"
  }
  depends_on = [helm_release.app_haproxy]
}
data aws_alb "app_nlb_internal" {
  tags = {
    "kubernetes.io/cluster/${local.app_cluster_name}" = "owned",
    #"kubernetes.io/service-name" = "nginx/nginx-ingress-ingress-nginx-nginx-internal"
    "kubernetes.io/service-name" = "ingress-controller/haproxy-ingress"
  }
  depends_on = [helm_release.app_haproxy]
}
#Reading NLB setup by ingress controller deployed in blk EKS
data aws_alb "blk_nlb_external" {
  tags = {
    "kubernetes.io/cluster/${local.blk_cluster_name}" = "owned",
    #"kubernetes.io/service-name" = "nginx/nginx-ingress-ingress-nginx-nginx"
    "kubernetes.io/service-name" = "ingress-controller/haproxy-ingress"
  }
  depends_on = [helm_release.blk_haproxy]
}
data aws_alb "blk_nlb_internal" {
  tags = {
    "kubernetes.io/cluster/${local.blk_cluster_name}" = "owned",
    #"kubernetes.io/service-name" = "nginx/nginx-ingress-ingress-nginx-nginx-internal"
    "kubernetes.io/service-name" = "ingress-controller/haproxy-ingress"
  }
  depends_on = [helm_release.blk_haproxy]
}
#Reading application cluster info
data "aws_eks_cluster" "app_eks_cluster" {
  name = data.terraform_remote_state.base_setup.outputs.app_cluster_name
}
data "aws_eks_cluster_auth" "app_eks_cluster_auth" {
  depends_on = [data.aws_eks_cluster.app_eks_cluster]
  name       = data.terraform_remote_state.base_setup.outputs.app_cluster_name
}
#Reading blockchain cluster info
data "aws_eks_cluster" "blk_eks_cluster" {
  name = data.terraform_remote_state.base_setup.outputs.blk_cluster_name
}
data "aws_eks_cluster_auth" "blk_eks_cluster_auth" {
  depends_on = [data.aws_eks_cluster.blk_eks_cluster]
  name       = data.terraform_remote_state.base_setup.outputs.blk_cluster_name
}
#Reading public hosted zone info
data aws_route53_zone "public_zone" {
  count = var.domain_info.r53_public_hosted_zone_required == "yes" ? 1 : 0
  zone_id = data.terraform_remote_state.base_setup.outputs.r53_public_hosted_zone_id
}
#Reading private hosted zone info
data aws_route53_zone "private_zone_internal" {
  zone_id = data.terraform_remote_state.base_setup.outputs.r53_private_hosted_zone_internal_id
}
data aws_route53_zone "private_zone" {
  zone_id = data.terraform_remote_state.base_setup.outputs.r53_private_hosted_zone_id
}
