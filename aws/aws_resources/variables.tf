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
#Variables related to VPC
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
  validation {
    condition = var.vpc_cidr != "172.17.0.0/16"
    error_message = "Docker runs in the 172.17.0.0/16 CIDR range in Amazon EKS clusters. We recommend that your cluster's VPC subnets do not overlap this range to avoid network traffic routing issues."
  }
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
#Bastion host related
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
#AWS cognito variables
#AWS cognito application client specific variables
variable "client_app_name" {
  type        = string
  description = "The name of the application client"
  default     = ""
}
variable "client_allowed_oauth_flows" {
  type        = list(string)
  description = "The list of allowed oauth flows"
  #default = ["code", "implicit", "client_credentials"]
  default = []
}
variable "client_callback_urls" {
  type        = list(string)
  description = "The list of callback urls"
  default     = []
}
variable "client_logout_urls" {
  type        = list(string)
  description = "The list of signout urls"
  default     = []
}
variable "client_default_redirect_url" {
  type        = string
  description = "The default url to redirect"
  default     = ""
}
variable "client_allowed_oauth_scopes" {
  type        = list(string)
  description = "The list of allowed OAuth scopes (phone, email, openid, profile, and aws.cognito.signin.user.admin)"
  default     = []
  #default = ["phone", "email", "openid", "profile", "aws.cognito.signin.user.admin"]
}
variable "client_explicit_auth_flows" {
  type        = list(string)
  description = "List of authentication flows (ADMIN_NO_SRP_AUTH, CUSTOM_AUTH_FLOW_ONLY, USER_PASSWORD_AUTH, ALLOW_ADMIN_USER_PASSWORD_AUTH, ALLOW_CUSTOM_AUTH, ALLOW_USER_PASSWORD_AUTH, ALLOW_USER_SRP_AUTH, ALLOW_REFRESH_TOKEN_AUTH)"
  default     = []
}
variable "client_generate_secret" {
  type        = bool
  description = "The secret is required to generate"
  default     = true
}
variable "client_prevent_user_existence_errors" {
  type        = string
  description = "Choose which errors and responses are returned by Cognito APIs during authentication, account confirmation, and password recovery when the user does not exist in the user pool. When set to ENABLED and the user does not exist, authentication returns an error indicating either the username or password was incorrect, and account confirmation and password recovery return a response indicating a code was sent to a simulated destination. When set to LEGACY, those APIs will return a UserNotFoundException exception if the user does not exist in the user pool."
  default     = "ENABLED"
  #LEGACY is alternate choice
}
variable "client_read_attributes" {
  type        = list(string)
  description = "The list of attributes of an user allowed to read by an application"
  default     = []
}
variable "client_write_attributes" {
  type        = list(string)
  description = "The list of attributes of an user allowed to write by an application"
  default     = []
}
variable "client_supported_idp" {
  type        = list(string)
  description = "The list of identity providers to be supported"
  default     = []
}
variable "client_allowed_oauth_flows_user_pool_client" {
  type        = bool
  description = "Whether the client is allowed to follow the OAuth protocol when interacting with Cognito user pools"
  default     = true
}
variable "client_refresh_token_validity" {
  description = "The time limit in days refresh tokens are valid for. Must be between 60 minutes and 3650 days. This value will be overridden if you have entered a value in `token_validity_units`"
  type        = number
  default     = 30
}
variable "client_id_token_validity" {
  description = "Time limit, between 5 minutes and 1 day, after which the ID token is no longer valid and cannot be used. Must be between 5 minutes and 1 day. Cannot be greater than refresh token expiration. This value will be overridden if you have entered a value in `token_validity_units`."
  type        = number
  default     = 60
}
variable "client_token_validity_units" {
  description = "Configuration block for units in which the validity times are represented in. Valid values for the following arguments are: `seconds`, `minutes`, `hours` or `days`."
  type        = any
  default = {
    access_token  = "hours"
    id_token      = "hours"
    refresh_token = "days"
  }
}
variable "client_access_token_validity" {
  description = "Time limit, between 5 minutes and 1 day, after which the access token is no longer valid and cannot be used."
  type        = number
  default     = 60
}
variable "email_sending_account" {
  type        = string
  description = "The email sending account type. COGNITO_DEFAULT | DEVELOPER"
}
#AWS cognito domain (default/custom) specific variables
variable "cognito_domain" {
  type        = string
  description = "The cognito or custom domain to be used"
  default     = ""
}
variable "acm_cert_arn" {
  type        = string
  description = "The acm certificate arn of the custom domain"
  default     = ""
}
#AWS cognito user pool specific variables
variable "userpool_recovery_mechanisms" {
  description = "The list of Account Recovery Options"
  type        = list(any)
  default     = []
}
variable "userpool_allow_admin_create_user_only" {
  type        = bool
  description = "Is the administrator allowed to create user profiles or users can sign themselves via app"
  default     = true
}
variable "userpool_alais_attributes" {
  type        = list(string)
  description = "The attributes supported as an alias for the userpool"
  default     = []
}
variable "userpool_username_attributes" {
  type        = list(string)
  description = "Whether email addresses or phone numbers can be specified as usernames when a user signs up"
  default     = []
}
variable "userpool_auto_verified_attributes" {
  type        = list(any)
  description = "The attributes to auto verify"
  default     = ["email"]
}
variable "userpool_challenge_required_on_new_device" {
  type        = bool
  description = "Whether a challenge is required on a new device"
  default     = true
}
variable "userpool_device_only_remembered_on_user_prompt" {
  type        = bool
  description = "Whether a device is only remembered on user prompt"
  default     = true
}
variable "userpool_email_config" {
  type        = map(any)
  description = "The details of email config set from SES"
  default     = {}
}
variable "userpool_email_verification_subject" {
  type        = string
  description = "The email verification subject"
  default     = ""
}
variable "userpool_email_verification_message" {
  type        = string
  description = "The email verification message"
  default     = ""
}
variable "userpool_mfa_configuration" {
  type        = string
  default     = "OFF"
  description = "The MFA is required"
}
variable "userpool_software_token_mfa_enabled" {
  type        = bool
  default     = false
  description = "Are you enabling software token mfa"
}
variable "password_policy_minimum_length" {
  type        = number
  default     = 8
  description = "The password minimum length"
}
variable "password_policy_require_lowercase" {
  type        = bool
  default     = true
  description = "The password requires lowercase char"
}
variable "password_policy_require_numbers" {
  type        = bool
  default     = true
  description = "The password requires a number in it"
}
variable "password_policy_require_symbols" {
  type        = bool
  default     = true
  description = "The password requires a symbol in it"
}
variable "password_policy_require_uppercase" {
  type        = bool
  default     = true
  description = "The password requires a uppercase character"
}
variable "password_policy_temporary_password_validity_days" {
  type        = number
  default     = 5
  description = "The temporary password validity days in number"
}
variable "userpool_advanced_security_mode" {
  type        = string
  default     = "AUDIT"
  description = "The userpool advanced security mode"
}
variable "userpool_enable_username_case_sensitivity" {
  type        = bool
  default     = false
  description = "The usernames in the userpool is case-sensitive?"
}
variable "userpool_name" {
  type        = string
  description = "The name of the cognito userpool to create"
  default     = ""
}
variable "ses_email_identity" {
  type        = string
  description = "The email address to be used in Cognito referred as from-email & reply-to-email address"
  default     = ""
}
variable "userpool_email_source_arn" {
  type        = string
  description = "The cognito ses email identity source arn"
  default = ""
}
#------------------------------------------------------------------------------------------------------------------
#Route53 related
variable "domain_info" {
  type        = any
  description = "The name of the domain registered within aws-route53 or outside"
  default     = {}
}
#-------------------------------------------------------------------------------------------------------------------
#EKS cluster related
variable "app_cluster_name" {
  description = "The name of application cluster (eks)"
  type        = string
}
variable "blk_cluster_name" {
  description = "The name of blockchain cluster (eks)"
  type        = string
}
variable "app_cluster_version" {
  description = "The hasicorp terraform eks module version"
  type        = string
  default     = "1.19"
}
variable "blk_cluster_version" {
  description = "The hasicorp terraform eks module version"
  type        = string
  default     = "1.19"
}
variable "app_eks_worker_instance_type" {
  description = "The app eks cluster worker node instance type"
  type        = string
}
variable "blk_eks_worker_instance_type" {
  description = "The blk eks cluster worker node instance type"
  type        = string
}
variable "tenancy" {
  description = "The tenancy of the instance (if the instance is running in a VPC). Available values: default, dedicated, host."
  type        = string
  default     = "default"
}
variable "cluster_encryption_config_resources" {
  type        = list(any)
  default     = ["secrets"]
  description = "Cluster Encryption Config Resources to encrypt, e.g. ['secrets']"
}
variable "cluster_encryption_config" {
  description = "Configuration block with encryption configuration for the cluster. See examples/secrets_encryption/main.tf for example format"
  type = list(object({
    provider_key_arn = string
    resources        = list(string)
  }))
  default = []
}
variable "kubeconfig_output_path" {
  description = "Where to save the Kubectl config file (if `write_kubeconfig = true`). Assumed to be a directory if the value ends with a forward slash `/`."
  type        = string
  default     = "./kubeconfig_file/"
}
variable "target_group_sticky" {
  description = "Whether to enable/disable stickiness for NLB"
  type        = bool
  default     = true
}
variable "cluster_endpoint_private_access" {
  type        = bool
  description = "Indicates whether or not the Amazon EKS private API server endpoint is enabled"
  default     = true
}
variable "cluster_create_endpoint_private_access_sg_rule" {
  type        = bool
  description = "Whether to create security group rules for the access to the Amazon EKS private API server endpoint"
  default     = false
}
variable "cluster_endpoint_private_access_cidrs" {
  type        = list(string)
  description = "List of CIDR blocks which can access the Amazon EKS private API server endpoint"
  default     = null
}
variable "cluster_endpoint_public_access" {
  type        = bool
  description = "Indicates whether or not the Amazon EKS public API server endpoint is enabled"
  default     = false
}
variable "cluster_endpoint_public_access_cidrs" {
  type        = list(string)
  description = "List of CIDR blocks which can access the Amazon EKS public API server endpoint"
  default     = null
}
variable "cluster_create_timeout" {
  description = "Timeout value when creating the EKS cluster."
  type        = string
  default     = "30m"
}
variable "manage_aws_auth" {
  type        = bool
  description = "Whether to apply the aws-auth configmap file."
  default     = true
}
variable "wait_for_cluster_timeout" {
  description = "A timeout (in seconds) to wait for cluster to be available."
  type        = number
  default     = 3600
}
variable "write_kubeconfig" {
  default     = true
  description = "Whether to write a Kubectl config file containing the cluster configuration. Saved to variable \"kubeconfig_output_path\"."
  type        = bool
}
variable "attach_worker_cni_policy" {
  description = "Whether to attach the Amazon managed `AmazonEKS_CNI_Policy` IAM policy to the default worker IAM role. WARNING: If set `false` the permissions must be assigned to the `aws-node` DaemonSet pods via another method or nodes will not be able to join the cluster."
  type        = bool
  default     = true
}
variable "wg_asg_min_size" {
  description = "The worker group min auto scaling size"
}
variable "wg_asg_max_size" {
  description = "The worker group max auto scaling size"
}
variable "wg_asg_desired_capacity" {
  description = "The worker group desired instance capacity"
}
variable "wg_ebs_optimized" {
  description = "The worker group ebs volume optimized"
}
variable "wg_instance_refresh_enabled" {
  description = "The worker group instance refresh status"
}
variable "eks_cluster_logs" {
  description = "List EKS Cluster logs that when logs enabled"
  type        = list(string)
  default     = []
}
variable "dhcp_options_domain_name_servers" {
  description = "Specify a list of DNS server addresses for DHCP options set, default to AWS provided (requires enable_dhcp_options set to true)"
  type        = list(string)
  default     = ["AmazonProvidedDNS"]
}
variable "eks_wg_public_ip" {
  description = "Whether to enable pubic IP address for worker groups"
}
variable "eks_wg_root_vol_encrypted" {
  description = "Whether to enable encryption for root volume"
}
variable "eks_wg_root_volume_size" {
  description = "Size of root volume"
}
variable "eks_wg_root_volume_type" {
  description = "Type of root volume"
}
variable "eks_wg_health_check_type" {
  description = "Type of Health check for worker group"
}
variable "app_eks_worker_nodes_ssh_key" {
  type        = string
  description = "The ssh public key to setup on worker nodes in app cluster eks for remote access"
  default = ""
}
variable "blk_eks_worker_nodes_ssh_key" {
  type        = string
  description = "The ssh public key to setup on worker nodes in blk cluster eks for remote access"
  default = ""
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
#Logs retention related
variable "cw_logs_retention_period" {
  type        = number
  description = "The number of days to retain cloudwatch logs related to cloudtrail events"
  default = 90
}
#-------------------------------------------------------------------------------------------------------------------
#Cloudtrail related
variable "s3_bucket_name_cloudtrail" {
  type        = string
  description = "The name of s3 bucket to store the cloudtrail logs"
  default = ""
}
#-------------------------------------------------------------------------------------------------------------------
#Org name related
variable "org_name" {
  type = string
  description = "The name of the organization"
  default = ""
}
#-------------------------------------------------------------------------------------------------------------------
#S3 as backend related 
variable "terraform_state_s3_bucket_name" {
  type = string
  description = "The name of the s3 bucket will manage terraform state files"
  default = ""
}
#-------------------------------------------------------------------------------------------------------------------
#Terraform cloud/enterprise as backend related 
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
#-------------------------------------------------------------------------------------------------------------------
#EKS related 
variable "app_worker_nodes_ami_id" {
  type = string
  description = "The AMI id of the app cluster worker nodes"
  default = ""
}
variable "blk_worker_nodes_ami_id" {
  type = string
  description = "The AMI id of the blk cluster worker nodes"
  default = ""
}
#-------------------------------------------------------------------------------------------------------------------
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
variable "s3_bucket_name_hds_analytics" {
  type = string
  description = "The name of s3 bucket for reporting relevant only to carrier and analytics node"
  default = ""
}
variable "s3_bucket_name_logos" {
  type = string
  description = "The name of s3 bucket used to manage logos (public s3 bucket)"
  default = ""
}
variable "s3_bucket_name_access_logs" {
  type = string
  description = "The name of s3 bucket used to access logs of s3 buckets"
  default = ""
}
variable "s3_bucket_names_etl" {
  type = map(any)
  description = "The name of s3 buckets used for IDM-ETL functions"
  default = {idm-loader: "", intake: "", failure: ""}
}
#-------------------------------------------------------------------------------------------------------------------
#Resource choice related
variable "create_bastion_host" {
  type = bool
  default = true
  description = "Determines whether to create bastion host in the VPC network"
}
variable "create_cloudtrail" {
  type = bool
  default = true
  description = "Determines whether to enable cloudtrial"
}
variable "create_cognito_userpool" {
  type = bool
  default = true
  description = "Determines whether to create cognito userpool"
}
variable "create_s3_bucket_public" {
  type = bool
  default = true
  description = "Determines whether to create public s3 bucket to manage logos"
}
variable "create_vpc" {
  type = bool
  default = true
  description = "Determines whether to create vpc or use existing vpc"
}
variable "create_kms_keys" {
  type = bool
  default = "true"
  description = "Determine whether KMS keys are required to create"
}
#-------------------------------------------------------------------------------------------------------------------
#KMS key related 
variable "s3_kms_key_arn" {
  type = string
  default = ""
  description ="KMS Key arn to be used for S3 buckets"
}
variable "eks_kms_key_arn" {
  type = string
  default = ""
  description = "KMS Key arn to be used for EKS related cloudwatch logs group"
}
variable "cloudtrail_cw_logs_kms_key_arn" {
  type = string
  default = ""
  description = "KMS Key arn to be used for EKS related cloudwatch logs group"
}
variable "vpc_flow_logs_kms_key_arn" {
  type = string
  default = ""
  description = "KMS Key arn to be used for VPC flow logs related cloudwatch logs group"
}
variable "secrets_manager_kms_key_arn" {
  type = string
  default = ""
  description = "KMS Key arn to be used for VPC flow logs related cloudwatch logs group"
}
variable "dynamodb_kms_key_arn" {
  type = string
  default = ""
  description = "KMS key arnt o be used to encrypt DynamoDB table related to ETL function"
}
#-------------------------------------------------------------------------------------------------------------------
#Existing VPC related 
variable "vpc_id" {
  type = string
  default = ""
  description = "Existing VPC ID to use"
}
#-------------------------------------------------------------------------------------------------------------------
#Custom tags related 
variable "custom_tags" {
  type = map
  default = {}
  description ="List of custom tags to include"
}
#-------------------------------------------------------------------------------------------------------------------
#SNS notification subscription - email list
variable "sns_subscription_email_ids" {
  type=list
  description = "The list of email ids to subscribe for SNS notifications related to ETL-IDM"
  default = []
}
variable "api_username" {
  type = string
  description = "The OpenIDL API username that will be used by lambda function to run ETL-IDM"
}
variable "api_user_password" {
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
variable "s3_bucket_name_upload_ui" {
  type = string
  description = "S3 bucket name to be used to host openidl UI static web content"
}