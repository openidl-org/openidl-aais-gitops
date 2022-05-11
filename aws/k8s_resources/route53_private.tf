#Setting up private dns entries for data call and insurance data manager services
resource "aws_route53_record" "private_record_services" {
  for_each = toset(["data-call-app-service", "insurance-data-manager-service"])
  zone_id = data.aws_route53_zone.private_zone_internal.zone_id
  name = var.aws_env != "prod" ? "${each.value}.${local.private_domain}" : "${each.value}.${local.private_domain}"
  type    = "A"
  alias {
    name                   = data.aws_alb.app_nlb_internal.dns_name
    zone_id                = data.aws_alb.app_nlb_internal.zone_id
    evaluate_target_health = true
  }
}
#Setting up private dns entries for vault
resource "aws_route53_record" "private_record_vault" {
  zone_id = data.aws_route53_zone.private_zone_internal.zone_id
  name = var.aws_env != "prod" ? "vault.${local.private_domain}" : "vault.${local.private_domain}"
  type    = "A"
  alias {
    name                   = data.aws_alb.blk_nlb_internal.dns_name
    zone_id                = data.aws_alb.blk_nlb_internal.zone_id
    evaluate_target_health = true
  }
}
#Setting up private dns entries on aais nodes specific
resource "aws_route53_record" "private_record_aais" {
  for_each = {for k in ["*.ordererorg"] : k => k if var.org_name == "aais" }
  #name = var.aws_env != "prod" ? "${each.value}.${var.aws_env}.${var.domain_info.sub_domain_name}" : "${each.value}.${var.domain_info.sub_domain_name}"
  name = "${each.value}"
  type = "A"
  zone_id = data.aws_route53_zone.private_zone.zone_id
  alias {
    evaluate_target_health = true
    name = data.aws_alb.blk_nlb_internal.dns_name
    zone_id = data.aws_alb.blk_nlb_internal.zone_id
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
    name = data.aws_alb.blk_nlb_internal.dns_name
    zone_id = data.aws_alb.blk_nlb_internal.zone_id
  }
}



