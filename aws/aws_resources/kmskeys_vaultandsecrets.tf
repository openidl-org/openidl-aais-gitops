#KMS key for hcp vault cluster unseal
resource "aws_kms_key" "vault_kms_key" {
  count = var.create_kms_keys ? 1 : 0
  description             = "The KMS key used for vault cluster"
  deletion_window_in_days = 30
  key_usage               = "ENCRYPT_DECRYPT"
  enable_key_rotation     = true
  policy = jsonencode({
    "Id" : "${local.std_name}-vault-kmskey",
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
          "Sid" : "Allow access for Key Administrators",
          "Effect" : "Allow",
          "Principal" : {
            "AWS" : ["${var.aws_role_arn}"]
          },
          "Action" : "*",
          "Resource" : "*"
      },
      {
          "Sid": "Allow use of the key",
          "Effect": "Allow",
          "Principal": {
            "AWS": ["${var.aws_role_arn}", aws_iam_role.baf_user_role.arn, aws_iam_role.git_actions_admin_role.arn, aws_iam_role.eks_nodegroup_role["app-node-group"].arn, aws_iam_role.eks_nodegroup_role["blk-node-group"].arn ]
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
        "Sid" : "Allow attachment of persistent resources",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : ["${var.aws_role_arn}", aws_iam_role.baf_user_role.arn, aws_iam_role.git_actions_admin_role.arn, aws_iam_role.eks_nodegroup_role["app-node-group"].arn, aws_iam_role.eks_nodegroup_role["blk-node-group"].arn ]
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
      }
    ]
  })
  tags = merge(
    local.tags,
    {
      "name"         = "${local.std_name}-vault-kmskey"
      "cluster_type" = "both"
  }, )
}
resource "aws_kms_alias" "vault_kms_key_alias" {
  count = var.create_kms_keys ? 1 : 0
  name          = "alias/${local.std_name}-vault-kmskey"
  target_key_id = aws_kms_key.vault_kms_key[0].id
}
#KMS key for AWS secrets
resource "aws_kms_key" "sm_kms_key" {
  count = var.create_kms_keys ? 1 : 0
  description             = "The KMS key used for AWS secrets"
  deletion_window_in_days = 30
  key_usage               = "ENCRYPT_DECRYPT"
  enable_key_rotation     = true
  policy = jsonencode({
    "Id" : "${local.std_name}-secrets-kmskey",
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
          "Sid" : "Allow access for Key Administrators",
          "Effect" : "Allow",
          "Principal" : {
            "AWS" : ["${var.aws_role_arn}"]
          },
          "Action" : "*",
          "Resource" : "*"
      },
      {
          "Sid": "Allow use of the key",
          "Effect": "Allow",
          "Principal": {
            "AWS": ["${var.aws_role_arn}", aws_iam_role.baf_user_role.arn, aws_iam_role.git_actions_admin_role.arn, aws_iam_role.openidl_apps_iam_role.arn]
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
        "Sid" : "Allow attachment of persistent resources",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : ["${var.aws_role_arn}", aws_iam_role.baf_user_role.arn, aws_iam_role.git_actions_admin_role.arn, aws_iam_role.openidl_apps_iam_role.arn ]
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
      }
    ]
  })
  tags = merge(
    local.tags,
    {
      "name"         = "${local.std_name}-secrets-kmskey"
      "cluster_type" = "both"
  }, )
}
resource "aws_kms_alias" "sm_kms_key_alias" {
  count = var.create_kms_keys ? 1 : 0
  name          = "alias/${local.std_name}-secrets-kmskey"
  target_key_id = aws_kms_key.sm_kms_key[0].id
}