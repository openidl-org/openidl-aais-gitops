locals {
   std_name = "${substr(var.org_name,0,4)}-${var.aws_env}"

   terraform_user_name = split("/", var.aws_user_arn)
   terraform_role_name = split("/", var.aws_role_arn)

   tags = merge(var.custom_tags, {
      application = "openidl"
      environment = var.aws_env
      managed_by  = "terraform"
      node_type   = var.org_name
  })
}

