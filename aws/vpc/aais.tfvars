#set org name as below
#when nodetype is aais set org_name="aais"
#when nodetype is analytics set org_name="analytics"
#when nodetype is aais's dummy carrier set org_name="carrier" and for other carriers refer to next line.
#when nodetype is other carrier set org_name="<carrier_org_name>" , example: org_name = "travelers" etc.,

ses_email_identity = ""
userpool_email_source_arn = ""
app_cluster_map_users = []
blk_cluster_map_users = []
app_cluster_map_roles = []
blk_cluster_map_roles = []


org_name = "aais" #Its an example
aws_env = "dev" #set to dev|test|prod

#--------------------------------------------------------------------------------------------------------------------
create_vpc = "true"

vpc_cidr           = "172.18.0.0/16"
availability_zones = ["us-east-2a", "us-east-2b", "us-east-2c"]
public_subnets     = ["172.18.1.0/24", "172.18.2.0/24", "172.18.5.0/24"]
private_subnets    = ["172.18.3.0/24", "172.18.4.0/24", "172.18.6.0/24"]
