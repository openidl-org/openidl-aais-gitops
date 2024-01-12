#-----------------------------------------------------------------------------------------------------------------
#AWS cognito application client outputs
output "cognito_user_pool_id" {
  value     = var.create_cognito_userpool ? aws_cognito_user_pool.user_pool[0].id : "cognito userpool not opted"
  sensitive = true
}
output "cognito_app_client_id" {
  value     = var.create_cognito_userpool ? aws_cognito_user_pool_client.cognito_app_client[0].id : "cognito userpool not opted"
  sensitive = true
}
output "cognito_app_client_secret" {
  value     = var.create_cognito_userpool ? aws_cognito_user_pool_client.cognito_app_client[0].client_secret : "cognito userpool not opted"
  sensitive = true
}
#-----------------------------------------------------------------------------------------------------------------
#Git actions user and baf automation user outputs
output "git_actions_iam_user_arn" {
  value = aws_iam_user.git_actions_user.arn
}
output "git_actions_admin_role_arn" {
  value = aws_iam_role.git_actions_admin_role.arn
}
output "baf_automation_user_arn" {
  value = aws_iam_user.baf_user.arn
}
output "baf_automation_role_arn" {
  value = aws_iam_role.baf_user_role.arn
}
output "openidl_app_iam_user_arn"{
  value = aws_iam_user.openidl_apps_user.arn
}
output "openidl_app_iam_role_arn" {
  value = aws_iam_role.openidl_apps_iam_role.arn
}
output "eks_admin_user_group_arn" {
  value = aws_iam_group.eks_admin_group.arn
}
output "eks_admin_role_arn" {
  value = aws_iam_role.eks_admin_role.arn
}
#-----------------------------------------------------------------------------------------------------------------
#Application cluster (EKS) outputs
output "app_cluster_endpoint" {
  value = module.app_eks_cluster.cluster_endpoint
}
output "app_cluster_name" {
  value = module.app_eks_cluster.cluster_id
}
output "app_eks_nodegroup_role_arn" {
  value = aws_iam_role.eks_nodegroup_role["app-node-group"].arn
}
#-----------------------------------------------------------------------------------------------------------------
#Blockchain cluster (EKS) outputs
output "blk_cluster_endpoint" {
  value = module.blk_eks_cluster.cluster_endpoint
}
output "blk_cluster_name" {
  value = module.blk_eks_cluster.cluster_id
}
output "blk_eks_nodegroup_role_arn" {
  value = aws_iam_role.eks_nodegroup_role["blk-node-group"].arn
}
#-----------------------------------------------------------------------------------------------------------------
#Cloudtrail related
output "cloudtrail_s3_bucket_name" {
  value = var.create_cloudtrail ? aws_s3_bucket.ct_cw_s3_bucket[0].bucket : "cloudtrail not opted"
}
output "hds_data_s3_bucket_name" {
  value = aws_s3_bucket.s3_bucket_hds.bucket
}
output "s3_public_bucket_logos_name" {
  value = var.create_s3_bucket_public ? aws_s3_bucket.s3_bucket_logos_public[0].bucket : "s3 public bucket not opted"
}
#-----------------------------------------------------------------------------------------------------------------
output "public_ip_bastion_host" {
  value = var.create_bastion_host ? aws_eip.bastion_host_eip[0].public_ip : "bastion hosts not opted"
}
#-----------------------------------------------------------------------------------------------------------------
#KMS key used with hashicorp vault setup
output "vault_kms_key_arn" {
  value = var.create_kms_keys ? aws_kms_key.vault_kms_key[0].arn : "Provision KMS key named ${local.std_name}-vault-kmskey and set access to ${aws_iam_role.git_actions_admin_role.arn}, ${aws_iam_role.eks_nodegroup_role["app-node-group"].arn}, ${aws_iam_role.eks_nodegroup_role["blk-node-group"].arn}, ${var.aws_role_arn}"
  sensitive = true
}
output "vault_kms_key_alias_name" {
  value = var.create_kms_keys ? aws_kms_alias.vault_kms_key_alias[0].name : ""
}
#-----------------------------------------------------------------------------------------------------------------
#KMS key used for AWS secrets
output "secrets_kms_key_arn" {
  value = var.create_kms_keys ? aws_kms_key.sm_kms_key[0].arn : "Provision KMS key named ${local.std_name}-secrets-kms-key and set access to ${aws_iam_role.git_actions_admin_role.arn}, ${var.aws_role_arn}, ${aws_iam_role.openidl_apps_iam_role.arn}, ${aws_iam_role.baf_user_role.arn}"
  sensitive = true
}
output "secrets_kms_key_alias_name" {
  value = var.create_kms_keys ? aws_kms_alias.sm_kms_key_alias[0].name : ""
}
output "dynamodb_arn" {
  value = aws_dynamodb_table.etl.arn
}
output "s3-bucket-idm-loader" {
  value = aws_s3_bucket.etl["idm-loader"].arn
}
output "s3-bucket-intake" {
  value = aws_s3_bucket.etl["intake"].arn
}
output "s3-bucket-failures" {
  value = aws_s3_bucket.etl["failure"].arn
}
#include lambda functions
output "lambda-idm-loader" {
  value = aws_lambda_function.etl_success_processor.arn
}
output "lambda-intake-processor" {
  value = aws_lambda_function.etl_intake_processor.arn
}
# output "upload_ui_s3_website_endpoint" {
#   value = aws_s3_bucket.upload_ui.website_endpoint
# }
# output "s3_static_website_bucket" {
#   value = aws_s3_bucket.upload_ui.arn
# }
# output "api_gateway_endpoint" {
#   value = aws_api_gateway_deployment.upload_v1.invoke_url
# }




