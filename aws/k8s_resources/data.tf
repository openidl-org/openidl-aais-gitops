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
