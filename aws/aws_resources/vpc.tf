#Creating required VPC
module "vpc" {
  count = var.create_vpc ? 1 : 0
  create_vpc      = true
  source          = "terraform-aws-modules/vpc/aws"
  name            = "${local.std_name}-vpc"
  cidr            = var.vpc_cidr
  azs             = var.availability_zones
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway     = true
  single_nat_gateway     = false
  one_nat_gateway_per_az = true
  enable_dns_hostnames   = true
  enable_dns_support     = true
  enable_dhcp_options    = true
  enable_ipv6            = false

  manage_default_network_acl    = false
  default_security_group_name   = "${local.std_name}-vpc-default-sg"
  manage_default_security_group = true
  manage_default_route_table    = true
  public_dedicated_network_acl  = false
  private_dedicated_network_acl = false

  default_network_acl_ingress    = var.default_nacl_rules["inbound"]
  default_network_acl_egress     = var.default_nacl_rules["outbound"]
  public_inbound_acl_rules       = var.public_nacl_rules["inbound"]
  public_outbound_acl_rules      = var.public_nacl_rules["outbound"]
  private_inbound_acl_rules      = var.private_nacl_rules["inbound"]
  private_outbound_acl_rules     = var.private_nacl_rules["outbound"]
  default_security_group_egress  = local.def_sg_egress
  default_security_group_ingress = local.def_sg_ingress

  enable_flow_log                      = true
  flow_log_destination_type            = "cloud-watch-logs"
  flow_log_cloudwatch_log_group_kms_key_id = var.create_kms_keys ? aws_kms_key.vpc_flow_logs_kms_key[0].arn : var.vpc_flow_logs_kms_key_arn
  flow_log_cloudwatch_log_group_name_prefix = "/aws/vpc-flow-log/"
  flow_log_cloudwatch_log_group_retention_in_days = var.cw_logs_retention_period
  vpc_flow_log_tags = merge(local.tags, { name = "vpc-flow-logs-cw-logs"})
  create_flow_log_cloudwatch_log_group = true
  create_flow_log_cloudwatch_iam_role  = true
  flow_log_max_aggregation_interval    = 60

  private_route_table_tags       = merge(local.tags, { tier = "private"})
  public_route_table_tags        = merge(local.tags, { tier = "public" })
  default_route_table_tags       = merge(local.tags, { DefaultRouteTable = true })
  tags                           = merge(local.tags, { "cluster_type" = "both" })
  vpc_tags                       = merge(local.tags, { "cluster_type" = "both" })
  public_subnet_tags = merge(local.tags, {
    "kubernetes.io/cluster/${local.app_cluster_name}" = "shared"
    "kubernetes.io/cluster/${local.blk_cluster_name}" = "shared"
    "kubernetes.io/role/elb"                          = "1"
    "cluster_type"                                    = "both"
    "tier"                                            = "public"
  })
  private_subnet_tags = merge(local.tags, {
    "kubernetes.io/cluster/${local.app_cluster_name}" = "shared"
    "kubernetes.io/cluster/${local.blk_cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"                 = "1"
    "cluster_type"                                    = "both"
    "tier"                                            = "private"
  })
}
#VPC flow logging related-KMS key
resource "aws_kms_key" "vpc_flow_logs_kms_key" {
  count = var.create_vpc && var.create_kms_keys ? 1 : 0
  description             = "The KMS key for ${var.org_name}-${var.aws_env}-vpc flow logs"
  deletion_window_in_days = 30
  key_usage               = "ENCRYPT_DECRYPT"
  enable_key_rotation     = true
  policy = jsonencode({
    "Id" : "${local.std_name}-vpc-flow-logs-key",
    "Version" : "2012-10-17",
    "Statement" : [
        {
            "Sid": "Enable Read Permissions",
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::${var.aws_account_number}:root"
            },
            "Action": ["kms:List*", "kms:Describe*", "kms:Get*"],
            "Resource": "*"
      },
        {
            "Sid": "Allow use of the key",
            "Effect": "Allow",
            "Principal": {
                "AWS": ["${var.aws_role_arn}"]
            },
            "Action": [
                "kms:Encrypt",
                "kms:Decrypt",
                "kms:ReEncrypt*",
                "kms:GenerateDataKey*",
                "kms:DescribeKey"
            ],
            "Resource": "*"
        },
        {
            "Sid" : "Allow access for Key Administrators",
            "Effect" : "Allow",
            "Principal" : {
              "AWS" : ["${var.aws_role_arn}"]
        },
            "Action" : "*"
            "Resource" : "*"
      },
      {
            "Sid" : "Allow attachment of persistent resources",
            "Effect" : "Allow",
            "Principal" : {
                "AWS" : ["${var.aws_role_arn}"]
            },
            "Action" : [
                "kms:CreateGrant",
                "kms:ListGrants",
                "kms:RevokeGrant"
            ],
            "Resource" : "*",
            "Condition" : {
              "Bool" : {
                  "kms:GrantIsForAWSResource" : "true"
              }
            }
      },
      {
          "Effect" : "Allow",
          "Principal" : {
              "Service" : ["logs.amazonaws.com"]
          },
          "Action" : [
              "kms:Encrypt*",
              "kms:Decrypt*",
              "kms:ReEncrypt*",
              "kms:GenerateDataKey*",
              "kms:Describe*"
            ],
          "Resource" : "*",
          "Condition" : {
              "ArnLike" : {
                  "kms:EncryptionContext:aws:logs:arn": "arn:aws:logs:${var.aws_region}:${var.aws_account_number}:*"
              }
          }
      }
    ]
  })
  tags = merge(
    local.tags,
    {
      "name"         = "${local.std_name}-vpc-flowlogs-key"
      "cluster_type" = "both"
  }, )
}
resource "aws_kms_alias" "vpc_flow_logs_kms_key_alias" {
  count = var.create_vpc && var.create_kms_keys ? 1 : 0
  name          = "alias/${local.std_name}-vpc-flow-logs-key"
  target_key_id = aws_kms_key.vpc_flow_logs_kms_key[0].id
}

