#set org name as below
#when nodetype is aais set org_name="aais"
#when nodetype is analytics set org_name="analytics"
#when nodetype is aais's dummy carrier set org_name="carrier" and for other carriers refer to next line.
#when nodetype is other carrier set org_name="<carrier_org_name>" , example: org_name = "travelers" etc.,

org_name = "analytics"
aws_env = "dev" #set to dev|test|prod

#--------------------------------------------------------------------------------------------------------------------
#Choose whether to create VPC or use existing VPC
create_vpc = "false"

#Key in VPC ID when create_vpc is set to false
vpc_id = "vpc-0abf6170667972e95"

#Key in for the below when create_vpc is set to true
# 3 Availability Zones required
vpc_cidr = ""
availability_zones = []
public_subnets = []
private_subnets = []

#--------------------------------------------------------------------------------------------------------------------
#Bastion host specs. It is provisioned in autoscaling group and gets an Elastic IP assigned
#Choose whether to provision bastion host
create_bastion_host = "true"

#when chosen to create bastion host, set the required IP address or CIDR block that is allowed SSH access to bastion host
bastion_sg_ingress =  [{rule="ssh-tcp", cidr_blocks = "3.237.88.84/32"}]
bastion_sg_egress =   [{rule="ssh-tcp", cidr_blocks = "3.237.88.84/32"}]

#--------------------------------------------------------------------------------------------------------------------
#Route53 (PUBLIC) DNS domain related specifications
domain_info = {
  r53_public_hosted_zone_required = "no", #Options: yes | no - This allows to chose whether to setup public hosted zone in Route53
  domain_name = "aaisdirect.com", #Primary domain registered
  sub_domain_name = "analytics", #Sub domain if applicable. Otherwise it can be empty quotes
  comments = "analytics-dev node domain"
}

#--------------------------------------------------------------------------------------------------------------------
#Cognito specifications
#Chose whether to provision Cognito user pool
create_cognito_userpool = "true"

#When cognito is choosen to provision set the below
userpool_name                = "openidl" #unique user_pool name

# COGNITO_DEFAULT - Uses cognito default. When set to cognito default SES related inputs goes empty in git secrets
# DEVELOPER - Ensure inputs ses_email_identity and userpool_email_source_arn are setup in git secrets
email_sending_account        = "COGNITO_DEFAULT" # Options: COGNITO_DEFAULT | DEVELOPER

#--------------------------------------------------------------------------------------------------------------------
# application cluster EKS specifications
app_cluster_name              = "app-cluster"
app_cluster_version           = "1.20"
app_worker_nodes_ami_id       = "ami-09fd0b5dd68327412"
#--------------------------------------------------------------------------------------------------------------------
# blockchain cluster EKS specifications
blk_cluster_name = "blk-cluster"
blk_cluster_version = "1.20"
blk_worker_nodes_ami_id = "ami-09fd0b5dd68327412"

#--------------------------------------------------------------------------------------------------------------------
#cloudtrail related
#Choose whether to enable cloudtrail
create_cloudtrail = "true"

#S3 bucket name to manage cloudtrail logs
s3_bucket_name_cloudtrail = "openidl-cloudtrail"

#--------------------------------------------------------------------------------------------------------------------
#Terraform backend specification when S3 is used
terraform_state_s3_bucket_name = "openidl-tf-state"

#--------------------------------------------------------------------------------------------------------------------
#Terraform backend specifications when Terraform Enterprise/Cloud is used
#Name of the TFE/TFC organization
tfc_org_name = "openidl-aais"
#Name of the workspace that manages AWS resources
tfc_workspace_name_aws_resources = "anal-dev-aws-resources"

#--------------------------------------------------------------------------------------------------------------------
#Applicable only to analytics and carrier nodes and not applicable to AAIS node. For AAIS it can be empty.
#Name of the S3 bucket used to store the data extracted from HDS for analytics

s3_bucket_name_hds_analytics = "openidl-hdsdata"

#--------------------------------------------------------------------------------------------------------------------
#Name of the PUBLIC S3 bucket used to manage logos
#Optional: Choose whether s3 public bucket is required to provision
create_s3_bucket_public = "true"

s3_bucket_name_logos = "openidl-public-logos"

#--------------------------------------------------------------------------------------------------------------------
#Name of the S3 bucket to store S3 bucket and its object access logs
s3_bucket_name_access_logs = "openidl-access-logs"

#--------------------------------------------------------------------------------------------------------------------
#KMS Key arn to be set when create_kms_keys is set to false
create_kms_keys = "true"
s3_kms_key_arn = ""
eks_kms_key_arn = ""
cloudtrail_cw_logs_kms_key_arn = ""
vpc_flow_logs_kms_key_arn = ""
secrets_manager_kms_key_arn = ""

#--------------------------------------------------------------------------------------------------------------------
#Cloudwatch logs retention period (For VPC flow logs, EKS logs, Cloudtrail logs)
cw_logs_retention_period = "90" #example 90 days

#--------------------------------------------------------------------------------------------------------------------
#Custom tags to include

custom_tags = {
  department = "openidl"
  team = "demo-team"
}