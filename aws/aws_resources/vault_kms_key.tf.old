#kms key for hcp vault cluster unseal
resource "aws_kms_key" "vault_kms_key" {
  description             = "The KMS key for vault cluster"
  deletion_window_in_days = 7
  key_usage               = "ENCRYPT_DECRYPT"
  enable_key_rotation     = true
  policy = jsonencode({
    "Id" : "${local.std_name}-vault-kmskey-policy",
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "EnableIAMUserPermissions",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::${var.aws_account_number}:root"
        },
        "Action" : "kms:*",
        "Resource" : "*"
      },
      {
        "Sid" : "AllowaccessforKeyAdministrators",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : ["${var.aws_role_arn}", aws_iam_role.git_actions_admin_role.arn, aws_iam_role.eks_nodegroup_role["app-node-group"].arn, aws_iam_role.eks_nodegroup_role["blk-node-group"].arn ]
        },
        "Action" : [
          "kms:Create*",
          "kms:Describe*",
          "kms:Enable*",
          "kms:List*",
          "kms:Put*",
          "kms:Update*",
          "kms:Revoke*",
          "kms:Disable*",
          "kms:Get*",
          "kms:Delete*",
          "kms:TagResource",
          "kms:UntagResource",
          "kms:ScheduleKeyDeletion",
          "kms:CancelKeyDeletion",
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        "Resource" : "*"
      },
      {
        "Sid" : "Allowattachmentofpersistentresources",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : ["${var.aws_role_arn}", aws_iam_role.git_actions_admin_role.arn, aws_iam_role.eks_nodegroup_role["app-node-group"].arn, aws_iam_role.eks_nodegroup_role["blk-node-group"].arn ]
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
      "Name"         = "${local.std_name}-vault-kmskey"
      "Cluster_type" = "both"
  }, )
}
resource "aws_kms_alias" "vault_kms_key_alias" {
  name          = "alias/${local.std_name}-vault-kmskey"
  target_key_id = aws_kms_key.vault_kms_key.id
}
