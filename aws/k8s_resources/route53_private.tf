#Setting up private dns entries for data call and insurance data manager services
resource "aws_route53_record" "private_record_services_internal" {
  for_each = toset(["data-call-app-service", "insurance-data-manager-service"])
  zone_id = data.aws_route53_zone.private_zone_internal.zone_id
  name = "${each.value}.${local.private_domain}"
  type    = "A"
  alias {
    name                   = data.aws_alb.app_nlb_external.dns_name
    zone_id                = data.aws_alb.app_nlb_external.zone_id
    evaluate_target_health = true
  }
}
#Setting up private dns entries for vault
resource "aws_route53_record" "private_record_vault" {
  zone_id = data.aws_route53_zone.private_zone_internal.zone_id
  name = "vault.${local.private_domain}"
  type    = "A"
  alias {
    name                   = data.aws_alb.blk_nlb_external.dns_name
    zone_id                = data.aws_alb.blk_nlb_external.zone_id
    evaluate_target_health = true
  }
}
#Setting up private dns entries on aais nodes specific
resource "aws_route53_record" "private_record_aais" {
  for_each = {for k in ["*.ordererorg"] : k => k if var.org_name == "aais" }
  name = "${each.value}"
  type = "A"
  zone_id = data.aws_route53_zone.private_zone.zone_id
  alias {
    evaluate_target_health = true
    name = data.aws_alb.blk_nlb_external.dns_name
    zone_id = data.aws_alb.blk_nlb_external.zone_id
  }
}
#Setting up private dns entries common for all node types
resource "aws_route53_record" "private_record_common" {
 #name = var.aws_env != "prod" ? "*.${var.org_name}-net.${var.org_name}.${var.aws_env}.${var.domain_info.sub_domain_name}" : "*.${var.org_name}-net.${var.org_name}.${var.domain_info.sub_domain_name}"
  name = "*.${var.org_name}-net.${var.org_name}"
  type = "A"
  zone_id = data.aws_route53_zone.private_zone.zone_id
  alias {
    evaluate_target_health = true
    name = data.aws_alb.blk_nlb_external.dns_name
    zone_id = data.aws_alb.blk_nlb_external.zone_id
  }
}
#Setting up private dns entry for data call and insurance data manager
resource "aws_route53_record" "private_record_public_services" {
  for_each = toset(["data-call-app-service", "insurance-data-manager-service", "utilities-service"])
  name = "${each.value}"
  type = "A"
  zone_id = data.aws_route53_zone.private_zone.zone_id
  alias {
    evaluate_target_health = true
    name = data.aws_alb.blk_nlb_external.dns_name
    zone_id = data.aws_alb.blk_nlb_external.zone_id
  }
}
#Setting up private dns entry for openidl application UI
resource "aws_route53_record" "private_record_openidl_ui" {
  name = "openidl"
  type = "A"
  zone_id = data.aws_route53_zone.private_zone.zone_id
  alias {
    evaluate_target_health = true
    name = data.aws_alb.blk_nlb_external.dns_name
    zone_id = data.aws_alb.blk_nlb_external.zone_id
  }
}


