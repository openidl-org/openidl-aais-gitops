#aws environment definition variables
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
#------------------------------------------------------------------------------------------------------------------
#Route53 related
variable "domain_info" {
  type        = any
  description = "The name of the domain registered within aws-route53 or outside"
  default     = {}
}
#-------------------------------------------------------------------------------------------------------------------
variable "app_cluster_name" {
  description = "The name of application cluster (eks)"
  type        = string
}
variable "blk_cluster_name" {
  description = "The name of blockchain cluster (eks)"
  type        = string
}
variable "app_cluster_map_roles" {
  type        = list(any)
  description = "The list of iam roles to have admin access in app cluster(EKS) to manage resources (sets config-map)"
  default     = []
}
variable "app_cluster_map_users" {
  type        = list(any)
  description = "The list of iam users to have admin access in app cluster (EKS) to manage resources (sets config-map)"
  default     = []
}
variable "blk_cluster_map_roles" {
  type        = list(any)
  description = "The list of iam roles to have admin access in blk cluster(EKS) to manage resources (sets config-map)"
  default     = []
}
variable "blk_cluster_map_users" {
  type        = list(any)
  description = "The list of iam users to have admin access in blk cluster(EKS) to manage resources (sets config-map)"
  default     = []
}
#-------------------------------------------------------------------------------------------------------------------
variable "org_name" {
  type = string
  description = "The short name of the carrier node"
  default = ""
}
variable "terraform_state_s3_bucket_name" {
  type = string
  description = "The name of the s3 bucket will manage terraform state files"
  default = ""
}
variable "tfc_workspace_name_aws_resources" {
  type = string
  description = "The terraform cloud workspace of AWS resources provisioned"
  default = ""
}
variable "tfc_org_name" {
  type = string
  description = "The terraform cloud organisation name"
  default = ""
}
variable "bastion_host_nlb_external" {
  type = bool
  description = "Do you want to set nlb for the bastion hosts in autoscaling group to be external"
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
  description = "ExternalID setup while setting up IAM user and relevant IAM roles"

}