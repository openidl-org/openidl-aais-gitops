data "archive_file" "upload_zip" {
  type = "zip"
  source_dir = "./resources/openidl-upload-lambda/"
  output_path = "./resources/openidl-upload-lambda.zip"
}
#Reading IAM identities required
data "aws_iam_user" "terraform_user" {
  user_name = local.terraform_user_name[1]
}
data "aws_iam_role" "terraform_role" {
  name = local.terraform_role_name[1]
}
#Reading IAM identity
data "aws_caller_identity" "current" {
}
data "aws_route53_zone" "public_zone" {
  zone_id = "Z045807421ALLI5ALIRJG"
}
data "aws_cognito_user_pools" "user_pool" {
  name = "cnd-dev-openidl"
}
data "aws_cognito_user_pool_client" "user_pool_client" {
  user_pool_id = data.aws_cognito_user_pools.user_pool.ids[0]
  client_id = "c9958kiir7tmp7qn2lvuekftd"
}
data "aws_s3_bucket" "intake" {
  bucket = "cnd-dev-intake"
}