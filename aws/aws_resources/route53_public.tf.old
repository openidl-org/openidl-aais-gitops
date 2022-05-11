#creating public hosted zones
resource "aws_route53_zone" "zones" {
  count   = var.domain_info.r53_public_hosted_zone_required == "yes" ? 1 : 0
  name    = lookup(var.domain_info, "domain_name")
  comment = lookup(var.domain_info, "comments", null)
  tags = merge(
    local.tags,
    {
      "Name"         = "${var.domain_info.domain_name}"
      "Cluster_type" = "Both"
  }, )
}
#setting dns entry for bastion host in app cluster vpc
resource "aws_route53_record" "app_nlb_bastion_r53_record" {
  count   = var.domain_info.r53_public_hosted_zone_required == "yes" && var.bastion_host_nlb_external ? 1 : 0
  zone_id = aws_route53_zone.zones[0].id
  name    = var.aws_env != "prod" ? "app-bastion.${var.aws_env}.${var.domain_info.sub_domain_name}.${aws_route53_zone.zones[0].name}" : "app-bastion.${var.domain_info.sub_domain_name}.${aws_route53_zone.zones[0].name}"
  type    = "A"
  alias {
    name                   = module.app_bastion_nlb.lb_dns_name
    zone_id                = module.app_bastion_nlb.lb_zone_id
    evaluate_target_health = true
  }
}
#setting dns entry for bastion host in blk cluster vpc
resource "aws_route53_record" "blk_nlb_bastion_r53_record" {
  count   = var.domain_info.r53_public_hosted_zone_required == "yes" && var.bastion_host_nlb_external ? 1 : 0
  zone_id = aws_route53_zone.zones[0].id
  name    = var.aws_env != "prod" ? "blk-bastion.${var.aws_env}.${var.domain_info.sub_domain_name}.${aws_route53_zone.zones[0].name}" : "blk-bastion.${var.domain_info.sub_domain_name}.${aws_route53_zone.zones[0].name}"
  type    = "A"
  alias {
    name                   = module.blk_bastion_nlb.lb_dns_name
    zone_id                = module.blk_bastion_nlb.lb_zone_id
    evaluate_target_health = true
  }
}
