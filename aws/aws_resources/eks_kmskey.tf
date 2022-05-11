#KMS key for application cluster and blockchain cluster encryption
resource "aws_kms_key" "eks_kms_key" {
  count = var.create_kms_keys ? 1 : 0
  #for_each = {for k in ["app-eks", "blk-eks"] : k => k if var.create_kms_keys }
  description             = "The KMS key for ${var.org_name}-${var.aws_env}-eks-key"
  deletion_window_in_days = 30
  key_usage               = "ENCRYPT_DECRYPT"
  enable_key_rotation     = true
  policy = jsonencode({
    "Id" : "${local.std_name}-eks-key",
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
              "AWS" : "${var.aws_role_arn}"
        },
            "Action" : "*"
            "Resource" : "*"
      },
      {
            "Sid" : "Allow attachment of persistent resources",
            "Effect" : "Allow",
            "Principal" : {
                "AWS" : "${var.aws_role_arn}"
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
              "Service" : "logs.${var.aws_region}.amazonaws.com"
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
      "name"         = "${local.std_name}-EKSClusters"
      "cluster_type" = "both"
  }, )
}
resource "aws_kms_alias" "eks_kms_key_alias" {
  count = var.create_kms_keys ? 1 : 0
  #for_each = {for k in ["app-eks", "blk-eks"] : k => k if var.create_kms_keys }
  name          = "alias/${local.std_name}-eks-key"
  #target_key_id = aws_kms_key.eks_kms_key["${each.value}"].id
  target_key_id = aws_kms_key.eks_kms_key[0].id
}