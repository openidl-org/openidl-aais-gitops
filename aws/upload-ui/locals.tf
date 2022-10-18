#Temporary variables and its manipulations are here 
locals {
  terraform_user_name = split("/", var.aws_user_arn)
  terraform_role_name = split("/", var.aws_role_arn)
  org_name            = substr(var.org_name, 0, 4)
  std_name            = "${substr(var.org_name,0,4)}-${var.aws_env}"
  tags = {}
}