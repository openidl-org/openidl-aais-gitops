#Creating public hosted zones
resource "aws_route53_zone" "public_zones" {
  count   = var.domain_info.r53_public_hosted_zone_required == "yes" ? 1 : 0
  name    = lookup(var.domain_info, "domain_name")
  comment = lookup(var.domain_info, "comments", null)
  tags = merge(
    local.tags,
    {
      "name"         = "${var.domain_info.domain_name}"
      "cluster_type" = "both"
  }, )
}
#Setting dns entry for bastion host in the vpc
resource "aws_route53_record" "nlb_bastion_r53_record" {
  count   = var.domain_info.r53_public_hosted_zone_required == "yes" && var.create_bastion_host ? 1 : 0
  zone_id = aws_route53_zone.public_zones[0].id
  name    = "bastion.${var.aws_env}.${local.public_domain}"
  type    = "A"
  ttl     = "300"
  records = [aws_eip.bastion_host_eip[0].public_ip]
  #alias {
  #  name                   = module.bastion_nlb[0].lb_dns_name
  #  zone_id                = module.bastion_nlb[0].lb_zone_id
  #  evaluate_target_health = true
  #}
}
resource "aws_route53_record" "upload_ui" {
  depends_on = [aws_s3_bucket.upload_ui]
  count   = var.domain_info.r53_public_hosted_zone_required == "yes" ? 1 : 0
  name = "${local.std_name}-${var.s3_bucket_name_upload_ui}.${var.aws_env}.${local.public_domain}"
  zone_id = aws_route53_zone.public_zones[0].id
  type = "CNAME"
  ttl = "300"
  records = ["s3-website-${var.aws_region}.amazonaws.com"]
}
