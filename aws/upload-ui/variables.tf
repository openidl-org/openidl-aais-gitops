#AWS environment definition variables
variable "aws_region" {
  default     = "us-east-2"
  type        = string
  description = "The aws region to deploy the infrastructure"
  validation {
    condition     = can(regex("([a-z]{2})-(.*)-([0-9])", var.aws_region))
    error_message = "The aws region must be entered in acceptable format, ex: us-east-2."
  }
}
variable "aws_env" {
  default = "dev"
  type    = string
  validation {
    condition     = can(regex("dev", var.aws_env)) || can(regex("prod", var.aws_env)) || can(regex("test", var.aws_env))
    error_message = "The environment value must be either \\dev\\test\\prod."
  }
}
variable "aws_account_number" {
  type        = string
  description = "The aws account number on which core application infra is to setup/exists"
}
variable "aws_user_arn" {
  type        = string
  description = "The iam user will have access to s3 bucket and kms key"
}
variable "aws_role_arn" {
  type        = string
  description = "The iam role which will have access to s3 bucket and kms key"
}
#Org name related
variable "org_name" {
  type = string
  description = "The name of the organization"
  default = ""
}
variable "aws_access_key" {
  type = string
  default = ""
  description = "IAM user access key"
}
variable "aws_secret_key" {
  type = string
  default = ""
  description = "IAM user secret key"
}
variable "aws_external_id" {
  type = string
  default = "terraform"
  description = "External Id setup while setting up IAM user and and its relevant roles"
}
variable "s3_bucket_name_upload_ui" {
  type = string
  description = "S3 bucket name to be used to host openidl UI static web content"
}
#Custom tags related
variable "custom_tags" {
  type = map
  default = {}
  description ="List of custom tags to include"
}
