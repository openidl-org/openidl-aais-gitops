#creating an s3 bucket for HDS data extract for analytics node
resource "aws_s3_bucket" "s3_bucket_hds" {
  count = var.org_name == "aais" ? 0 : 1
  bucket = "${local.std_name}-${var.s3_bucket_name_hds_analytics}"
  acl    = "private"
  force_destroy = true
  versioning {
    enabled = true
  }
  tags = merge(
    local.tags,
    {
      "Name" = "${local.std_name}-${var.s3_bucket_name_hds_analytics}"
    },)
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "aws:kms"
        kms_master_key_id = aws_kms_key.s3_kms_key_hds[0].id
      }
    }
  }
}
#blocking public access to s3 bucket used for HDS data extract for analytics node
resource "aws_s3_bucket_public_access_block" "s3_bucket_public_access_block_hds" {
  count = var.org_name == "aais" ? 0 : 1
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  bucket                  = aws_s3_bucket.s3_bucket_hds[0].id
  depends_on              = [aws_s3_bucket.s3_bucket_hds, aws_s3_bucket_policy.s3_bucket_policy_hds]
}
#setting up a bucket policy to restrict access to s3 bucket used for HDS data extract for analytics node
resource "aws_s3_bucket_policy" "s3_bucket_policy_hds" {
  count = var.org_name == "aais" ? 0 : 1
  bucket     = "${local.std_name}-${var.s3_bucket_name_hds_analytics}"
  depends_on = [aws_s3_bucket.s3_bucket_hds]
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowGetAndPutObjects",
            "Effect": "Allow",
            "Principal": {
                "AWS": "${aws_iam_user.hds_user[0].arn}"
            },
            "Action": [
                "s3:GetObject",
                "s3:PutObject",
                "s3:AbortMultipartUpload",
                "s3:RestoreObject",
                "s3:DeleteObject",
                "s3:ListMultipartUploadParts"
            ],
            "Resource": [
                "arn:aws:s3:::${local.std_name}-${var.s3_bucket_name_hds_analytics}",
                "arn:aws:s3:::${local.std_name}-${var.s3_bucket_name_hds_analytics}/*"
            ]
        },
      {
        Sid       = "HTTPRestrict"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = "arn:aws:s3:::${local.std_name}-${var.s3_bucket_name_hds_analytics}/*",
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
})
}
#creating kms key that is used to encrypt data at rest in S3 bucket used for HDS data extract for analytics node
resource "aws_kms_key" "s3_kms_key_hds" {
  count = var.org_name == "aais" ? 0 : 1
  description             = "The kms key for s3 bucket used for HDS"
  deletion_window_in_days = 30
  key_usage               = "ENCRYPT_DECRYPT"
  enable_key_rotation     = true
  tags = merge(
    local.tags,
    {
      "Name" = "s3-bucket-hds-kms-key"
    },)
  policy = jsonencode({
    "Id" : "${local.std_name}-${var.s3_bucket_name_hds_analytics}",
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
          "AWS" : "${var.aws_role_arn}"
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
        "Sid" : "EnableAccess",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "${aws_iam_user.hds_user[0].arn}"
        },
        "Action" : [
			"kms:Encrypt",
			"kms:Decrypt",
			"kms:DescribeKey"
		],
        "Resource" : "*"
    },
      {
        "Sid" : "Allowattachmentofpersistentresources",
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
      }
    ]
  })
}
#setting up an alias for the kms key used with s3 bucket data encryption which is used for HDS data extract for analytics node
resource "aws_kms_alias" "kms_alias_hds" {
  count = var.org_name == "aais" ? 0 : 1
  name          = "alias/${local.std_name}-${var.s3_bucket_name_hds_analytics}"
  target_key_id = aws_kms_key.s3_kms_key_hds[0].id
}
#IAM user and relevant credentials used for S3 bucket access which is used for HDS data extract for analytics node
resource "aws_iam_user" "hds_user" {
  count = var.org_name == "aais" ? 0 : 1
  name = "${local.std_name}-hds-user"
  force_destroy = true
  tags = merge(local.tags, { Name = "${local.std_name}-hds-user", Cluster_type = "both" })
}
resource "aws_iam_access_key" "hds_user_access_key" {
  count = var.org_name == "aais" ? 0 : 1
  user = aws_iam_user.hds_user[0].name
  status = "Active"
  lifecycle {
    ignore_changes = [status]
  }
}
resource "aws_iam_user_policy" "hds_user_policy" {
  count = var.org_name == "aais" ? 0 : 1
  name = "${local.std_name}-hds-user-policy"
  user = aws_iam_user.hds_user[0].name
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "ListBucket",
            "Effect": "Allow",
            "Action": "s3:ListAllMyBuckets",
            "Resource": "*"
        },
        {
            "Sid": "GetPutAllow",
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:PutObject",
                "s3:AbortMultipartUpload",
                "s3:RestoreObject",
                "s3:DeleteObject",
                "s3:ListMultipartUploadParts"
            ],
            "Resource": [
                "arn:aws:s3:::${local.std_name}-${var.s3_bucket_name_hds_analytics}",
                "arn:aws:s3:::${local.std_name}-${var.s3_bucket_name_hds_analytics}/*",
            ]
        },
        {
            "Sid": "AllowKMS",
            "Effect": "Allow",
            "Action": [
                "kms:Decrypt",
                "kms:Encrypt",
                "kms:DescribeKey"
            ],
            "Resource": [
                "${aws_kms_key.s3_kms_key_hds[0].arn}"
            ]
        }
    ]
  })
}

