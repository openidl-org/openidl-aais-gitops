#Route53 private entries
output "private_data_call_service_fqdn" {
  value = aws_route53_record.private_record_services["data-call-app-service"].fqdn
}
output "private_insurance_manager_service_fqdn" {
  value = aws_route53_record.private_record_services["insurance-data-manager-service"].fqdn
}
output "private_vault_fqdn" {
  value = aws_route53_record.private_record_vault.fqdn
}
output "private_ordererorg_fqdn" {
  value = var.org_name == "aais" ? aws_route53_record.private_record_aais["*.ordererorg"].fqdn : null
}
#output "private_aais-net_fqdn" {
#  value = var.org_name == "aais" ? aws_route53_record.private_record_aais["*.aais-net.aais"].fqdn : null
#}
output "private_common_fqdn" {
  value = aws_route53_record.private_record_common.fqdn
}
#Route53 public entries
output "public_app_ui_url" {
  value = var.domain_info.r53_public_hosted_zone_required == "yes" ? aws_route53_record.app_nlb_r53_record[0].fqdn : null
}
output "public_ordererog_fqdn" {
  value = var.domain_info.r53_public_hosted_zone_required == "yes" && var.org_name == "aais" ? aws_route53_record.public_aais_orderorg_r53_record[0].fqdn : null
}
output "public_common_fqdn" {
  value = var.domain_info.r53_public_hosted_zone_required == "yes" ? aws_route53_record.public_common_r53_record[0].fqdn : null
}
output "public_data_call_service_fqdn" {
  value = var.domain_info.r53_public_hosted_zone_required == "yes" ? aws_route53_record.public_data_call_r53_record[0].fqdn : null
}
output "public_insurance_manager_service_fqdn" {
  value = var.domain_info.r53_public_hosted_zone_required == "yes" ? aws_route53_record.public_insurance_manager_r53_record[0].fqdn : null
}
output "public_utilities_service_fqdn" {
  value = var.domain_info.r53_public_hosted_zone_required == "yes" ? aws_route53_record.public_utilities_service_r53_record[0].fqdn : null
}
output "dns_entries_required_to_update" {
  value = var.domain_info.r53_public_hosted_zone_required == "no" && var.aws_env == "prod" ? local.dns_entries_list_prod : null
}
output "dns_entries_required_to_add" {
  value = var.domain_info.r53_public_hosted_zone_required == "no" && var.aws_env != "prod" ? local.dns_entries_list_non_prod : null
}
#-----------------------------------------------------------------------------------------------------------------
#aws cognito application client outputs
output "cognito_user_pool_id" {
  value     = data.terraform_remote_state.base_setup.outputs.cognito_user_pool_id
  sensitive = true
}
output "cognito_app_client_id" {
  value     = data.terraform_remote_state.base_setup.outputs.cognito_app_client_id
  sensitive = true
}
#-----------------------------------------------------------------------------------------------------------------
#git actions user and baf automation user outputs
output "git_actions_iam_user_arn" {
  value = data.terraform_remote_state.base_setup.outputs.git_actions_iam_user_arn
}
output "baf_automation_user_arn" {
  value = data.terraform_remote_state.base_setup.outputs.baf_automation_user_arn
}
output "eks_admin_role_arn" {
  value = data.terraform_remote_state.base_setup.outputs.eks_admin_role_arn
}
output "git_actions_admin_role_arn" {
  value = data.terraform_remote_state.base_setup.outputs.git_actions_admin_role_arn
}
output "hds_iam_user" {
  value = var.org_name == "aais" ? null : data.terraform_remote_state.base_setup.outputs.hds_iam_user_arn
}
#-----------------------------------------------------------------------------------------------------------------
#application cluster (EKS) outputs
output "app_cluster_endpoint" {
  value = data.terraform_remote_state.base_setup.outputs.app_cluster_endpoint
}
output "app_cluster_name" {
  value = data.terraform_remote_state.base_setup.outputs.app_cluster_name
}
#-----------------------------------------------------------------------------------------------------------------
#blockchain cluster (EKS) outputs
output "blk_cluster_endpoint" {
  value = data.terraform_remote_state.base_setup.outputs.blk_cluster_endpoint
}
output "blk_cluster_name" {
  value = data.terraform_remote_state.base_setup.outputs.blk_cluster_name
}
#-----------------------------------------------------------------------------------------------------------------
#cloudtrail related
output "cloudtrail_s3_bucket_name" {
  value = data.terraform_remote_state.base_setup.outputs.cloudtrail_s3_bucket_name
}
output "hds_data_s3_bucket_name" {
  value = var.org_name == "aais" ? null : data.terraform_remote_state.base_setup.outputs.hds_data_s3_bucket_name
}        
#Route53 entries
output "private_app_bastion_nlb_private_fqdn" {
  value = var.bastion_host_nlb_external ? null : data.terraform_remote_state.base_setup.outputs.private_app_bastion_nlb_private_fqdn
}
output "private_blk_bastion_nlb_private_fqdn" {
  value = var.bastion_host_nlb_external ? null : data.terraform_remote_state.base_setup.outputs.private_blk_bastion_nlb_private_fqdn
}
output "aws_name_servers" {
  value       = var.domain_info.r53_public_hosted_zone_required == "yes"  ? data.terraform_remote_state.base_setup.outputs.aws_name_servers : null
  description = "The name servers to be updated in the domain registrar"
}
output "public_blk_bastion_fqdn" {
  value = var.domain_info.r53_public_hosted_zone_required == "yes" && var.bastion_host_nlb_external ? data.terraform_remote_state.base_setup.outputs.public_blk_bastion_fqdn : null
}
output "public_app_bastion_fqdn" {
  value = var.domain_info.r53_public_hosted_zone_required == "yes" && var.bastion_host_nlb_external ? data.terraform_remote_state.base_setup.outputs.public_app_bastion_fqdn : null
}
output "public_app_bastion_dns_name" {
  value = var.bastion_host_nlb_external ? data.terraform_remote_state.base_setup.outputs.public_app_bastion_dns_name : null
}
output "public_blk_bastion_dns_name" {
  value = var.bastion_host_nlb_external ? data.terraform_remote_state.base_setup.outputs.public_blk_bastion_dns_name : null
}
#-----------------------------------------------------------------------------------------------------------------
#KMS key related to vault unseal
output "kms_key_arn_vault_unseal" {
  value = data.terraform_remote_state.base_setup.outputs.kms_key_arn_vault_unseal_arn
}
output "kms_key_id_vault_unseal" {
  value = data.terraform_remote_state.base_setup.outputs.kms_key_id_vault_unseal_name
}
