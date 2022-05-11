#application cluster(eks) vpc endpoints
resource "aws_vpc_endpoint" "app_eks_s3" {
  vpc_id       = module.aais_app_vpc.vpc_id
  service_name = "com.amazonaws.${var.aws_region}.s3"
  tags = merge(local.tags, {
    "Name" = "${local.app_cluster_name}-s3-endpoint"
  "Cluster_type" = "application" })
  depends_on = [module.aais_app_vpc]
}
resource "aws_vpc_endpoint_route_table_association" "app_eks_private_s3_route" {
  count           = length(module.aais_app_vpc.private_route_table_ids)
  vpc_endpoint_id = aws_vpc_endpoint.app_eks_s3.id
  route_table_id  = module.aais_app_vpc.private_route_table_ids[count.index]
  depends_on      = [module.aais_app_vpc]
}
resource "aws_vpc_endpoint" "app_eks_ec2" {
  vpc_id              = module.aais_app_vpc.vpc_id
  service_name        = "com.amazonaws.${var.aws_region}.ec2"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [module.app_eks_worker_node_group_sg.security_group_id]
  subnet_ids          = module.aais_app_vpc.private_subnets
  private_dns_enabled = true
  tags = merge(local.tags, {
    "Name" = "${local.app_cluster_name}-ec2-endpoint",
  "Cluster_type" = "application" })
  depends_on = [module.aais_app_vpc]
}
resource "aws_vpc_endpoint" "app_eks_ecr_dkr" {
  vpc_id              = module.aais_app_vpc.vpc_id
  service_name        = "com.amazonaws.${var.aws_region}.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [module.app_eks_worker_node_group_sg.security_group_id]
  subnet_ids          = module.aais_app_vpc.private_subnets
  private_dns_enabled = true
  tags = merge(local.tags, {
    "Name" = "${local.app_cluster_name}-ecr-dkr-endpoint",
  "Cluster_type" = "application" })
  depends_on = [module.aais_app_vpc]
}
resource "aws_vpc_endpoint" "app_eks_elb" {
  vpc_id              = module.aais_app_vpc.vpc_id
  service_name        = "com.amazonaws.${var.aws_region}.elasticloadbalancing"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [module.app_eks_worker_node_group_sg.security_group_id]
  subnet_ids          = module.aais_app_vpc.private_subnets
  private_dns_enabled = true
  tags = merge(local.tags, {
    "Name" = "${local.app_cluster_name}-ec2-elb",
  "Cluster_type" = "application" })
  depends_on = [module.aais_app_vpc]
}
resource "aws_vpc_endpoint" "app_eks_asg" {
  vpc_id              = module.aais_app_vpc.vpc_id
  service_name        = "com.amazonaws.${var.aws_region}.autoscaling"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [module.app_eks_worker_node_group_sg.security_group_id]
  subnet_ids          = module.aais_app_vpc.private_subnets
  private_dns_enabled = true
  tags = merge(local.tags, {
    "Name" = "${local.app_cluster_name}-ec2-asg",
  "Cluster_type" = "application" })
  depends_on = [module.aais_app_vpc]
}
resource "aws_vpc_endpoint" "app_eks_logs" {
  vpc_id              = module.aais_app_vpc.vpc_id
  service_name        = "com.amazonaws.${var.aws_region}.logs"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [module.app_eks_worker_node_group_sg.security_group_id]
  subnet_ids          = module.aais_app_vpc.private_subnets
  private_dns_enabled = true
  tags = merge(local.tags, {
    "Name" = "${local.app_cluster_name}-logs",
  "Cluster_type" = "application" })
  depends_on = [module.aais_app_vpc]
}
resource "aws_vpc_endpoint" "app_eks_sts" {
  vpc_id              = module.aais_app_vpc.vpc_id
  service_name        = "com.amazonaws.${var.aws_region}.sts"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [module.app_eks_worker_node_group_sg.security_group_id]
  subnet_ids          = module.aais_app_vpc.private_subnets
  private_dns_enabled = true
  tags = merge(local.tags, {
    "Name" = "${local.app_cluster_name}-ec2-sts",
  "Cluster_type" = "application" })
  depends_on = [module.aais_app_vpc]
}
resource "aws_vpc_endpoint" "app_eks_ecr_api" {
  vpc_id              = module.aais_app_vpc.vpc_id
  service_name        = "com.amazonaws.${var.aws_region}.ecr.api"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [module.app_eks_worker_node_group_sg.security_group_id]
  subnet_ids          = module.aais_app_vpc.private_subnets
  private_dns_enabled = true
  tags = merge(local.tags, {
    "Name" = "${local.app_cluster_name}-ecr-api",
  "Cluster_type" = "application" })
  depends_on = [module.aais_app_vpc]
}
#blockchain cluster (eks) vpc endpoints
resource "aws_vpc_endpoint" "blk_eks_s3" {
  vpc_id       = module.aais_blk_vpc.vpc_id
  service_name = "com.amazonaws.${var.aws_region}.s3"
  tags = merge(local.tags, {
    "Name" = "${local.blk_cluster_name}-s3-endpoint"
  "Cluster_type" = "blockchain" })
  depends_on = [module.aais_blk_vpc]
}
resource "aws_vpc_endpoint_route_table_association" "blk_eks_private_s3_route" {
  count = length(module.aais_blk_vpc.private_route_table_ids)
  //  count = "2"
  vpc_endpoint_id = aws_vpc_endpoint.blk_eks_s3.id
  route_table_id  = module.aais_blk_vpc.private_route_table_ids[count.index]
  depends_on      = [module.aais_blk_vpc]
}
resource "aws_vpc_endpoint" "blk_eks_ec2" {
  vpc_id              = module.aais_blk_vpc.vpc_id
  service_name        = "com.amazonaws.${var.aws_region}.ec2"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [module.blk_eks_worker_node_group_sg.security_group_id]
  subnet_ids          = module.aais_blk_vpc.private_subnets
  private_dns_enabled = true
  tags = merge(local.tags, {
    "Name" = "${local.blk_cluster_name}-ec2-endpoint",
  "Cluster_type" = "blockchain" })
  depends_on = [module.aais_blk_vpc]
}
resource "aws_vpc_endpoint" "blk_eks_ecr_dkr" {
  vpc_id              = module.aais_blk_vpc.vpc_id
  service_name        = "com.amazonaws.${var.aws_region}.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [module.blk_eks_worker_node_group_sg.security_group_id]
  subnet_ids          = module.aais_blk_vpc.private_subnets
  private_dns_enabled = true
  tags = merge(local.tags, {
    "Name" = "${local.blk_cluster_name}-ecr-dkr-endpoint",
  "Cluster_type" = "blockchain" })
  depends_on = [module.aais_blk_vpc]
}
resource "aws_vpc_endpoint" "blk_eks_elb" {
  vpc_id              = module.aais_blk_vpc.vpc_id
  service_name        = "com.amazonaws.${var.aws_region}.elasticloadbalancing"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [module.blk_eks_worker_node_group_sg.security_group_id]
  subnet_ids          = module.aais_blk_vpc.private_subnets
  private_dns_enabled = true
  tags = merge(local.tags, {
    "Name" = "${local.blk_cluster_name}-ec2-elb",
  "Cluster_type" = "blockchain" })
  depends_on = [module.aais_blk_vpc]
}
resource "aws_vpc_endpoint" "blk_eks_asg" {
  vpc_id              = module.aais_blk_vpc.vpc_id
  service_name        = "com.amazonaws.${var.aws_region}.autoscaling"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [module.blk_eks_worker_node_group_sg.security_group_id]
  subnet_ids          = module.aais_blk_vpc.private_subnets
  private_dns_enabled = true
  tags = merge(local.tags, {
    "Name" = "${local.blk_cluster_name}-ec2-asg",
  "Cluster_type" = "blockchain" })
  depends_on = [module.aais_blk_vpc]
}
resource "aws_vpc_endpoint" "blk_eks_logs" {
  vpc_id              = module.aais_blk_vpc.vpc_id
  service_name        = "com.amazonaws.${var.aws_region}.logs"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [module.blk_eks_worker_node_group_sg.security_group_id]
  subnet_ids          = module.aais_blk_vpc.private_subnets
  private_dns_enabled = true
  tags = merge(local.tags, {
    "Name" = "${local.blk_cluster_name}-logs",
  "Cluster_type" = "blockchain" })
  depends_on = [module.aais_blk_vpc]
}
resource "aws_vpc_endpoint" "blk_eks_sts" {
  vpc_id              = module.aais_blk_vpc.vpc_id
  service_name        = "com.amazonaws.${var.aws_region}.sts"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [module.blk_eks_worker_node_group_sg.security_group_id]
  subnet_ids          = module.aais_blk_vpc.private_subnets
  private_dns_enabled = true
  tags = merge(local.tags, {
    "Name" = "${local.blk_cluster_name}-ec2-sts",
  "Cluster_type" = "blockchain" })
  depends_on = [module.aais_blk_vpc]
}
resource "aws_vpc_endpoint" "blk_eks_ecr_api" {
  vpc_id              = module.aais_blk_vpc.vpc_id
  service_name        = "com.amazonaws.${var.aws_region}.ecr.api"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [module.blk_eks_worker_node_group_sg.security_group_id]
  subnet_ids          = module.aais_blk_vpc.private_subnets
  private_dns_enabled = true
  tags = merge(local.tags, {
    "Name" = "${local.blk_cluster_name}-ecr-api",
  "Cluster_type" = "blockchain" })
  depends_on = [module.aais_blk_vpc]
}
