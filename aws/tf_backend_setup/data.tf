#reading iam user and role details
data "aws_iam_user" "terraform_user" {
  user_name = local.terraform_user_name[1]
}
data "aws_iam_role" "terraform_role" {
  name = local.terraform_role_name[1]
}