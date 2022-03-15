#VPC endpoints for EKS cluster when it is set to be private cluster
resource "aws_vpc_endpoint" "eks_s3" {
  count =  var.cluster_endpoint_public_access == false ? 1 : 0
  vpc_id       = var.create_vpc ? module.vpc[0].vpc_id : data.aws_vpc.vpc[0].id
  service_name = "com.amazonaws.${var.aws_region}.s3"
  tags = merge(local.tags, {
    "name" = "${local.std_name}-s3-endpoint"
    "cluster_type" = "both" })
  depends_on = [module.vpc]
}
resource "aws_vpc_endpoint_route_table_association" "eks_private_s3_route" {
  count           = var.cluster_endpoint_public_access == false ? local.count : 0
  vpc_endpoint_id = aws_vpc_endpoint.eks_s3[0].id
  route_table_id  = var.create_vpc ? module.vpc[0].private_route_table_ids[count.index] : tolist(data.aws_route_tables.vpc_private_rt[0].ids)[count.index]
  depends_on      = [module.vpc]
}
resource "aws_vpc_endpoint" "eks_ec2" {
  count =  var.cluster_endpoint_public_access == false ? 1 : 0
  vpc_id              = var.create_vpc ? module.vpc[0].vpc_id : data.aws_vpc.vpc[0].id
  service_name        = "com.amazonaws.${var.aws_region}.ec2"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [module.app_eks_worker_node_group_sg.security_group_id, module.blk_eks_worker_node_group_sg.security_group_id]
  subnet_ids          = var.create_vpc ? module.vpc[0].private_subnets : data.aws_subnet_ids.vpc_private_subnets.ids
  private_dns_enabled = true
  tags = merge(local.tags, {
    "name" = "${local.std_name}-ec2-endpoint",
    "cluster_type" = "both" })
  depends_on = [module.vpc]
}
resource "aws_vpc_endpoint" "eks_ecr_dkr" {
  count =  var.cluster_endpoint_public_access == false ? 1 : 0
  vpc_id              = var.create_vpc ? module.vpc[0].vpc_id : data.aws_vpc.vpc[0].id
  service_name        = "com.amazonaws.${var.aws_region}.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [module.app_eks_worker_node_group_sg.security_group_id, module.blk_eks_worker_node_group_sg.security_group_id]
  subnet_ids          = var.create_vpc ? module.vpc[0].private_subnets : data.aws_subnet_ids.vpc_private_subnets.ids
  private_dns_enabled = true
  tags = merge(local.tags, {
    "name" = "${local.std_name}-ecr-dkr-endpoint",
    "cluster_type" = "both" })
  depends_on = [module.vpc]
}
resource "aws_vpc_endpoint" "eks_elb" {
  count =  var.cluster_endpoint_public_access == false ? 1 : 0
  vpc_id              = var.create_vpc ? module.vpc[0].vpc_id : data.aws_vpc.vpc[0].id
  service_name        = "com.amazonaws.${var.aws_region}.elasticloadbalancing"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [module.app_eks_worker_node_group_sg.security_group_id, module.blk_eks_worker_node_group_sg.security_group_id]
  subnet_ids          = var.create_vpc ? module.vpc[0].private_subnets : data.aws_subnet_ids.vpc_private_subnets.ids
  private_dns_enabled = true
  tags = merge(local.tags, {
    "name" = "${local.std_name}-ec2-elb",
    "cluster_type" = "both" })
  depends_on = [module.vpc]
}
resource "aws_vpc_endpoint" "eks_asg" {
  count =  var.cluster_endpoint_public_access == false ? 1 : 0
  vpc_id              = var.create_vpc ? module.vpc[0].vpc_id : data.aws_vpc.vpc[0].id
  service_name        = "com.amazonaws.${var.aws_region}.autoscaling"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [module.app_eks_worker_node_group_sg.security_group_id, module.blk_eks_worker_node_group_sg.security_group_id]
  subnet_ids          = var.create_vpc ? module.vpc[0].private_subnets : data.aws_subnet_ids.vpc_private_subnets.ids
  private_dns_enabled = true
  tags = merge(local.tags, {
    "name" = "${local.std_name}-ec2-asg",
    "cluster_type" = "both" })
  depends_on = [module.vpc]
}
resource "aws_vpc_endpoint" "eks_logs" {
  count =  var.cluster_endpoint_public_access == false ? 1 : 0
  vpc_id              = var.create_vpc ? module.vpc[0].vpc_id : data.aws_vpc.vpc[0].id
  service_name        = "com.amazonaws.${var.aws_region}.logs"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [module.app_eks_worker_node_group_sg.security_group_id, module.blk_eks_worker_node_group_sg.security_group_id]
  subnet_ids          = var.create_vpc ? module.vpc[0].private_subnets : data.aws_subnet_ids.vpc_private_subnets.ids
  private_dns_enabled = true
  tags = merge(local.tags, {
    "name" = "${local.std_name}-logs",
    "cluster_type" = "both" })
  depends_on = [module.vpc]
}
resource "aws_vpc_endpoint" "eks_sts" {
  count =  var.cluster_endpoint_public_access == false ? 1 : 0
  vpc_id              = var.create_vpc ? module.vpc[0].vpc_id : data.aws_vpc.vpc[0].id
  service_name        = "com.amazonaws.${var.aws_region}.sts"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [module.app_eks_worker_node_group_sg.security_group_id, module.blk_eks_worker_node_group_sg.security_group_id]
  subnet_ids          = var.create_vpc ? module.vpc[0].private_subnets : data.aws_subnet_ids.vpc_private_subnets.ids
  private_dns_enabled = true
  tags = merge(local.tags, {
    "name" = "${local.std_name}-ec2-sts",
    "cluster_type" = "both" })
  depends_on = [module.vpc]
}
resource "aws_vpc_endpoint" "eks_ecr_api" {
  count =  var.cluster_endpoint_public_access == false ? 1 : 0
  vpc_id              = var.create_vpc ? module.vpc[0].vpc_id : data.aws_vpc.vpc[0].id
  service_name        = "com.amazonaws.${var.aws_region}.ecr.api"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [module.app_eks_worker_node_group_sg.security_group_id, module.blk_eks_worker_node_group_sg.security_group_id]
  subnet_ids          = var.create_vpc ? module.vpc[0].private_subnets : data.aws_subnet_ids.vpc_private_subnets.ids
  private_dns_enabled = true
  tags = merge(local.tags, {
    "name" = "${local.std_name}-ecr-api",
    "cluster_type" = "both" })
  depends_on = [module.vpc]
}
