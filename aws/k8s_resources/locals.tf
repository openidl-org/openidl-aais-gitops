#Temporary variables and their manipulation are here
locals {
  std_name          = "${substr(var.org_name,0,4)}-${var.aws_env}"
  app_cluster_name  = "${local.std_name}-${var.app_cluster_name}"
  blk_cluster_name  = "${local.std_name}-${var.blk_cluster_name}"
  policy_arn_prefix = "arn:aws:iam::aws:policy"
  tags = merge(var.custom_tags, {
    application = "openidl"
    environment = var.aws_env
    managed_by  = "terraform"
    node_type   = var.org_name
  })

  #Sub domain specific
  public_domain = "${var.domain_info.sub_domain_name}" == "" ? "${var.domain_info.domain_name}" : "${var.domain_info.sub_domain_name}.${var.domain_info.domain_name}"
  private_domain = "${var.domain_info.sub_domain_name}" == "" ? "${var.aws_env}" : "${var.aws_env}.${var.domain_info.sub_domain_name}"

  #Application cluster (eks) config-map (aws auth) - iam user to map
  ##This is required to remove once BAF IAM role based is enabled fully.
  app_cluster_map_users = [{
    userarn = data.terraform_remote_state.base_setup.outputs.baf_automation_user_arn
    username = "admin"
    groups = ["system:masters"]
  }]

  #Blockchain cluster (eks) config-map (aws auth) - iam user to map
  ##This is required to remove once BAF IAM role based is enabled fully.
  blk_cluster_map_users = [{
    userarn = data.terraform_remote_state.base_setup.outputs.baf_automation_user_arn
    username = "admin"
    groups = ["system:masters"]
  }]
  #Application cluster (eks) config-map (aws auth) - iam roles to map
  app_cluster_map_roles = [
    {
      rolearn  = data.terraform_remote_state.base_setup.outputs.app_eks_nodegroup_role_arn
      username = "system:node:{{EC2PrivateDNSName}}"
      groups = [
        "system:masters",
        "system:nodes",
        "system:bootstrappers"]
  },
  {
      rolearn  = data.terraform_remote_state.base_setup.outputs.eks_admin_role_arn
      username = "admin"
      groups = [
        "system:masters",
        "system:nodes",
        "system:bootstrappers"]
  },
  {
      rolearn  = data.terraform_remote_state.base_setup.outputs.git_actions_admin_role_arn
      username = "admin"
      groups = [
        "system:masters",
        "system:nodes",
        "system:bootstrappers"]
  },
  {
      rolearn  = data.terraform_remote_state.base_setup.outputs.baf_automation_role_arn
      username = "admin"
      groups = [
        "system:masters",
        "system:nodes",
        "system:bootstrappers"]
  }]
  #Blockchain cluster (eks) config-map (aws auth) - iam roles to map
  blk_cluster_map_roles = [
    {
      rolearn  = data.terraform_remote_state.base_setup.outputs.blk_eks_nodegroup_role_arn
      username = "system:node:{{EC2PrivateDNSName}}"
      groups = [
        "system:masters",
        "system:nodes",
        "system:bootstrappers"]
  },
  {
      rolearn  = data.terraform_remote_state.base_setup.outputs.eks_admin_role_arn
      username = "admin"
      groups = [
        "system:masters",
        "system:nodes",
        "system:bootstrappers"]
  },
  {
      rolearn  = data.terraform_remote_state.base_setup.outputs.git_actions_admin_role_arn
      username = "admin"
      groups = [
        "system:masters",
        "system:nodes",
        "system:bootstrappers"]
  },
  {
      rolearn  = data.terraform_remote_state.base_setup.outputs.baf_automation_role_arn
      username = "admin"
      groups = [
        "system:masters",
        "system:nodes",
        "system:bootstrappers"]
  }]
  app_cluster_map_roles_list = [for key in var.app_cluster_map_roles :
    {
      rolearn  = "${key}"
      username = "admin"
      groups   = ["system:masters"]
  }]

  blk_cluster_map_roles_list = [for key in var.blk_cluster_map_roles :
    {
      rolearn  = "${key}"
      username = "admin"
      groups   = ["system:masters"]
  }]

  app_cluster_map_users_list = [for key in var.app_cluster_map_users :
    {
      userarn  = "${key}"
      username = "admin"
      groups   = ["system:masters"]
  }]

  blk_cluster_map_users_list = [for key in var.blk_cluster_map_users :
    {
      userarn  = "${key}"
      username = "admin"
      groups   = ["system:masters"]
  }]
  #DNS entries prepared
  dns_entries_list_non_prod = {
    "openidl.${var.aws_env}.${local.public_domain}" = data.aws_alb.app_nlb_external.dns_name,
    "bastion.${var.aws_env}.${local.public_domain}" = var.create_bastion_host ? data.terraform_remote_state.base_setup.outputs.public_ip_bastion_host : null,
    "*.ordererorg.${var.aws_env}.${local.public_domain}" = data.aws_alb.blk_nlb_external.dns_name,
    "*.${var.org_name}-net.${var.org_name}.${var.aws_env}.${local.public_domain}" = data.aws_alb.blk_nlb_external.dns_name,
    "data-call-app-service.${var.aws_env}.${local.public_domain}" = data.aws_alb.app_nlb_external.dns_name,
    "insurance-data-manager-service.${var.aws_env}.${local.public_domain}" = data.aws_alb.app_nlb_external.dns_name,
    "utilities-service.${var.aws_env}.${local.public_domain}" = data.aws_alb.app_nlb_external.dns_name
  }
  dns_entries_list_prod = {
    "openidl.${local.public_domain}" = data.aws_alb.app_nlb_external.dns_name,
    "bastion.${local.public_domain}" = var.create_bastion_host? data.terraform_remote_state.base_setup.outputs.public_ip_bastion_host : null,
    "*.ordererorg.${local.public_domain}" = data.aws_alb.blk_nlb_external.dns_name,
    "*.${var.org_name}-net.${var.org_name}.${local.public_domain}" = data.aws_alb.blk_nlb_external.dns_name,
    "data-call-app-service.${local.public_domain}" = data.aws_alb.app_nlb_external.dns_name,
    "insurance-data-manager-service.${local.public_domain}" = data.aws_alb.app_nlb_external.dns_name,
    "utilities-service.${local.public_domain}" = data.aws_alb.app_nlb_external.dns_name
  }
}
