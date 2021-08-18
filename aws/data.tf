#AMI used with bastion host, this identifies the filtered ami from the region
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name = "name"
    values = [
      "amzn-ami-hvm-*-x86_64-gp2",
    ]
  }
  filter {
    name = "owner-alias"
    values = [
      "amazon",
    ]
  }
}
#AMI used with eks worker nodes, this identifies the filtered ami from the region
data "aws_ami" "eks_app_worker_nodes_ami" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name = "name"
    values = ["amazon-eks-node-${var.app_cluster_version}-v*"]
  }
}
data "aws_ami" "eks_blk_worker_nodes_ami" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name = "name"
    values = ["amazon-eks-node-${var.blk_cluster_version}-v*"]
  }
}
#extracting zone info if the domain is already registered in aws
data "aws_route53_zone" "data_zones" {
  count = (lookup(var.domain_info, "registered") == "yes" && lookup(var.domain_info, "domain_registrar") == "aws") ? 1 : 0
  name  = lookup(var.domain_info, "domain_name")
}
#reading identifying iam identity
data "aws_caller_identity" "current" {
}
#reading application cluster info
data "aws_eks_cluster" "app_eks_cluster" {
  name = module.app_eks_cluster.cluster_id
}
data "aws_eks_cluster_auth" "app_eks_cluster_auth" {
  depends_on = [data.aws_eks_cluster.app_eks_cluster]
  name       = module.app_eks_cluster.cluster_id
}
#reading blockchain cluster info
data "aws_eks_cluster" "blk_eks_cluster" {
  name = module.blk_eks_cluster.cluster_id
}
data "aws_eks_cluster_auth" "blk_eks_cluster_auth" {
  depends_on = [data.aws_eks_cluster.blk_eks_cluster]
  name       = module.blk_eks_cluster.cluster_id
}
#reading availability zones
data "aws_availability_zones" "app_vpc_azs" {
  state = "available"
}
#reading application cluster public subnets
data "aws_subnet_ids" "app_vpc_public_subnets" {
  depends_on = [module.aais_app_vpc]
  vpc_id     = module.aais_app_vpc.vpc_id
  filter {
    name   = "cidr"
    values = var.app_public_subnets
  }
}
#reading application cluster private subnets
data "aws_subnet_ids" "app_vpc_private_subnets" {
  depends_on = [module.aais_app_vpc]
  vpc_id     = module.aais_app_vpc.vpc_id
  filter {
    name   = "cidr"
    values = var.app_private_subnets
  }
}
#reading blockchain cluster public subnets
data "aws_subnet_ids" "blk_vpc_public_subnets" {
  depends_on = [module.aais_blk_vpc]
  vpc_id     = module.aais_blk_vpc.vpc_id
  filter {
    name   = "cidr"
    values = var.blk_public_subnets
  }
}
#reading blockchain cluster private subnets
data "aws_subnet_ids" "blk_vpc_private_subnets" {
  depends_on = [module.aais_blk_vpc]
  vpc_id     = module.aais_blk_vpc.vpc_id
  filter {
    name   = "cidr"
    values = var.blk_private_subnets
  }
}
data "aws_iam_policy_document" "cloudtrail_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
  }
}
data "aws_iam_policy_document" "cloudtrail_cloudwatch_logs" {
  statement {
    sid    = "WriteCloudWatchLogs"
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["arn:aws:logs:${var.aws_region}:${var.aws_account_number}:log-group:${local.std_name}-cloudtrail-logs:*"]
  }
}
data "aws_iam_policy_document" "cloudtrail_kms_policy_doc" {
  statement {
    sid     = "Enable IAM User Permissions"
    effect  = "Allow"
    actions = ["kms:*"]

    principals {
      type = "AWS"

      identifiers = ["arn:aws:iam::${var.aws_account_number}:root"]
    }

    resources = ["*"]
  }

  statement {
    sid     = "Allow CloudTrail to encrypt logs"
    effect  = "Allow"
    actions = ["kms:GenerateDataKey*"]

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    resources = ["*"]

    condition {
      test     = "StringLike"
      variable = "kms:EncryptionContext:aws:cloudtrail:arn"
      values   = ["arn:aws:cloudtrail:*:${var.aws_account_number}:trail/*"]
    }
  }

  statement {
    sid     = "Allow CloudTrail to describe key"
    effect  = "Allow"
    actions = ["kms:DescribeKey"]

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    resources = ["*"]
  }

  statement {
    sid    = "Allow principals in the account to decrypt log files"
    effect = "Allow"

    actions = [
      "kms:Decrypt",
      "kms:ReEncryptFrom",
    ]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "kms:CallerAccount"
      values   = ["${var.aws_account_number}"]
    }

    condition {
      test     = "StringLike"
      variable = "kms:EncryptionContext:aws:cloudtrail:arn"
      values   = ["arn:aws:cloudtrail:*:${var.aws_account_number}:trail/*"]
    }
  }

  statement {
    sid     = "Allow alias creation during setup"
    effect  = "Allow"
    actions = ["kms:CreateAlias"]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"
      values   = ["ec2.${var.aws_region}.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "kms:CallerAccount"
      values   = ["${var.aws_account_number}"]
    }

    resources = ["*"]
  }

  statement {
    sid    = "Enable cross account log decryption"
    effect = "Allow"

    actions = [
      "kms:Decrypt",
      "kms:ReEncryptFrom",
    ]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    condition {
      test     = "StringEquals"
      variable = "kms:CallerAccount"
      values   = ["${var.aws_account_number}"]
    }

    condition {
      test     = "StringLike"
      variable = "kms:EncryptionContext:aws:cloudtrail:arn"
      values   = ["arn:aws:cloudtrail:*:${var.aws_account_number}:trail/*"]
    }

    resources = ["*"]
  }

  statement {
    sid    = "Allow logs KMS access"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["logs.${var.aws_region}.amazonaws.com"]
    }

    actions = [
      "kms:Encrypt*",
      "kms:Decrypt*",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Describe*"
    ]
    resources = ["*"]
  }
}
