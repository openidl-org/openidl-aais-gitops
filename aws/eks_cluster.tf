#application cluster specific
#iam instance profile for worker nodes of application cluster and blockchain cluster (eks)
resource "aws_iam_instance_profile" "eks_instance_profile" {
  for_each = toset(["app-node-group", "blk-node-group"])
  name     = "${local.std_name}-${each.value}-instance-profile"
  role     = aws_iam_role.eks_nodegroup_role["${each.value}"].id
}
#ssh key pair for application cluster worker nodes (eks)
module "app_eks_worker_nodes_key_pair_external" {
  depends_on = [module.aais_app_vpc]
  source     = "terraform-aws-modules/key-pair/aws"
  key_name   = "${local.std_name}-app-eks-worker-nodes-external"
  public_key = var.app_eks_worker_nodes_ssh_key
  tags = merge(
    local.tags,
    {
      "Name"         = "${local.std_name}-app-eks-worker-nodes-external"
      "Cluster_type" = "application"
  }, )
}
#setting up application cluster (eks)
module "app_eks_cluster" {
  providers = {
    kubernetes = kubernetes.app_cluster
  }
  source                                             = "terraform-aws-modules/eks/aws"
  version                                            = "17.1.0"
  create_eks                                         = true
  cluster_name                                       = local.app_cluster_name
  enable_irsa                                        = true
  cluster_version                                    = var.app_cluster_version
  subnets                                            = module.aais_app_vpc.private_subnets
  vpc_id                                             = module.aais_app_vpc.vpc_id
  write_kubeconfig                                   = false
  cluster_service_ipv4_cidr                          = var.app_cluster_service_ipv4_cidr
  kubeconfig_output_path                             = var.kubeconfig_output_path
  cluster_endpoint_private_access                    = var.cluster_endpoint_private_access
  cluster_endpoint_public_access                     = var.cluster_endpoint_public_access
  cluster_create_endpoint_private_access_sg_rule     = true
  cluster_create_security_group                      = false
  cluster_security_group_id                          = module.app_eks_control_plane_sg.security_group_id
  cluster_endpoint_private_access_cidrs              = [var.app_vpc_cidr]
  cluster_endpoint_public_access_cidrs               = var.cluster_endpoint_public_access_cidrs
  cluster_create_timeout                             = var.cluster_create_timeout
  wait_for_cluster_timeout                           = var.wait_for_cluster_timeout
  manage_aws_auth                                    = var.manage_aws_auth
  manage_cluster_iam_resources                       = false
  manage_worker_iam_resources                        = false
  cluster_enabled_log_types                          = var.eks_cluster_logs
  cluster_iam_role_name                              = aws_iam_role.eks_cluster_role["app-eks"].name
  cluster_log_kms_key_id                             = aws_kms_key.eks_kms_key["app-eks"].arn
  cluster_log_retention_in_days                      = 365
  worker_create_security_group                       = false
  worker_security_group_id                           = module.app_eks_worker_node_group_sg.security_group_id
  worker_create_cluster_primary_security_group_rules = true
  map_roles                                          = concat(local.app_cluster_map_roles, local.app_cluster_map_roles_list)
  map_users                                          = local.app_cluster_map_users_list
  cluster_encryption_config = [
    {
      provider_key_arn = aws_kms_key.eks_kms_key["app-eks"].arn
      resources        = ["secrets"]
    }
  ]
  worker_groups = [
    {
      name                          = "${local.std_name}-app-worker-group-1"
      instance_type                 = var.eks_worker_instance_type
      ami_id                        = data.aws_ami.eks_app_worker_nodes_ami.id
      platform                      = "linux"
      additional_userdata           = local.worker_nodes_userdata
      asg_min_size                  = var.wg_asg_min_size
      asg_max_size                  = var.wg_asg_max_size
      asg_desired_capacity          = var.wg_asg_desired_capacity
      security_groups               = module.app_eks_worker_node_group_sg.security_group_id
      additional_security_group_ids = module.app_eks_workers_app_traffic_sg.security_group_id
      public_ip                     = var.eks_wg_public_ip
      root_encrypted                = var.eks_wg_root_vol_encrypted
      root_volume_size              = var.eks_wg_root_volume_size
      root_volume_type              = var.eks_wg_root_volume_type
      key_name                      = module.app_eks_worker_nodes_key_pair_external.key_pair_key_name
      subnet_id                     = module.aais_app_vpc.private_subnets[0]
      target_group_arns             = module.app_eks_nlb.target_group_arns
      health_check_type             = var.eks_wg_health_check_type
      ebs_optimized                 = var.wg_ebs_optimized
      instance_refresh_enabled      = var.wg_instance_refresh_enabled
      enable_monitoring             = true
      iam_instance_profile_name     = aws_iam_instance_profile.eks_instance_profile["app-node-group"].name
    },
    {
      name                          = "${local.std_name}-app-worker-group-2"
      instance_type                 = var.eks_worker_instance_type
      ami_id                        = data.aws_ami.eks_app_worker_nodes_ami.id
      platform                      = "linux"
      additional_userdata           = local.worker_nodes_userdata
      asg_min_size                  = var.wg_asg_min_size
      asg_max_size                  = var.wg_asg_max_size
      asg_desired_capacity          = var.wg_asg_desired_capacity
      security_groups               = module.app_eks_worker_node_group_sg.security_group_id
      additional_security_group_ids = module.app_eks_workers_app_traffic_sg.security_group_id
      public_ip                     = var.eks_wg_public_ip
      root_encrypted                = var.eks_wg_root_vol_encrypted
      root_volume_size              = var.eks_wg_root_volume_size
      root_volume_type              = var.eks_wg_root_volume_type
      key_name                      = module.app_eks_worker_nodes_key_pair_external.key_pair_key_name
      subnet_id                     = module.aais_app_vpc.private_subnets[1]
      target_group_arns             = module.app_eks_nlb.target_group_arns
      health_check_type             = var.eks_wg_health_check_type
      ebs_optimized                 = var.wg_ebs_optimized
      instance_refresh_enabled      = var.wg_instance_refresh_enabled
      enable_monitoring             = true
      iam_instance_profile_name     = aws_iam_instance_profile.eks_instance_profile["app-node-group"].name
  }]

  tags = merge(
    local.tags,
    {
      "Name"         = "${local.app_cluster_name}"
      "Cluster_type" = "application"
  }, )
  depends_on = [module.aais_app_vpc,
    aws_vpc_endpoint.app_eks_asg,
    aws_vpc_endpoint.app_eks_ec2,
    aws_vpc_endpoint.app_eks_ecr_api,
    aws_vpc_endpoint.app_eks_ecr_dkr,
    aws_vpc_endpoint.app_eks_elb,
    aws_vpc_endpoint.app_eks_logs,
    aws_vpc_endpoint.app_eks_s3,
    aws_vpc_endpoint.app_eks_sts,
    module.app_eks_control_plane_sg,
    module.app_eks_worker_node_group_sg,
    aws_iam_role.eks_cluster_role,
    aws_iam_role.eks_nodegroup_role,
    aws_kms_key.eks_kms_key,
    aws_iam_role_policy_attachment.eks_cluster_AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.eks_cluster_AmazonEKSCNIPolicy,
    aws_iam_role_policy_attachment.eks_cluster_AmazonEKSServicePolicy,
    aws_iam_role_policy_attachment.eks_cluster_AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.eks_cluster_AmazonEKSVPCResourceController,
    aws_iam_role_policy_attachment.eks_cluster_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.eks_nodegroup_AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.eks_nodegroup_AmazonEKSCNIPolicy,
    aws_iam_role_policy_attachment.eks_nodegroup_AmazonEKSWorkerNodePolicy,
  aws_iam_instance_profile.eks_instance_profile]
}
#blockchain cluster specific
#ssh key pair for blockchain cluster worker nodes (eks)
module "blk_eks_worker_nodes_key_pair_external" {
  depends_on = [module.aais_blk_vpc]
  source     = "terraform-aws-modules/key-pair/aws"
  key_name   = "${local.std_name}-blk-eks-worker-nodes-external"
  public_key = var.blk_eks_worker_nodes_ssh_key
  tags = merge(
    local.tags,
    {
      "Name"         = "${local.std_name}-blk-eks-worker-nodes-external"
      "Cluster_type" = "blockchain"
  }, )
}
#setting up blockchain cluster (eks)
module "blk_eks_cluster" {
  providers = {
    kubernetes = kubernetes.blk_cluster
  }
  source                                             = "terraform-aws-modules/eks/aws"
  version                                            = "17.1.0"
  create_eks                                         = true
  cluster_name                                       = local.blk_cluster_name
  enable_irsa                                        = true
  cluster_version                                    = var.blk_cluster_version
  subnets                                            = module.aais_blk_vpc.private_subnets
  vpc_id                                             = module.aais_blk_vpc.vpc_id
  write_kubeconfig                                   = false
  cluster_service_ipv4_cidr                          = var.blk_cluster_service_ipv4_cidr
  kubeconfig_output_path                             = var.kubeconfig_output_path
  cluster_endpoint_private_access                    = var.cluster_endpoint_private_access
  cluster_endpoint_public_access                     = var.cluster_endpoint_public_access
  cluster_create_endpoint_private_access_sg_rule     = true
  cluster_create_security_group                      = false
  cluster_security_group_id                          = module.blk_eks_control_plane_sg.security_group_id
  cluster_endpoint_private_access_cidrs              = [var.blk_vpc_cidr]
  cluster_endpoint_public_access_cidrs               = var.cluster_endpoint_public_access_cidrs
  cluster_create_timeout                             = var.cluster_create_timeout
  wait_for_cluster_timeout                           = var.wait_for_cluster_timeout
  manage_aws_auth                                    = var.manage_aws_auth
  manage_cluster_iam_resources                       = false
  manage_worker_iam_resources                        = false
  cluster_enabled_log_types                          = var.eks_cluster_logs
  cluster_iam_role_name                              = aws_iam_role.eks_cluster_role["blk-eks"].name
  cluster_log_kms_key_id                             = aws_kms_key.eks_kms_key["blk-eks"].arn
  cluster_log_retention_in_days                      = 365
  worker_create_security_group                       = false
  worker_security_group_id                           = module.blk_eks_worker_node_group_sg.security_group_id
  worker_create_cluster_primary_security_group_rules = true
  map_roles                                          = concat(local.blk_cluster_map_roles, local.blk_cluster_map_roles_list)
  map_users                                          = local.blk_cluster_map_users_list
  cluster_encryption_config = [
    {
      provider_key_arn = aws_kms_key.eks_kms_key["blk-eks"].arn
      resources        = ["secrets"]
    }
  ]
  worker_groups = [
    {
      name                          = "${local.std_name}-blk-worker-group-1"
      instance_type                 = var.eks_worker_instance_type
      ami_id                        = data.aws_ami.eks_blk_worker_nodes_ami.id
      platform                      = "linux"
      additional_userdata           = local.worker_nodes_userdata
      asg_min_size                  = var.wg_asg_min_size
      asg_max_size                  = var.wg_asg_max_size
      asg_desired_capacity          = var.wg_asg_desired_capacity
      security_groups               = module.blk_eks_worker_node_group_sg.security_group_id
      additional_security_group_ids = module.blk_eks_workers_app_traffic_sg.security_group_id
      public_ip                     = var.eks_wg_public_ip
      root_encrypted                = var.eks_wg_root_vol_encrypted
      root_volume_size              = var.eks_wg_root_volume_size
      root_volume_type              = var.eks_wg_root_volume_type
      key_name                      = module.blk_eks_worker_nodes_key_pair_external.key_pair_key_name
      subnet_id                     = module.aais_blk_vpc.private_subnets[0]
      target_group_arns             = module.blk_eks_nlb.target_group_arns
      health_check_type             = var.eks_wg_health_check_type
      ebs_optimized                 = var.wg_ebs_optimized
      instance_refresh_enabled      = var.wg_instance_refresh_enabled
      enable_monitoring             = true
      iam_instance_profile_name     = aws_iam_instance_profile.eks_instance_profile["blk-node-group"].name
    },
    {
      name                          = "${local.std_name}-blk-worker-group-2"
      instance_type                 = var.eks_worker_instance_type
      ami_id                        = data.aws_ami.eks_blk_worker_nodes_ami.id
      platform                      = "linux"
      additional_userdata           = local.worker_nodes_userdata
      asg_min_size                  = var.wg_asg_min_size
      asg_max_size                  = var.wg_asg_max_size
      asg_desired_capacity          = var.wg_asg_desired_capacity
      security_groups               = module.blk_eks_worker_node_group_sg.security_group_id
      additional_security_group_ids = module.blk_eks_workers_app_traffic_sg.security_group_id
      public_ip                     = var.eks_wg_public_ip
      root_encrypted                = var.eks_wg_root_vol_encrypted
      root_volume_size              = var.eks_wg_root_volume_size
      root_volume_type              = var.eks_wg_root_volume_type
      key_name                      = module.blk_eks_worker_nodes_key_pair_external.key_pair_key_name
      subnet_id                     = module.aais_blk_vpc.private_subnets[1]
      target_group_arns             = module.blk_eks_nlb.target_group_arns
      health_check_type             = var.eks_wg_health_check_type
      ebs_optimized                 = var.wg_ebs_optimized
      instance_refresh_enabled      = var.wg_instance_refresh_enabled
      enable_monitoring             = true
      iam_instance_profile_name     = aws_iam_instance_profile.eks_instance_profile["blk-node-group"].name
  }]

  tags = merge(
    local.tags,
    {
      "Name"         = "${local.app_cluster_name}"
      "Cluster_type" = "blockchain"
  }, )
  depends_on = [module.aais_blk_vpc,
    aws_vpc_endpoint.blk_eks_asg,
    aws_vpc_endpoint.blk_eks_ec2,
    aws_vpc_endpoint.blk_eks_ecr_api,
    aws_vpc_endpoint.blk_eks_ecr_dkr,
    aws_vpc_endpoint.blk_eks_elb,
    aws_vpc_endpoint.blk_eks_logs,
    aws_vpc_endpoint.blk_eks_s3,
    aws_vpc_endpoint.blk_eks_sts,
    module.blk_eks_control_plane_sg,
    module.blk_eks_worker_node_group_sg,
    aws_iam_role.eks_cluster_role,
    aws_iam_role.eks_nodegroup_role,
    aws_kms_key.eks_kms_key,
    aws_iam_role_policy_attachment.eks_cluster_AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.eks_cluster_AmazonEKSCNIPolicy,
    aws_iam_role_policy_attachment.eks_cluster_AmazonEKSServicePolicy,
    aws_iam_role_policy_attachment.eks_cluster_AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.eks_cluster_AmazonEKSVPCResourceController,
    aws_iam_role_policy_attachment.eks_cluster_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.eks_nodegroup_AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.eks_nodegroup_AmazonEKSCNIPolicy,
    aws_iam_role_policy_attachment.eks_nodegroup_AmazonEKSWorkerNodePolicy,
  aws_iam_instance_profile.eks_instance_profile]
}
