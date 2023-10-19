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
#variables related to VPC
variable "default_nacl_rules" {
  type        = map(any)
  description = "The list of default access rules to be allowed"
  default     = {inbound=[{}],outbound=[{}]}
}
variable "default_sg_rules" {
  type        = map(any)
  description = "The list of default traffic flow to be opened in security group"
  default = {ingress=[{}],egress=[{}]}
}
variable "vpc_cidr" {
  description = "The VPC network CIDR Block to be created"
  default = ""
}
variable "availability_zones" {
  type        = list(string)
  description = "The list of availability zones aligning to the numbers with public/private subnets defined"
  default = []
}
variable "private_subnets" {
  type        = list(string)
  description = "The list of private subnet cidrs to be created"
  default = []
}
variable "public_subnets" {
  type        = list(string)
  description = "The list of public subnet cidrs to be created"
  default = []
}
variable "public_nacl_rules" {
  type        = map(any)
  description = "The list of network access rules to be allowed for public subnets"
  default     = { inbound = [{}], outbound = [{}] }
}
variable "private_nacl_rules" {
  type        = map(any)
  description = "The list of network access rules to be allowed for private subnets"
  default     = { inbound = [{}], outbound = [{}] }
}
#bastion host related
variable "bastion_sg_ingress" {
  type        = list(any)
  default     = []
  description = "The list of traffic rules to be allowed for ingress"
}
variable "bastion_sg_egress" {
  type        = list(any)
  default     = []
  description = "The list of traffic rules to be allowed for egress"
}
variable "bastion_ssh_key" {
  type        = string
  description = "The public ssh key to setup on the bastion host for remote ssh access"
  default = ""
}
variable "instance_type" {
  description = "The instance type of the bastion host"
  type        = string
  default     = "t2.small"
}
variable "instance_ami_id" {
  description = "The ami id for the ec2 instance"
  type        = string
  default     = "ami-0d5eff06f840b45e9"
}
variable "instance_count" {
  description = "The number of instances to launch"
  type        = number
  default     = 1
}
variable "storage_type" {
  description = "The ebs volume storage type"
  type        = string
  default     = "gp2"
}
variable "storage_size" {
  description = "The ebs volume storage size"
  type        = string
  default     = "30"
}
variable "root_block_device_volume_type" {
  description = "root_block_device volume type"
}
variable "root_block_device_volume_size" {
  description = "root_block_device volume Size"
}
variable "org_name" {
  type = string
  description = "The name of the organization"
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
variable "create_vpc" {
  type = bool
  default = true
  description = "Determines whether to create vpc or use existing vpc"
}
variable "vpc_id" {
  type = string
  default = ""
  description = "Existing VPC ID to use"
}
variable "custom_tags" {
  type = map
  default = {}
  description ="List of custom tags to include"
}
variable "vpc_flow_logs_kms_key_arn" {
  type = string
  default = ""
  description = "KMS Key arn to be used for VPC flow logs related cloudwatch logs group"
}
variable "create_kms_keys" {
  type = bool
  default = "true"
  description = "Determine whether KMS keys are required to create"
}
