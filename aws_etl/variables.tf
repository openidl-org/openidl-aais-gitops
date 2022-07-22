#AWS environment definition variables
variable "aws_region" {
  default     = "us-east-2"
  type        = string
  description = "The aws region to deploy the infrastructure"
}
variable "aws_env" {
  default = "dev"
  type    = string
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
variable "org_name" {
  type = string
  description = "The name of the organization"
  default = ""
}
#AWS access related
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
#-------------------------------------------------------------------------------------------------------------------
#S3 related 
variable "s3_bucket_names_etl" {
  type = map(any)
  description = "The name of s3 buckets used for IDM-ETL functions"
  default = {idm-loader: "", intake: "", failure: ""}
}
#-------------------------------------------------------------------------------------------------------------------
#SNS notfication subscription - email list
variable "sns_subscription_email_ids" {
  type=list
  description = "The list of emailds to subscribe for SNS notifications related to ETL-IDM"
  default = []
}
variable "api_username" {
  type = string
  description = "The OpenIDL API username that will be used by lambda function to run ETL-IDM"
}
variable "api_username_password" {
  type = string
  description = "The OpenIDL API user password that will be used by lambda function to run ETL-IDM"
}
variable "carrier_id" {
  type = string
  description = "The Carrier ID of the node"
}
variable "state" {
  type = string
  description = "The state that this node belongs to"
}

