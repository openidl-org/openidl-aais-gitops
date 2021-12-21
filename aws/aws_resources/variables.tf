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
variable "app_vpc_cidr" {
  description = "The VPC network CIDR Block to be created"
}
variable "app_availability_zones" {
  type        = list(string)
  description = "The list of availability zones aligning to the numbers with public/private subnets defined"
}
variable "app_private_subnets" {
  type        = list(string)
  description = "The list of private subnet cidrs to be created"
}
variable "app_public_subnets" {
  type        = list(string)
  description = "The list of public subnet cidrs to be created"
}
variable "app_public_nacl_rules" {
  type        = map(any)
  description = "The list of network access rules to be allowed for public subnets"
  default     = { inbound = [{}], outbound = [{}] }
}
variable "app_private_nacl_rules" {
  type        = map(any)
  description = "The list of network access rules to be allowed for private subnets"
  default     = { inbound = [{}], outbound = [{}] }
}
variable "blk_vpc_cidr" {
  description = "The VPC network CIDR Block to be created"
}
variable "blk_availability_zones" {
  type        = list(string)
  description = "The list of availability zones aligning to the numbers with public/private subnets defined"
}
variable "blk_private_subnets" {
  type        = list(string)
  description = "The list of private subnet cidrs to be created"
}
variable "blk_public_subnets" {
  type        = list(string)
  description = "The list of public subnet cidrs to be created"
}
variable "blk_public_nacl_rules" {
  type        = map(any)
  description = "The list of network access rules to be allowed for public subnets"
  default     = { inbound = [{}], outbound = [{}] }
}
variable "blk_private_nacl_rules" {
  type        = map(any)
  description = "The list of network access rules to be allowed for private subnets"
  default     = { inbound = [{}], outbound = [{}] }
}
#variables related to transit gateway
variable "app_tgw_routes" {
  type        = list(any)
  description = "The list of network routes to be allowed/blocked in the transit gateway route table"
  default     = []
}
variable "blk_tgw_routes" {
  type        = list(any)
  description = "The list of network routes to be allowed/blocked in the transit gateway route table"
  default     = []
}
variable "app_tgw_destination_cidr" {
  type        = list(any)
  default     = []
  description = "The list of network routes to route via transit gateway"
}
variable "blk_tgw_destination_cidr" {
  type        = list(any)
  default     = []
  description = "The list of network routes to route via transit gateway"
}
variable "tgw_amazon_side_asn" {
  type        = string
  description = "The amazon side asn for the transit gateway"
}
#bastion host related
variable "app_bastion_sg_ingress" {
  type        = list(any)
  default     = []
  description = "The list of traffic rules to be allowed for ingress"
}
variable "app_bastion_sg_egress" {
  type        = list(any)
  default     = []
  description = "The list of traffic rules to be allowed for egress"
}
variable "blk_bastion_sg_ingress" {
  type        = list(any)
  default     = []
  description = "The list of traffic rules to be allowed for ingress"
}
variable "blk_bastion_sg_egress" {
  type        = list(any)
  default     = []
  description = "The list of traffic rules to be allowed for egress"
}
variable "app_bastion_ssh_key" {
  type        = string
  description = "The public ssh key to setup on the bastion host for remote ssh access"
}
variable "blk_bastion_ssh_key" {
  type        = string
  description = "The public ssh key to setup on the bastion host for remote ssh access"
}
variable "bastion_host_nlb_external" {
  type = bool
  description = "Do you want to set nlb for the bastion hosts in autoscaling group to be external"
}
#app cluster (eks) worker nodes application traffic specific SG
variable "app_eks_workers_app_sg_ingress" {
  type        = list(any)
  description = "The ingress rules of the application specific traffic to be allowed to worker nodes of app cluster"
}
variable "app_eks_workers_app_sg_egress" {
  type        = list(any)
  description = "The egress rules of the application specific traffic to be allowed to worker nodes of app cluster"
}
#blk cluster (eks) worker nodes application traffic specific SG
variable "blk_eks_workers_app_sg_ingress" {
  type        = list(any)
  description = "The ingress rules of the application specific traffic to be allowed to worker nodes of blk cluster"
}
variable "blk_eks_workers_app_sg_egress" {
  type        = list(any)
  description = "The egress rules of the application specific traffic to be allowed to worker nodes of blk cluster"
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
#aws cognito variables
#aws cognito application client specific variables
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
#aws cognito domain (default/custom) specific variables
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
#aws cognito user pool specific variables
variable "userpool_recovery_mechanisms" {
  description = "The list of Account Recovery Options"
  type        = list(any)
  default     = []
}
variable "userpool_allow_admin_create_user_only" {
  type        = bool
  description = "Is the administrator allowed to create user profiles or users can sign themselves via app"
  default     = false
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
variable "eks_worker_instance_type" {
  description = "The eks cluster worker node instance type"
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
variable "eks_wg_block_device_name" {
  description = "EBS volume device name"
}
variable "eks_wg_ebs_volume_size" {
  description = "Whether to enable pubic IP address for worker groups"
}
variable "eks_wg_ebs_volume_type" {
  description = "Type of EBS volume"
}
variable "eks_wg_ebs_vol_encrypted" {
  description = "Whether to enable encryption for EBS volume"
}
variable "eks_wg_health_check_type" {
  description = "Type of Health check for worker group"
}
variable "app_eks_worker_nodes_ssh_key" {
  type        = string
  description = "The ssh public key to setup on worker nodes in app cluster eks for remote access"
}
variable "blk_eks_worker_nodes_ssh_key" {
  type        = string
  description = "The ssh public key to setup on worker nodes in blk cluster eks for remote access"
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
#cloudtrail related
variable "cw_logs_retention_period" {
  type        = number
  description = "The number of days to retain cloudwatch logs related to cloudtrail events"
}
variable "s3_bucket_name_cloudtrail" {
  type        = string
  description = "The name of s3 bucket to store the cloudtrail logs"
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
variable "s3_bucket_name_hds_analytics" {
  type = string
  description = "The name of s3 bucket for reporting relevant only to carrier and analytics node"
}