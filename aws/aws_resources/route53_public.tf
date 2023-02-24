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
#resource "aws_route53_record" "upload_ui" {
#  depends_on = [aws_s3_bucket.upload_ui]
#  count   = var.domain_info.r53_public_hosted_zone_required == "yes" ? 1 : 0
#  name = "${local.std_name}-${var.s3_bucket_name_upload_ui}.${var.aws_env}.${local.public_domain}"
#  zone_id = aws_route53_zone.public_zones[0].id
#  type = "CNAME"
#  ttl = "300"
#  records = ["s3-website-${var.aws_region}.amazonaws.com"]
#}
#resource "aws_acm_certificate" "upload_ui" {
#  provider          = aws.acm
#  domain_name       = "${local.std_name}-${var.s3_bucket_name_upload_ui}.${var.aws_env}.${local.public_domain}"
#  validation_method = "DNS"
#  lifecycle {
#    create_before_destroy = true
#  }
#}
#resource "aws_route53_record" "certificate_validation_record" {
#  depends_on = [aws_acm_certificate.upload_ui]
#  allow_overwrite = true
#  name            = tolist(aws_acm_certificate.upload_ui.domain_validation_options)[0].resource_record_name
#  records         = [ tolist(aws_acm_certificate.upload_ui.domain_validation_options)[0].resource_record_value ]
#  type            = tolist(aws_acm_certificate.upload_ui.domain_validation_options)[0].resource_record_type
#  zone_id         = aws_route53_zone.public_zones[0].id
#  ttl             = "300"
#}
#resource "aws_acm_certificate_validation" "cert" {
#  provider                = aws.acm
#  certificate_arn         = aws_acm_certificate.upload_ui.arn
#  validation_record_fqdns = [ aws_route53_record.certificate_validation_record.fqdn ]
#}
#resource "aws_route53_record" "upload_ui" {
#  depends_on = [aws_cloudfront_distribution.upload_ui]
#  zone_id = aws_route53_zone.public_zones[0].id
#  name    = "${local.std_name}-${var.s3_bucket_name_upload_ui}.${var.aws_env}.${local.public_domain}"
#  type = "A"
#  alias {
#    name                   = aws_cloudfront_distribution.upload_ui.domain_name
#    zone_id                = aws_cloudfront_distribution.upload_ui.hosted_zone_id
#    evaluate_target_health = false
#  }
#}
