#Setting up public dns entry for application
resource "aws_route53_record" "app_nlb_r53_record" {
  count   = var.domain_info.r53_public_hosted_zone_required == "yes" ? 1 : 0
  zone_id = data.aws_route53_zone.public_zone[0].zone_id
  name    = var.aws_env != "prod" ? "openidl.${var.aws_env}.${local.public_domain}" : "openidl.${local.public_domain}"
  type    = "A"
  alias {
    name                   = data.aws_alb.app_nlb_external.dns_name
    zone_id                = data.aws_alb.app_nlb_external.zone_id
    evaluate_target_health = true
  }
}
#Setting up public dns entry for ordererorg
resource "aws_route53_record" "public_aais_orderorg_r53_record" {
  count   = var.domain_info.r53_public_hosted_zone_required == "yes" && var.org_name == "aais" ? 1 : 0
  zone_id = data.aws_route53_zone.public_zone[0].zone_id
  name = var.aws_env != "prod" ? "*.ordererorg.${var.aws_env}.${local.public_domain}" : "*.ordererorg.${local.public_domain}"
  type = "A"
  alias {
    name                   = data.aws_alb.blk_nlb_external.dns_name
    zone_id                = data.aws_alb.blk_nlb_external.zone_id
    evaluate_target_health = true
  }
}
#Setting up public dns entry for org-net
resource "aws_route53_record" "public_common_r53_record" {
  count   = var.domain_info.r53_public_hosted_zone_required == "yes" ? 1 : 0
  zone_id = data.aws_route53_zone.public_zone[0].zone_id
  name = var.aws_env != "prod" ? "*.${var.org_name}-net.${var.org_name}.${var.aws_env}.${local.public_domain}" : "*.${var.org_name}-net.${var.org_name}.${local.public_domain}"
  type = "A"
  alias {
    name                   = data.aws_alb.blk_nlb_external.dns_name
    zone_id                = data.aws_alb.blk_nlb_external.zone_id
    evaluate_target_health = true
  }
}
#Setting up public dns entry for data call service
resource "aws_route53_record" "public_data_call_r53_record" {
  count   = var.domain_info.r53_public_hosted_zone_required == "yes" ? 1 : 0
  zone_id = data.aws_route53_zone.public_zone[0].zone_id
  name = var.aws_env != "prod" ? "data-call-app-service.${var.aws_env}.${local.public_domain}" : "data-call-app-service.${local.public_domain}"
  type = "A"
  alias {
    name                   = data.aws_alb.app_nlb_external.dns_name
    zone_id                = data.aws_alb.app_nlb_external.zone_id
    evaluate_target_health = true
  }
}
#Setting up public dns entry for insurance data manager
resource "aws_route53_record" "public_insurance_manager_r53_record" {
  count   = var.domain_info.r53_public_hosted_zone_required == "yes" ? 1 : 0
  zone_id = data.aws_route53_zone.public_zone[0].zone_id
  name = var.aws_env != "prod" ? "insurance-data-manager-service.${var.aws_env}.${local.public_domain}" : "insurance-data-manager-service.${local.public_domain}"
  type = "A"
  alias {
    name                   = data.aws_alb.app_nlb_external.dns_name
    zone_id                = data.aws_alb.app_nlb_external.zone_id
    evaluate_target_health = true
  }
}
#Setting up dns entry for utilities service
resource "aws_route53_record" "public_utilities_service_r53_record" {
  count   = var.domain_info.r53_public_hosted_zone_required == "yes" ? 1 : 0
  zone_id = data.aws_route53_zone.public_zone[0].zone_id
  name = var.aws_env != "prod" ? "utilities-service.${var.aws_env}.${local.public_domain}" : "utilities-service.${local.public_domain}"
  type = "A"
  alias {
    name                   = data.aws_alb.app_nlb_external.dns_name
    zone_id                = data.aws_alb.app_nlb_external.zone_id
    evaluate_target_health = true
  }
}
