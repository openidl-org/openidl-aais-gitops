#Control plane security group for application cluster (eks)
module "app_eks_control_plane_sg" {
  #for_each = {"app-eks-sg" = "aais_vpc", "blk-eks-sg" = "aais_vpc"}
  source                                                   = "terraform-aws-modules/security-group/aws"
  name                                                     = "${local.std_name}-app-eks-ctrl-plane-sg"
  vpc_id                                                   = var.create_vpc ? module.vpc[0].vpc_id : data.aws_vpc.vpc[0].id
  egress_rules                                             = ["all-all"]
  number_of_computed_ingress_with_source_security_group_id = var.create_bastion_host ? 4 : 2
  computed_ingress_with_source_security_group_id = local.app_eks_control_plane_sg_computed_ingress
  tags = merge(local.tags, {
    name = "${local.std_name}-app-eks-ctrl-plane-sg",
  "cluster_type" = "application" })
}
#Control plane security group for blockchain cluster (eks)
module "blk_eks_control_plane_sg" {
  #for_each = {"app-eks-sg" = "aais_vpc", "blk-eks-sg" = "aais_vpc"}
  source                                                   = "terraform-aws-modules/security-group/aws"
  name                                                     = "${local.std_name}-blk-eks-ctrl-plane-sg"
  vpc_id                                                   = var.create_vpc ? module.vpc[0].vpc_id : data.aws_vpc.vpc[0].id
  egress_rules                                             = ["all-all"]
  number_of_computed_ingress_with_source_security_group_id = var.create_bastion_host ? 4 : 2
  computed_ingress_with_source_security_group_id = local.blk_eks_control_plane_sg_computed_ingress
  tags = merge(local.tags, {
    name = "${local.std_name}-blk-eks-ctrl-plane-sg",
  "cluster_type" = "blockchain" })
}
#Worker nodes security group for application cluster (eks)
module "app_eks_worker_node_group_sg" {
  source                                                   = "terraform-aws-modules/security-group/aws"
  name                                                     = "${local.std_name}-app-eks-worker-node-group-sg"
  vpc_id                                                   = var.create_vpc ? module.vpc[0].vpc_id : data.aws_vpc.vpc[0].id
  ingress_cidr_blocks                                      = var.create_vpc ? [var.vpc_cidr] : [data.aws_vpc.vpc[0].cidr_block]
  ingress_rules                                            = ["ssh-tcp", "https-443-tcp", "http-80-tcp"]
  number_of_computed_ingress_with_source_security_group_id = var.create_bastion_host ? 8 : 7
  egress_rules                                             = ["all-all"]
  computed_ingress_with_source_security_group_id = local.app_eks_worker_node_group_sg_computed_ingress
  tags = merge(local.tags, {
    name                                              = "${local.std_name}-app-eks-worker-node-group-sg"
    "kubernetes.io/cluster/${local.app_cluster_name}" = "owned"
  "cluster_type" = "application" })
}
#Worker nodes security group for blockchain cluster (eks)
module "blk_eks_worker_node_group_sg" {
  source                                                   = "terraform-aws-modules/security-group/aws"
  name                                                     = "${local.std_name}-blk-eks-worker-node-group-sg"
  vpc_id                                                   = var.create_vpc ? module.vpc[0].vpc_id : data.aws_vpc.vpc[0].id
  ingress_cidr_blocks                                      = var.create_vpc ? [var.vpc_cidr] : [data.aws_vpc.vpc[0].cidr_block]
  ingress_rules                                            = ["ssh-tcp", "https-443-tcp", "http-80-tcp"]
  number_of_computed_ingress_with_source_security_group_id = var.create_bastion_host ? 7 : 6
  egress_rules                                             = ["all-all"]
  computed_ingress_with_source_security_group_id = local.blk_eks_worker_node_group_sg_computed_ingress
  tags = merge(local.tags, {
    Nnme                                              = "${local.std_name}-blk-eks-worker-node-group-sg"
    "kubernetes.io/cluster/${local.blk_cluster_name}" = "owned"
  "cluster_type" = "application" })
}
/*
#Application cluster worker nodes additional security group to manage application specific traffic requirements
module "app_eks_workers_app_traffic_sg" {
  depends_on               = [module.vpc]
  source                   = "terraform-aws-modules/security-group/aws"
  name                     = "${local.std_name}-app-eks-workers-app-traffic-sg"
  description              = "Security group associated app eks workers group for app specific traffic"
  vpc_id                   = var.create_vpc ? module.vpc[0].vpc_id : data.aws_vpc.vpc[0].id
  ingress_with_cidr_blocks = var.app_eks_workers_app_sg_ingress
  egress_with_cidr_blocks  = var.app_eks_workers_app_sg_egress
  tags = merge(
    local.tags,
    {
      "cluster_type" = "application"
  }, )
}
#Blockchain cluster worker nodes additional security group to manage application specific traffic requirements
module "blk_eks_workers_app_traffic_sg" {
  depends_on               = [module.vpc]
  source                   = "terraform-aws-modules/security-group/aws"
  name                     = "${local.std_name}-blk-eks-workers-app-traffic-sg"
  description              = "Security group associated blk eks workers group for app specific traffic"
  vpc_id                   = var.create_vpc ? module.vpc[0].vpc_id : data.aws_vpc.vpc[0].id
  ingress_with_cidr_blocks = var.blk_eks_workers_app_sg_ingress
  egress_with_cidr_blocks  = var.blk_eks_workers_app_sg_egress
  tags = merge(
    local.tags,
    {
      "cluster_type" = "blockchain"
  }, )
}
*/