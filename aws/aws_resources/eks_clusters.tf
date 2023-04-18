#Application cluster specific
#IAM instance profile for worker nodes of application cluster and blockchain cluster (eks)
resource "aws_iam_instance_profile" "eks_instance_profile" {
  for_each = toset(["app-node-group", "blk-node-group"])
  name     = "${local.std_name}-${each.value}-instance-profile"
  role     = aws_iam_role.eks_nodegroup_role["${each.value}"].id
}
#SSH key pair for application cluster worker nodes (eks)
module "app_eks_worker_nodes_key_pair_external" {
  #depends_on = [module.vpc]
  source     = "terraform-aws-modules/key-pair/aws"
  key_name   = "${local.std_name}-app-eks-worker-nodes-external"
  public_key = var.app_eks_worker_nodes_ssh_key
  tags = merge(
    local.tags,
    {
      "name"         = "${local.std_name}-app-eks-worker-nodes-external"
      "cluster_type" = "application"
  }, )
}
#Setting up application cluster (eks)
module "app_eks_cluster" {
  #source                                             = "terraform-aws-modules/eks/aws"
  source                                              = "./modules/eks_cluster"
  #version                                            = "17.1.0"
  create_eks                                         = true
  cluster_name                                       = local.app_cluster_name
  enable_irsa                                        = true
  cluster_version                                    = var.app_cluster_version
  subnets                                            = var.create_vpc ? module.vpc[0].private_subnets : data.aws_subnet_ids.vpc_private_subnets.ids
  vpc_id                                             = var.create_vpc ? module.vpc[0].vpc_id : data.aws_vpc.vpc[0].id
  write_kubeconfig                                   = false
  #cluster_service_ipv4_cidr                          = var.app_cluster_service_ipv4_cidr
  kubeconfig_output_path                             = var.kubeconfig_output_path
  cluster_endpoint_private_access                    = var.cluster_endpoint_private_access
  cluster_endpoint_public_access                     = var.cluster_endpoint_public_access
  cluster_create_endpoint_private_access_sg_rule     = true
  cluster_create_security_group                      = false
  cluster_security_group_id                          = module.app_eks_control_plane_sg.security_group_id
  cluster_endpoint_private_access_cidrs              = var.create_vpc ? [var.vpc_cidr] : [data.aws_vpc.vpc[0].cidr_block]
  cluster_endpoint_public_access_cidrs               = var.cluster_endpoint_public_access_cidrs
  cluster_create_timeout                             = var.cluster_create_timeout
  wait_for_cluster_timeout                           = var.wait_for_cluster_timeout
  manage_aws_auth                                    = var.manage_aws_auth
  manage_cluster_iam_resources                       = false
  manage_worker_iam_resources                        = false
  cluster_enabled_log_types                          = var.eks_cluster_logs
  cluster_iam_role_name                              = aws_iam_role.eks_cluster_role["app-eks"].name
  cluster_log_kms_key_id                             = var.create_kms_keys ? aws_kms_key.eks_kms_key[0].arn : var.eks_kms_key_arn
  cluster_log_retention_in_days                      = var.cw_logs_retention_period
  worker_create_security_group                       = false
  worker_security_group_id                           = module.app_eks_worker_node_group_sg.security_group_id
  worker_additional_security_group_ids               = ["${module.app_eks_worker_node_group_sg.security_group_id}"]
  worker_create_cluster_primary_security_group_rules = true
  #map_roles                                          = concat(local.app_cluster_map_roles, local.app_cluster_map_roles_list)
  #map_users                                          = concat(local.app_cluster_map_users, local.app_cluster_map_users_list)
  cluster_encryption_config = [
    {
      provider_key_arn = var.create_kms_keys ? aws_kms_key.eks_kms_key[0].arn : var.eks_kms_key_arn
      resources        = ["secrets"]
    }
  ]
  
  node_groups = {
    "${local.std_name}-app-worker-node-group-1" = {
      ami_type         = "AL2_x86_64"
      # ami_release_version = var.app_worker_nodes_ami_id == "" ? data.aws_ami.eks_app_worker_nodes_ami.id : var.app_worker_nodes_ami_id
      capacity_type  = "ON_DEMAND"
      create_launch_template = true
      desired_capacity = var.wg_asg_desired_capacity
      disk_size        = var.eks_wg_root_volume_size
      enable_monitoring = true
      public_ip         = var.eks_wg_public_ip
      force_update_version = true
      iam_role_arn     = aws_iam_role.eks_nodegroup_role["app-node-group"].arn
      max_capacity     = var.wg_asg_max_size
      min_capacity     = var.wg_asg_min_size
      name_prefix      = "${local.std_name}-app-worker-node-group-1"
      instance_types = ["${var.app_eks_worker_instance_type}"]
      subnets        = var.create_vpc ? tolist([module.vpc[0].private_subnets[0]]) : tolist([tolist(data.aws_subnet_ids.vpc_private_subnets.ids)[0]])
      version        = var.app_cluster_version
    },
    "${local.std_name}-app-worker-node-group-2" = {
      ami_type         = "AL2_x86_64"
      # ami_release_version = var.app_worker_nodes_ami_id == "" ? data.aws_ami.eks_app_worker_nodes_ami.id : var.app_worker_nodes_ami_id
      capacity_type  = "ON_DEMAND"
      create_launch_template = true
      desired_capacity = var.wg_asg_desired_capacity
      disk_size        = var.eks_wg_root_volume_size
      enable_monitoring = true
      public_ip         = var.eks_wg_public_ip
      force_update_version = true
      iam_role_arn     = aws_iam_role.eks_nodegroup_role["app-node-group"].arn
      max_capacity     = var.wg_asg_max_size
      min_capacity     = var.wg_asg_min_size
      name_prefix      = "${local.std_name}-app-worker-node-group-2"
      instance_types = ["${var.app_eks_worker_instance_type}"]
      subnets        = var.create_vpc ? tolist([module.vpc[0].private_subnets[1]]) : tolist([tolist(data.aws_subnet_ids.vpc_private_subnets.ids)[1]])
      version        = var.app_cluster_version
    }
  }
  tags = merge(
    local.tags,
    {
      "name"         = "${local.app_cluster_name}"
      "cluster_type" = "application"
  }, )
  depends_on = [module.vpc,
    module.app_eks_control_plane_sg,
    module.app_eks_worker_node_group_sg,
    aws_iam_role.eks_cluster_role,
    aws_iam_role.eks_nodegroup_role,
    aws_iam_role.eks_admin_role,
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
resource "aws_eks_addon" "app_eks_cluster_addons" {
  cluster_name      = local.app_cluster_name
  addon_name        = "aws-ebs-csi-driver"
  addon_version     = "v1.17.0-eksbuild.1"
  depends_on = [module.app_eks_cluster]
}
#Blockchain cluster specific
#SSH key pair for blockchain cluster worker nodes (eks)
module "blk_eks_worker_nodes_key_pair_external" {
  #depends_on = [module.vpc]
  source     = "terraform-aws-modules/key-pair/aws"
  key_name   = "${local.std_name}-blk-eks-worker-nodes-external"
  public_key = var.blk_eks_worker_nodes_ssh_key
  tags = merge(
    local.tags,
    {
      "name"         = "${local.std_name}-blk-eks-worker-nodes-external"
      "cluster_type" = "blockchain"
  }, )
}
#Setting up blockchain cluster (eks)
module "blk_eks_cluster" {
  #source                                             = "terraform-aws-modules/eks/aws"
  source                                              = "./modules/eks_cluster"
  #version                                            = "17.1.0"
  create_eks                                         = true
  cluster_name                                       = local.blk_cluster_name
  enable_irsa                                        = true
  cluster_version                                    = var.blk_cluster_version
  subnets                                            = var.create_vpc ? module.vpc[0].private_subnets : data.aws_subnet_ids.vpc_private_subnets.ids
  vpc_id                                             = var.create_vpc ? module.vpc[0].vpc_id : data.aws_vpc.vpc[0].id
  write_kubeconfig                                   = false
  #cluster_service_ipv4_cidr                         = var.blk_cluster_service_ipv4_cidr
  kubeconfig_output_path                             = var.kubeconfig_output_path
  cluster_endpoint_private_access                    = var.cluster_endpoint_private_access
  cluster_endpoint_public_access                     = var.cluster_endpoint_public_access
  cluster_create_endpoint_private_access_sg_rule     = true
  cluster_create_security_group                      = false
  cluster_security_group_id                          = module.blk_eks_control_plane_sg.security_group_id
  cluster_endpoint_private_access_cidrs              = var.create_vpc ? [var.vpc_cidr] : [data.aws_vpc.vpc[0].cidr_block]
  cluster_endpoint_public_access_cidrs               = var.cluster_endpoint_public_access_cidrs
  cluster_create_timeout                             = var.cluster_create_timeout
  wait_for_cluster_timeout                           = var.wait_for_cluster_timeout
  manage_aws_auth                                    = var.manage_aws_auth
  manage_cluster_iam_resources                       = false
  manage_worker_iam_resources                        = false
  cluster_enabled_log_types                          = var.eks_cluster_logs
  cluster_iam_role_name                              = aws_iam_role.eks_cluster_role["blk-eks"].name
  cluster_log_kms_key_id                             = var.create_kms_keys ? aws_kms_key.eks_kms_key[0].arn : var.eks_kms_key_arn
  cluster_log_retention_in_days                      = var.cw_logs_retention_period
  worker_create_security_group                       = false
  worker_security_group_id                           = module.blk_eks_worker_node_group_sg.security_group_id
  worker_additional_security_group_ids               = ["${module.blk_eks_worker_node_group_sg.security_group_id}"]
  worker_create_cluster_primary_security_group_rules = true
  #map_roles                                         = concat(local.blk_cluster_map_roles, local.blk_cluster_map_roles_list)
  #map_users                                         = concat(local.blk_cluster_map_users, local.blk_cluster_map_users_list)
  cluster_encryption_config = [
    {
      provider_key_arn = var.create_kms_keys ? aws_kms_key.eks_kms_key[0].arn : var.eks_kms_key_arn
      resources        = ["secrets"]
    }
  ]
  node_groups = {
    "${local.std_name}-blk-worker-node-group-1" = {
      ami_type         = "AL2_x86_64"
      # ami_release_version = var.blk_worker_nodes_ami_id == "" ? data.aws_ami.eks_blk_worker_nodes_ami.id : var.blk_worker_nodes_ami_id
      capacity_type  = "ON_DEMAND"
      create_launch_template = true
      desired_capacity = var.wg_asg_desired_capacity
      disk_size        = var.eks_wg_root_volume_size
      enable_monitoring = true
      public_ip         = var.eks_wg_public_ip
      force_update_version = true
      iam_role_arn     = aws_iam_role.eks_nodegroup_role["blk-node-group"].arn
      max_capacity     = var.wg_asg_max_size
      min_capacity     = var.wg_asg_min_size
      name_prefix      = "${local.std_name}-blk-worker-node-group-1"
      instance_types = ["${var.blk_eks_worker_instance_type}"]
      subnets        = var.create_vpc ? tolist([module.vpc[0].private_subnets[0]]) : tolist([tolist(data.aws_subnet_ids.vpc_private_subnets.ids)[0]])
      version        = var.blk_cluster_version
    },
    "${local.std_name}-blk-worker-node-group-2" = {
      ami_type         = "AL2_x86_64"
      # ami_release_version = var.blk_worker_nodes_ami_id == "" ? data.aws_ami.eks_blk_worker_nodes_ami.id : var.blk_worker_nodes_ami_id
      capacity_type  = "ON_DEMAND"
      create_launch_template = true
      desired_capacity = var.wg_asg_desired_capacity
      disk_size        = var.eks_wg_root_volume_size
      enable_monitoring = true
      public_ip         = var.eks_wg_public_ip
      force_update_version = true
      iam_role_arn     = aws_iam_role.eks_nodegroup_role["blk-node-group"].arn
      max_capacity     = var.wg_asg_max_size
      min_capacity     = var.wg_asg_min_size
      name_prefix      = "${local.std_name}-blk-worker-node-group-2"
      instance_types = ["${var.blk_eks_worker_instance_type}"]
      subnets        = var.create_vpc ? tolist([module.vpc[0].private_subnets[1]]) : tolist([tolist(data.aws_subnet_ids.vpc_private_subnets.ids)[1]])
      version        = var.blk_cluster_version
    },
    "${local.std_name}-blk-worker-node-group-3" = {
      ami_type         = "AL2_x86_64"
      # ami_release_version = var.blk_worker_nodes_ami_id == "" ? data.aws_ami.eks_blk_worker_nodes_ami.id : var.blk_worker_nodes_ami_id
      capacity_type  = "ON_DEMAND"
      create_launch_template = true
      desired_capacity = var.wg_asg_desired_capacity
      disk_size        = var.eks_wg_root_volume_size
      enable_monitoring = true
      public_ip         = var.eks_wg_public_ip
      force_update_version = true
      iam_role_arn     = aws_iam_role.eks_nodegroup_role["blk-node-group"].arn
      max_capacity     = var.wg_asg_max_size
      min_capacity     = var.wg_asg_min_size
      name_prefix      = "${local.std_name}-blk-worker-node-group-3"
      instance_types = ["${var.blk_eks_worker_instance_type}"]
      subnets        = var.create_vpc ? tolist([module.vpc[0].private_subnets[2]]) : tolist([tolist(data.aws_subnet_ids.vpc_private_subnets.ids)[2]])
      version        = var.blk_cluster_version
    }
  }
  tags = merge(
    local.tags,
    {
      "name"         = "${local.blk_cluster_name}"
      "cluster_type" = "blockchain"
  }, )
  depends_on = [module.vpc,
    module.blk_eks_control_plane_sg,
    module.blk_eks_worker_node_group_sg,
    aws_iam_role.eks_cluster_role,
    aws_iam_role.eks_nodegroup_role,
    aws_iam_role.eks_admin_role,
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
resource "aws_eks_addon" "blk_eks_cluster_addons" {
  cluster_name      = local.blk_cluster_name
  addon_name        = "aws-ebs-csi-driver"
  addon_version     = "v1.17.0-eksbuild.1"
  depends_on = [module.blk_eks_cluster]
}
