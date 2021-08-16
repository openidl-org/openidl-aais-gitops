#set to different node types like aais, carrier, analytics etc. Prefer 4 letter representation only.
#example: aais/carr/anlt etc.,
node_type = "aais"
aws_env = "dev" #set to dev or test or prod

#--------------------------------------------------------------------------------------------------------------------
#Application cluster VPC specifications
app_vpc_cidr           = "172.20.0.0/16"
app_availability_zones = ["us-east-2a", "us-east-2b"]
app_public_subnets     = ["172.20.1.0/24", "172.20.2.0/24"]
app_private_subnets    = ["172.20.3.0/24", "172.20.4.0/24"]

#VPC Network ACL traffic rules to be configured in the VPC
#you may need to update these rules as when new networks are added
app_public_nacl_rules = {
  inbound = [{
    rule_number = 100
    rule_action = "allow"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_block  = "172.20.0.0/16"
    },
    {
    rule_number = 101
    rule_action = "allow"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_block  = "0.0.0.0/0"
    },
    {
      rule_number = 102
      rule_action = "allow"
      from_port   = 1024
      to_port     = 65535
      protocol    = "tcp"
      cidr_block  = "0.0.0.0/0"
  },
  {
    rule_number = 103
    rule_action = "allow"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_block  = "0.0.0.0/0"
    },
  {
    rule_number = 104
    rule_action = "allow"
    from_port   = 8443
    to_port     = 8443
    protocol    = "tcp"
    cidr_block  = "0.0.0.0/0" #related to eks
    }],
  outbound = [{
    rule_number = 100
    rule_action = "allow"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_block  = "172.20.0.0/16"
    },
    {
    rule_number = 101
    rule_action = "allow"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_block  = "0.0.0.0/0"
    },
    {
    rule_number = 102
    rule_action = "allow"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_block  = "0.0.0.0/0"
    },
    {
      rule_number = 103
      rule_action = "allow"
      from_port   = 32768
      to_port     = 65535
      protocol    = "tcp"
      cidr_block  = "0.0.0.0/0"
  },
  {
    rule_number = 104
    rule_action = "allow"
    from_port   = 8443
    to_port     = 8443
    protocol    = "tcp"
    cidr_block  = "0.0.0.0/0" #related to eks
    }]
}
app_private_nacl_rules = {
  inbound = [{
    rule_number = 100
    rule_action = "allow"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_block  = "172.20.0.0/16"
    },
    {
    rule_number = 101
    rule_action = "allow"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_block  = "172.20.0.0/16"
    },
    {
    rule_number = 102
    rule_action = "allow"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_block  = "172.20.0.0/16"
    },
    {
      rule_number = 103
      rule_action = "allow"
      from_port   = 1024
      to_port     = 65535
      protocol    = "tcp"
      cidr_block  = "0.0.0.0/0" #related to eks
    },
  {
    rule_number = 104
    rule_action = "allow"
    from_port   = 8443
    to_port     = 8443
    protocol    = "tcp"
    cidr_block  = "0.0.0.0/0" #related to eks
    },
  {
    rule_number = 105
    rule_action = "allow"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_block  = "172.21.0.0/16" #related to eks
    }],
  outbound = [{
    rule_number = 100
    rule_action = "allow"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_block  = "172.20.0.0/16"
    },
    {
      rule_number = 101
      rule_action = "allow"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_block  = "0.0.0.0/0"
    },
    {
      rule_number = 102
      rule_action = "allow"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_block  = "0.0.0.0/0"
    },
    {
      rule_number = 103
      rule_action = "allow"
      from_port   = 32768
      to_port     = 65535
      protocol    = "tcp"
      cidr_block  = "0.0.0.0/0"
    },
  {
    rule_number = 104
    rule_action = "allow"
    from_port   = 8443
    to_port     = 8443
    protocol    = "tcp"
    cidr_block  = "0.0.0.0/0" #related to eks
    }]
}
#-------------------------------------------------------------------------------------------------------------------

#Blockchain cluster VPC specifications
blk_vpc_cidr           = "172.21.0.0/16"
blk_availability_zones = ["us-east-2a", "us-east-2b"]
blk_public_subnets     = ["172.21.1.0/24", "172.21.2.0/24"]
blk_private_subnets    = ["172.21.3.0/24", "172.21.4.0/24"]

#VPC Network ACL traffic rules to be configured in the VPC
#you may need to update these rules as when new networks are added
blk_public_nacl_rules = {
  inbound = [{
    rule_number = 100
    rule_action = "allow"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_block  = "172.21.0.0/16"
    },
    {
    rule_number = 101
    rule_action = "allow"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_block  = "0.0.0.0/0"
    },
    {
      rule_number = 102
      rule_action = "allow"
      from_port   = 1024
      to_port     = 65535
      protocol    = "tcp"
      cidr_block  = "0.0.0.0/0"
  },
  {
    rule_number = 103
    rule_action = "allow"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_block  = "0.0.0.0/0"
    },
  {
    rule_number = 104
    rule_action = "allow"
    from_port   = 8443
    to_port     = 8443
    protocol    = "tcp"
    cidr_block  = "0.0.0.0/0" #related to eks
    }],
  outbound = [{
    rule_number = 100
    rule_action = "allow"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_block  = "172.21.0.0/16"
    },
    {
    rule_number = 101
    rule_action = "allow"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_block  = "0.0.0.0/0"
    },
    {
    rule_number = 102
    rule_action = "allow"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_block  = "0.0.0.0/0"
    },
    {
      rule_number = 103
      rule_action = "allow"
      from_port   = 32768
      to_port     = 65535
      protocol    = "tcp"
      cidr_block  = "0.0.0.0/0"
  },
  {
    rule_number = 104
    rule_action = "allow"
    from_port   = 8443
    to_port     = 8443
    protocol    = "tcp"
    cidr_block  = "0.0.0.0/0" #related to eks
    }]
}
blk_private_nacl_rules = {
  inbound = [{
    rule_number = 100
    rule_action = "allow"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_block  = "172.21.0.0/16"
    }, {
    rule_number = 101
    rule_action = "allow"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_block  = "172.21.0.0/16"
    },
    {
    rule_number = 102
    rule_action = "allow"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_block  = "172.21.0.0/16"
    },
    {
      rule_number = 103
      rule_action = "allow"
      from_port   = 1024
      to_port     = 65535
      protocol    = "tcp"
      cidr_block  = "0.0.0.0/0" #related to eks
    },
  {
    rule_number = 104
    rule_action = "allow"
    from_port   = 8443
    to_port     = 8443
    protocol    = "tcp"
    cidr_block  = "0.0.0.0/0" #related to eks
    },
  {
    rule_number = 105
    rule_action = "allow"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_block  = "172.20.0.0/16"
    }],
  outbound = [{
    rule_number = 100
    rule_action = "allow"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_block  = "172.21.0.0/16"
    },
    {
      rule_number = 101
      rule_action = "allow"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_block  = "0.0.0.0/0"
    },
    {
      rule_number = 102
      rule_action = "allow"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_block  = "0.0.0.0/0"
    },
    {
      rule_number = 103
      rule_action = "allow"
      from_port   = 32768
      to_port     = 65535
      protocol    = "tcp"
      cidr_block  = "0.0.0.0/0"
    },
  {
    rule_number = 104
    rule_action = "allow"
    from_port   = 8443
    to_port     = 8443
    protocol    = "tcp"
    cidr_block  = "0.0.0.0/0" #related to eks
    }]
}
#--------------------------------------------------------------------------------------------------------------------

#Default security group assigned/used when a resource is created without any security group attached
default_sg_rules = {
  ingress = [{
    cidr_blocks = "172.21.0.0/16"
    description = "Inbound SSH traffic"
    from_port   = "22"
    to_port     = "22"
    protocol    = "tcp"
  },
  {
    cidr_blocks = "172.20.0.0/16"
    description = "Inbound SSH traffic"
    from_port   = "22"
    to_port     = "22"
    protocol    = "tcp"
  }],
  egress = [{
    cidr_blocks = "0.0.0.0/0"
    description = "Outbound SSH traffic"
    from_port   = "80"
    to_port     = "80"
    protocol    = "tcp"
  },
  {
    cidr_blocks = "0.0.0.0/0"
    description = "Outbound SSH traffic"
    from_port   = "443"
    to_port     = "443"
    protocol    = "tcp"
  }]
}
#--------------------------------------------------------------------------------------------------------------------

#Bastion host specifications
#application cluster bastion host specifications
app_bastion_sg_ingress =  [{rule="ssh-tcp", cidr_blocks = "172.20.0.0/16"},]
app_bastion_sg_egress =   [{rule="https-443-tcp", cidr_blocks = "0.0.0.0/0"},
                       {rule="http-80-tcp", cidr_blocks = "0.0.0.0/0"},
                       {rule="ssh-tcp", cidr_blocks = "172.20.0.0/16"}]

#blockchain cluster bastion host specifications
#bastion host security specifications
blk_bastion_sg_ingress =  [{rule="ssh-tcp", cidr_blocks = "172.21.0.0/16"},]
blk_bastion_sg_egress =   [{rule="https-443-tcp", cidr_blocks = "0.0.0.0/0"},
                       {rule="http-80-tcp", cidr_blocks = "0.0.0.0/0"},
                       {rule="ssh-tcp", cidr_blocks = "172.21.0.0/16"}]

#--------------------------------------------------------------------------------------------------------------------

#Route53 (PUBLIC) DNS domain related specifications (domain registrar: aws/others, registered: yes/no)
domain_info = {
  domain_registrar = "others", # alternate option: aws
  domain_name: "aaisdirect.com", #primary domain registered
  registered = "yes" #registered already: yes, otherwise: no
  app_sub_domain_name: "dev-openidl" , #subdomain mapped to app eks nlb
  blk_sub_domain_names: ["orderer0","orderer1", "orderer2", "aais-peer", "aais-ca"] #list of subdomain names mapped to blk eks nlb
  comments: "aais node public name resolutions"
}
#Route53 (PRIVATE) DNS resolution related specifications
#internal name resolution required for blockchain vpc NLB
internal_domain = "internal.aaisdirect.com" #internal domain name for internal name resolution within vpcs
internal_subdomain = ["orderer0", "orderer1", "orderer2", "aais-peer", "aais-ca"] #list of subdomains for internal resolution within vpcs

#-------------------------------------------------------------------------------------------------------------------

#Transit gateway  specifications
tgw_amazon_side_asn = "64532" #default is 64532.
# routes from application cluster private subnets to other vpc private subnet cidrs (TGW route table updates)
app_tgw_routes = [{destination_cidr_block = "172.21.0.0/16"}]

#routes from blockchain cluster private subnets to other vpc private subnet cidrs (TGW route table updates)
blk_tgw_routes = [{destination_cidr_block = "172.20.0.0/16"}]

#routes from application cluster private subnets to other vpc private subnet cidrs (subnet route table updates)
app_tgw_destination_cidr = ["172.21.0.0/16"]

#routes from blockchain cluster private subnets to other vpc private subnet cidrs (subnet route table updates)
blk_tgw_destination_cidr = ["172.20.0.0/16"]

#--------------------------------------------------------------------------------------------------------------------

#Cognito specifications
userpool_name                = "openidl-pool"
client_app_name              = "openidl-client"
client_callback_urls         = ["https://dev-openidl.aaisdirect.com/callback", "https://dev-openidl.aaisdirect.com/redirect"]
client_default_redirect_url  = "https://dev-openidl.aaisdirect.com/redirect"
client_logout_urls           = ["https://dev-openidl.aaisdirect.com/signout"]
cognito_domain               = "aaisdirect"
#--------------------------------------------------------------------------------------------------------------------

#application specific traffic to be allowed in app cluster worker nodes
app_eks_workers_app_sg_ingress = [
  {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    description = "inbound https traffic"
    cidr_blocks = "172.20.0.0/16"
  },
   {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    description = "inbound https traffic"
    cidr_blocks = "172.21.0.0/16"
}]
app_eks_workers_app_sg_egress = [{rule = "all-all"}]

#application specific traffic to be allowed in blk cluster worker nodes
blk_eks_workers_app_sg_ingress = [
  {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    description = "inbound https traffic"
    cidr_blocks = "172.21.0.0/16"
  },
   {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    description = "inbound https traffic"
    cidr_blocks = "172.20.0.0/16"
}]
blk_eks_workers_app_sg_egress = [{rule = "all-all"}]
#--------------------------------------------------------------------------------------------------------------------

# application cluster EKS specifications
app_cluster_name              = "app-cluster"
app_cluster_version           = "1.19"
app_cluster_service_ipv4_cidr = "172.23.0.0/16"
#--------------------------------------------------------------------------------------------------------------------

# blockchain cluster EKS specifications
blk_cluster_name              = "blk-cluster"
blk_cluster_version           = "1.19"
blk_cluster_service_ipv4_cidr = "172.24.0.0/16"
#--------------------------------------------------------------------------------------------------------------------
#cloudtrail related
cw_logs_retention_period = 90
s3_bucket_name_cloudtrail = "cloudtrail-aais-sandbox"
