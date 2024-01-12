
#-----------------------------------------------------------------------------------------------------------------
#AWS cognito application client outputs
output "cognito_user_pool_id" {
  value     = var.create_cognito_userpool ? data.terraform_remote_state.base_setup.outputs.cognito_user_pool_id : null
  sensitive = true
}
output "cognito_app_client_id" {
  value     = var.create_cognito_userpool ? data.terraform_remote_state.base_setup.outputs.cognito_app_client_id : null
  sensitive = true
}
output "cognito_app_client_secret" {
  value     = var.create_cognito_userpool ? data.terraform_remote_state.base_setup.outputs.cognito_app_client_secret : null
  sensitive = true
}
#-----------------------------------------------------------------------------------------------------------------
#IAM user ARN outputs
output "git_actions_user_arn" {
  value = data.terraform_remote_state.base_setup.outputs.git_actions_iam_user_arn
}
output "git_actions_admin_role_arn" {
  value = data.terraform_remote_state.base_setup.outputs.git_actions_admin_role_arn
}
output "baf_automation_user_arn" {
  value = data.terraform_remote_state.base_setup.outputs.baf_automation_user_arn
}
output "baf_automation_role_arn" {
  value = data.terraform_remote_state.base_setup.outputs.baf_automation_role_arn
}
output "openidl_app_user_arn" {
  value = data.terraform_remote_state.base_setup.outputs.openidl_app_iam_user_arn
}
output "openidl_app_role_arn" {
  value = data.terraform_remote_state.base_setup.outputs.openidl_app_iam_role_arn
}
output "eks_admin_user_group_arn" {
  value = data.terraform_remote_state.base_setup.outputs.eks_admin_user_group_arn
}
output "eks_admin_role_arn" {
  value = data.terraform_remote_state.base_setup.outputs.eks_admin_role_arn
}
#-----------------------------------------------------------------------------------------------------------------
#Application cluster (EKS) outputs
output "app_cluster_endpoint" {
  value = data.terraform_remote_state.base_setup.outputs.app_cluster_endpoint
}
output "app_cluster_name" {
  value = data.terraform_remote_state.base_setup.outputs.app_cluster_name
}
#-----------------------------------------------------------------------------------------------------------------
#Blockchain cluster (EKS) outputs
output "blk_cluster_endpoint" {
  value = data.terraform_remote_state.base_setup.outputs.blk_cluster_endpoint
}
output "blk_cluster_name" {
  value = data.terraform_remote_state.base_setup.outputs.blk_cluster_name
}
#-----------------------------------------------------------------------------------------------------------------
#Cloudtrail related
output "cloudtrail_s3_bucket_name" {
  value = var.create_cloudtrial ? data.terraform_remote_state.base_setup.outputs.cloudtrail_s3_bucket_name : null
}
output "hds_data_s3_bucket_name" {
  value = var.org_name == "aais" ? null : data.terraform_remote_state.base_setup.outputs.hds_data_s3_bucket_name
}
output "s3_public_bucket_logos" {
  value = var.create_s3_bucket_public ? data.terraform_remote_state.base_setup.outputs.s3_public_bucket_logos_name : null
}
#-----------------------------------------------------------------------------------------------------------------
#KMS key related to vault unseal
output "vault_kms_key_arn" {
  value = data.terraform_remote_state.base_setup.outputs.vault_kms_key_arn
}
output "vault_kms_key_alais_name" {
  value = data.terraform_remote_state.base_setup.outputs.vault_kms_key_alias_name
}
#-----------------------------------------------------------------------------------------------------------------
#KMS key related to AWS secrets
output "secrets_kms_key_arn" {
  value = data.terraform_remote_state.base_setup.outputs.secrets_kms_key_arn
}
output "secrets_kms_key_alais_name" {
  value = data.terraform_remote_state.base_setup.outputs.secrets_kms_key_alias_name
}
