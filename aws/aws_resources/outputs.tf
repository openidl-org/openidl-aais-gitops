#-----------------------------------------------------------------------------------------------------------------
#aws cognito application client outputs
output "cognito_user_pool_id" {
  value     = aws_cognito_user_pool.user_pool.id
  sensitive = true
}
output "cognito_app_client_id" {
  value     = aws_cognito_user_pool_client.cognito_app_client.id
  sensitive = true
}
#-----------------------------------------------------------------------------------------------------------------
#git actions user and baf automation user outputs
output "git_actions_iam_user_arn" {
  value = aws_iam_user.git_actions_user.arn
}
output "baf_automation_user_arn" {
  value = aws_iam_user.baf_user.arn
}
output "hds_iam_user_arn"{
  value = var.org_name == "aais" ? null : aws_iam_user.hds_user[0].arn
}
output "eks_admin_role_arn" {
  value = aws_iam_role.eks_admin_role.arn
}
output "git_actions_admin_role_arn" {
  value = aws_iam_role.git_actions_admin_role.arn
}
#-----------------------------------------------------------------------------------------------------------------
#application cluster (EKS) outputs
output "app_cluster_endpoint" {
  value = module.app_eks_cluster.cluster_endpoint
}
output "app_cluster_name" {
  value = module.app_eks_cluster.cluster_id
}
#output "app_cluster_certificate" {
#  value = module.app_eks_cluster.cluster_certificate_authority_data
#  sensitive = true
#}
#output "app_cluster_token" {
#  value = module.app_eks_cluster.aws_eks_cluster_auth[0].token
#  sensitive = true
#}
output "app_eks_nodegroup_role_arn" {
  value = aws_iam_role.eks_nodegroup_role["app-node-group"].arn
}
#-----------------------------------------------------------------------------------------------------------------
#blockchain cluster (EKS) outputs
output "blk_cluster_endpoint" {
  value = module.blk_eks_cluster.cluster_endpoint
}
output "blk_cluster_name" {
  value = module.blk_eks_cluster.cluster_id
}
#output "blk_cluster_certificate" {
#  value = module.blk_eks_cluster.cluster_certificate_authority_data
#  sensitive = true
#}
#output "blk_cluster_token" {
#  value = module.blk_eks_cluster.aws_eks_cluster_auth[0].token
#  sensitive = true
#}
output "blk_eks_nodegroup_role_arn" {
  value = aws_iam_role.eks_nodegroup_role["blk-node-group"].arn
}
#-----------------------------------------------------------------------------------------------------------------
#cloudtrail related
output "cloudtrail_s3_bucket_name" {
  value = aws_s3_bucket.s3_bucket.bucket
}
output "hds_data_s3_bucket_name" {
  value = var.org_name == "aais" ? null : aws_s3_bucket.s3_bucket_hds[0].bucket
}
#-----------------------------------------------------------------------------------------------------------------
#Route53 entries
output "private_app_bastion_nlb_private_fqdn" {
  value = var.bastion_host_nlb_external ? null : aws_route53_record.private_record_app_nlb_bastion[0].fqdn
}
output "private_blk_bastion_nlb_private_fqdn" {
  value = var.bastion_host_nlb_external ? null : aws_route53_record.private_record_blk_nlb_bastion[0].fqdn
}
output "aws_name_servers" {
  value       = var.domain_info.r53_public_hosted_zone_required == "yes"  ? aws_route53_zone.zones[0].name_servers : null
  description = "The name servers to be updated in the domain registrar"
}
output "public_blk_bastion_fqdn" {
  value = var.domain_info.r53_public_hosted_zone_required == "yes" && var.bastion_host_nlb_external ? aws_route53_record.blk_nlb_bastion_r53_record[0].fqdn : null
}
output "public_app_bastion_fqdn" {
  value = var.domain_info.r53_public_hosted_zone_required == "yes" && var.bastion_host_nlb_external ? aws_route53_record.app_nlb_bastion_r53_record[0].fqdn : null
}
output "bastion_dns_entries_required_to_update" {
  value = var.domain_info.r53_public_hosted_zone_required == "no" && var.aws_env == "prod" && var.bastion_host_nlb_external ? local.dns_entries_list_prod : null
}
output "bastion_dns_entries_required_to_add" {
  value = var.domain_info.r53_public_hosted_zone_required == "no" && var.aws_env != "prod" && var.bastion_host_nlb_external ? local.dns_entries_list_non_prod : null
}
output "public_app_bastion_dns_name" {
  value = var.bastion_host_nlb_external ? module.app_bastion_nlb.lb_dns_name : null
}
output "public_blk_bastion_dns_name" {
  value = var.bastion_host_nlb_external ? module.blk_bastion_nlb.lb_dns_name: null
}
output "r53_public_hosted_zone_id" {
  value = var.domain_info.r53_public_hosted_zone_required == "yes" ? aws_route53_zone.zones[0].zone_id : null
}
output "r53_private_hosted_zone_id"{
  value = aws_route53_zone.aais_private_zones.zone_id
}
output "r53_private_hosted_zone_internal_id" {
  value = aws_route53_zone.aais_private_zones_internal.zone_id
}
#-----------------------------------------------------------------------------------------------------------------
#KMS key related to vault unseal
output "kms_key_arn_vault_unseal_arn" {
  value = aws_kms_key.vault_kms_key.arn
}
output "kms_key_id_vault_unseal_name" {
  value = aws_kms_alias.vault_kms_key_alias.name
}