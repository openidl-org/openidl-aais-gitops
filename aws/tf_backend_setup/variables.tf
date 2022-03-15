#aws environment specific variables
variable "aws_region" {
  default     = "us-east-1"
  type        = string
  description = "The aws region to deploy the infrastructure"
  validation {
    condition     = can(regex("([a-z]{2})-(.*)-([0-9])", var.aws_region))
    error_message = "The aws region must be entered in acceptable format, ex: us-east-2."
  }
}
variable "aws_access_key" {
  type        = string
  description = "The aws access key for the account login"
}
variable "aws_secret_key" {
  type        = string
  description = "The aws secret key for the account login"
}
variable "aws_role_arn" {
  type = string
  description = "The aws iam role arn to be assumed by the iam user"
}
variable "aws_external_id" {
  type = string
  default = "terraform"
  description = "The external id used as extra condition as a best practice"
}
variable "tags" {
  type = map
  default = {}
}
variable "aws_account_id" {
  type = string
  description = "The account number of the aws account used"
}
variable "aws_user_arn" {
  type = string
  description = "The arn of the aws iam user"
}
#terraform backend specific variables
variable "tf_backend_s3_bucket" {
  type = string
  description = "The s3 bucket to store terraform state files"
}
variable "tf_backend_dynamodb_table_aws_resources" {
  type = string
  description = "The dynamodb table to manage terraform state file locking for aws resources"
}
variable "tf_backend_dynamodb_table_k8s_resources" {
  type = string
  description = "The dynamodb table to manage terraform state file locking for k8s resources"
}
variable "tf_inputs_s3_bucket" {
  type = string
  description = "The name of s3 bucket to manage terraform input files"
}
variable "org_name" {
  type = string
  description = "The name of the organization"
  default = ""
}
variable "aws_env" {
  default = "dev"
  type    = string
  validation {
    condition     = can(regex("dev", var.aws_env)) || can(regex("prod", var.aws_env)) || can(regex("test", var.aws_env))
    error_message = "The environment value must be either \\dev\\test\\prod."
  }
}
variable "custom_tags" {
  type = map
  default = {}
  description ="List of custom tags to include"
}
variable "s3_kms_key_arn" {
  type = string
  default = ""
  description ="KMS Key arn to be used for S3 buckets"
}
variable "dynamodb_kms_key_arn" {
  type = string
  default = ""
  description = "KMS Key arn to be used for EKS related cloudwatch logs"
}
variable "create_kms_keys" {
  type = bool
  default = "true"
  description = "Determine whether KMS keys are required to create"
}