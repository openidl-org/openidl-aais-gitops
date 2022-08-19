
data "archive_file" "etl_intake_processor_zip" {
  type = "zip"
  source_dir = "./resources/openidl-etl-intake-processor/"
  output_path = "./resources/openidl-etl-intake-processor.zip"
  depends_on = [local_file.config_intake]
}
data "archive_file" "etl_success_processor_zip" {
  type = "zip"
  source_dir = "./resources/openidl-etl-success-processor/"
  output_path = "./resources/openidl-etl-success-processor.zip"
  depends_on = [local_file.config_success]
}
data "archive_file" "upload_zip" {
  type = "zip"
  source_dir = "./resources/openidl-upload-lambda/"
  output_path = "./resources/openidl-upload-lambda.zip"
}
#Reading IAM identities required
data "aws_iam_user" "terraform_user" {
  user_name = local.terraform_user_name[1]
}
data "aws_iam_role" "terraform_role" {
  name = local.terraform_role_name[1]
}
#AMI for the bastion host, this identifies the filtered AMI from the region
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
#AMI used for EKS worker nodes, this identifies the filtered AMI from the region
data "aws_ami" "eks_app_worker_nodes_ami" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amazon-eks-node-${var.app_cluster_version}-v*"]
  }
}
data "aws_ami" "eks_blk_worker_nodes_ami" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amazon-eks-node-${var.blk_cluster_version}-v*"]
  }
}
#Reading IAM identity
data "aws_caller_identity" "current" {
}
#Reading application cluster info
data "aws_eks_cluster" "app_eks_cluster" {
  name = module.app_eks_cluster.cluster_id
  depends_on = [module.app_eks_cluster.cluster_id]
}
data "aws_eks_cluster_auth" "app_eks_cluster_auth" {
  depends_on = [data.aws_eks_cluster.app_eks_cluster]
  name       = module.app_eks_cluster.cluster_id
}
#Reading blockchain cluster info
data "aws_eks_cluster" "blk_eks_cluster" {
  name = module.blk_eks_cluster.cluster_id
  depends_on = [module.blk_eks_cluster.cluster_id]
}
data "aws_eks_cluster_auth" "blk_eks_cluster_auth" {
  depends_on = [data.aws_eks_cluster.blk_eks_cluster]
  name       = module.blk_eks_cluster.cluster_id
}
#Reading existing VPC
data "aws_vpc" "vpc" {
  count = var.create_vpc ? 0 : 1
  id = var.vpc_id
}
#Reading availability zones
data "aws_availability_zones" "vpc_azs" {
  state = "available"
}
#Reading application cluster public subnets
data "aws_subnet_ids" "vpc_public_subnets" {
  vpc_id     = var.create_vpc ? module.vpc[0].vpc_id : data.aws_vpc.vpc[0].id
 # filter {
 #   name   = "cidr"
 #   values = var.public_subnets
 # }
  tags = {
    tier = "public"
  }
}
#Reading application cluster private subnets
data "aws_subnet_ids" "vpc_private_subnets" {
  vpc_id     = var.create_vpc ? module.vpc[0].vpc_id : data.aws_vpc.vpc[0].id
 # filter {
 #   name   = "cidr"
 #   values = var.private_subnets
 # }
  tags = {
    tier = "private"
  }
}
#Reading private route tables
data "aws_route_tables" "vpc_private_rt" {
  count = var.create_vpc ? 0 : 1
  vpc_id = var.vpc_id
  filter {
    name = "tag:tier"
    values = ["private"]
  }
}
#IAM policy for cloudtrail
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
#IAM policy for cloudtrail cloudwatch logs
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
#IAM policy for KMS related to cloudtrail
data "aws_iam_policy_document" "cloudtrail_kms_policy_doc" {
  statement {
    sid     = "Enable Read Permissions"
    effect  = "Allow"
    actions = ["kms:List*", "kms:Describe*", "kms:Get*"]
    principals {
      type = "AWS"
      identifiers = ["arn:aws:iam::${var.aws_account_number}:root"]
    }
    resources = ["*"]
  }
  statement {
    sid     = "Enable IAM User Administrator Permissions"
    effect  = "Allow"
    actions = ["kms:*"]
    principals {
      type = "AWS"
      identifiers = ["${var.aws_role_arn}"]
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
      identifiers = ["arn:aws:iam::${var.aws_account_number}:root", "${var.aws_role_arn}"]
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
      identifiers = ["${var.aws_role_arn}"]
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
      identifiers = ["${var.aws_role_arn}"]
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
