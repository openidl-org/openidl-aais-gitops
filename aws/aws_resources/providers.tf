#Activate the below code snippet when used with GitHub actions pipeline
/*
provider "aws" {
  region = var.aws_region
}
*/

#Active below code snippet when used with Jenkins pipeline 
provider "aws" {
  region = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  assume_role {
    role_arn     = var.aws_role_arn
    session_name = "terraform"
    external_id  = var.aws_external_id
  }
}
provider "zipper" {
  skip_ssl_validation = false
}
