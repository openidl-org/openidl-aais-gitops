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
  value = var.org_name == "aais" ? "s3 bucket for hds data analytics not applicable for AAIS node" : aws_s3_bucket.s3_bucket_hds[0].bucket
}
output "s3_public_bucket_logos_name" {
  value = var.create_s3_bucket_public ? aws_s3_bucket.s3_bucket_logos_public[0].bucket : "s3 public bucket not opted"
}
#-----------------------------------------------------------------------------------------------------------------
#Route53 entries
output "aws_name_servers" {
  value       = var.domain_info.r53_public_hosted_zone_required == "yes"  ? aws_route53_zone.public_zones[0].name_servers : ["Route53 public hosted zone not opted"]
  description = "The name servers to be updated in the domain registrar"
}
output "public_bastion_fqdn" {
  value = var.domain_info.r53_public_hosted_zone_required == "yes" && var.create_bastion_host ? aws_route53_record.nlb_bastion_r53_record[0].fqdn : null
}
output "bastion_dns_entries_required_to_update" {
  value = var.domain_info.r53_public_hosted_zone_required == "no" && var.aws_env == "prod" && var.create_bastion_host ? local.dns_entries_list_prod : null
}
output "bastion_dns_entries_required_to_add" {
  value = var.domain_info.r53_public_hosted_zone_required == "no" && var.aws_env != "prod" && var.create_bastion_host ? local.dns_entries_list_non_prod : null
}
#output "public_bastion_dns_name" {
#  value = var.create_bastion_host ? module.bastion_nlb[0].lb_dns_name : "bastion hosts opted out"
#}
output "public_ip_bastion_host" {
  value = var.create_bastion_host ? aws_eip.bastion_host_eip[0].public_ip : "bastion hosts not opted"
}
output "r53_public_hosted_zone_id" {
  value = var.domain_info.r53_public_hosted_zone_required == "yes" ? aws_route53_zone.public_zones[0].zone_id : "Route53 public zone opted out"
}
output "r53_private_hosted_zone_id"{
  value = aws_route53_zone.private_zones.zone_id
}
output "r53_private_hosted_zone_internal_id" {
  value = aws_route53_zone.private_zones_internal.zone_id
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
output "config-file-intake" {
  value = local_file.config_intake.content
}
output "config-file-success" {
  value = local_file.config_intake.content
}