
#aais, analytics or aais dummy carrier should be carrier and for rest specify any org name: example for travelers: trv or travelers etc.
org_name = "aais" # For aais set to aais, for analytics set to analytics, for carriers set their org name, ex: travelers
aws_env = "dev" #set to dev|test|prod
#--------------------------------------------------------------------------------------------------------------------
#Application cluster VPC specifications
app_vpc_cidr           = "172.26.0.0/16"
app_availability_zones = ["us-west-2a", "us-west-2b"]
app_public_subnets     = ["172.26.1.0/24", "172.26.2.0/24"]
app_private_subnets    = ["172.26.3.0/24", "172.26.4.0/24"]

#-------------------------------------------------------------------------------------------------------------------
#Blockchain cluster VPC specifications
blk_vpc_cidr           = "172.27.0.0/16"
blk_availability_zones = ["us-west-2a", "us-west-2b"]
blk_public_subnets     = ["172.27.1.0/24", "172.27.2.0/24"]
blk_private_subnets    = ["172.27.3.0/24", "172.27.4.0/24"]

#--------------------------------------------------------------------------------------------------------------------
#Bastion host specifications
#bastion hosts are placed behind nlb. These NLBs can be configured to be private | public to serve SSH.
#In any case whether the endpoint is private|public for an nlb, the source ip_address|cidr_block should be enabled
#in bastion hosts security group for ssh traffic

bastion_host_nlb_external = "true"

#application cluster bastion host specifications
app_bastion_sg_ingress =  [
  {rule="ssh-tcp", cidr_blocks = "172.26.0.0/16"},
  {rule="ssh-tcp", cidr_blocks = "3.237.88.84/32"}]
app_bastion_sg_egress  =   [
  {rule="https-443-tcp", cidr_blocks = "0.0.0.0/0"},
  {rule="http-80-tcp", cidr_blocks = "0.0.0.0/0"},
  {rule="ssh-tcp", cidr_blocks = "172.26.0.0/16"}] #additional ip_address|cidr_block should be included for ssh

#blockchain cluster bastion host specifications
#bastion host security specifications
blk_bastion_sg_ingress =  [
  {rule="ssh-tcp", cidr_blocks = "172.27.0.0/16"},
  {rule="ssh-tcp", cidr_blocks = "3.237.88.84/32"}]
blk_bastion_sg_egress  = [
  {rule="https-443-tcp", cidr_blocks = "0.0.0.0/0"},
  {rule="http-80-tcp", cidr_blocks = "0.0.0.0/0"},
  {rule="ssh-tcp", cidr_blocks = "172.27.0.0/16"}] #additional ip_address|cidr_block should be included for ssh

#--------------------------------------------------------------------------------------------------------------------
#Route53 (PUBLIC) DNS domain related specifications
domain_info = {
  r53_public_hosted_zone_required = "yes", #Option: yes | no
  domain_name = "aaisonline.com", #primary domain registered
  sub_domain_name = "demo", #sub domain
  comments = "aais node dns name resolutions"
}
#-------------------------------------------------------------------------------------------------------------------
#Transit gateway  specifications
tgw_amazon_side_asn = "64532" #default is 64532

#--------------------------------------------------------------------------------------------------------------------
#Cognito specifications
userpool_name                = "openidl"
client_app_name              = "openidl-client"
client_callback_urls         = ["https://openidl.aais.test.testaais.com/callback", "https://openidl.aais.test.testaais.com/redirect"]
client_default_redirect_url  = "https://openidl.aais.test.testaais.com/redirect"
client_logout_urls           = ["https://openidl.aais.test.testaais.com/signout"]
cognito_domain               = "testaais" #unique domain name
email_sending_account        = "COGNITO_DEFAULT" # Options: COGNITO_DEFAULT | DEVELOPER
# COGNITO_DEFAULT - Uses cognito default and SES related inputs goes to empty in git secrets
# DEVELOPER - Ensure inputs ses_email_identity and userpool_email_source_arn are setup in git secrets

#--------------------------------------------------------------------------------------------------------------------
#Any additional traffic in future required to open to worker nodes, the below section needs to be set
app_eks_workers_app_sg_ingress = [] #{from_port, to_port, protocol, description, cidr_blocks}
app_eks_workers_app_sg_egress = [{rule = "all-all"}]

#Any additional traffic in future required to open to worker nodes, the below section needs to be set
blk_eks_workers_app_sg_ingress = [] #{from_port, to_port, protocol, description, cidr_blocks}
blk_eks_workers_app_sg_egress = [{rule = "all-all"}]

#--------------------------------------------------------------------------------------------------------------------
# application cluster EKS specifications
app_cluster_name              = "app-cluster"
app_cluster_version           = "1.20"
app_worker_nodes_ami_id       = "<amiid_specific_to_region>"


#--------------------------------------------------------------------------------------------------------------------
# blockchain cluster EKS specifications
blk_cluster_name              = "blk-cluster"
blk_cluster_version           = "1.20"
blk_worker_nodes_ami_id       = "<amiid_specific_to_region>"

#--------------------------------------------------------------------------------------------------------------------
#cloudtrail related
cw_logs_retention_period = 90
s3_bucket_name_cloudtrail = "cloudtrail-logs"

#--------------------------------------------------------------------------------------------------------------------
#Name of the S3 bucket managing terraform state files
terraform_state_s3_bucket_name = "aais-dev-tfstate-mgmt"

#Name of the S3 bucket used to store the data extracted from HDS for analytics
#Applicable for carrier and analytics node only. For AAIS node leave it empty
s3_bucket_name_hds_analytics = ""

#S3 public bucket to manage application related images (logos)
s3_bucket_name_logos = "openidl-logos"