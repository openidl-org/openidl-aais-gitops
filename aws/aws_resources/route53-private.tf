#Creating private hosted zones for internal vpc dns resolution - databases and vault
resource "aws_route53_zone" "private_zones_internal" {
  name    = "internal.${var.domain_info.domain_name}"
  comment = "Private hosted zones for ${local.std_name}"
  vpc {
    vpc_id = var.create_vpc ? module.vpc[0].vpc_id : data.aws_vpc.vpc[0].id
  }
  tags = merge(
    local.tags,
    {
      "name"         = "${local.std_name}-internal.${var.domain_info.domain_name}"
      "cluster_type" = "both"
  },)
}
#Creating private hosted zones for internal vpc dns resolution - others
resource "aws_route53_zone" "private_zones" {
  name    = "${var.aws_env}.${local.private_domain}"
  comment = "Private hosted zones for ${local.std_name}"
  vpc {
    vpc_id = var.create_vpc ? module.vpc[0].vpc_id : data.aws_vpc.vpc[0].id
  }
  tags = merge(
    local.tags,
    {
      "name"         = "${local.std_name}-${var.domain_info.domain_name}"
      "cluster_type" = "both"
  },)
}

