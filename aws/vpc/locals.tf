##local variables and their manipulation are here
locals {
  terraform_user_name = split("/", var.aws_user_arn)
  terraform_role_name = split("/", var.aws_role_arn)

  std_name          = "${var.org_name}-${var.aws_env}"
  policy_arn_prefix = "arn:aws:iam::aws:policy"

  tags = merge(var.custom_tags, {
    application = "openidl"
    environment = var.aws_env
    managed_by  = "terraform"
    node_type   = var.org_name
  })
}