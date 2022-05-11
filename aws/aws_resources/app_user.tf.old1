#IAM user specific to openIDL application purpose
resource "aws_iam_user" "openidl_apps_user" {
  name = "${local.std_name}-openidl-apps-user"
  force_destroy = true
  tags = merge(local.tags, { name = "${local.std_name}-openidl-apps-user", cluster_type = "application" })
}
resource "aws_iam_access_key" "openidl_apps_user_access_key" {
  user = aws_iam_user.openidl_apps_user.name
  status = "Active"
  lifecycle {
    ignore_changes = [status]
  }
}
resource "aws_iam_user_policy" "openidl_apps_user_policy" {
  name = "${local.std_name}-openidl-apps-user-policy"
  user = aws_iam_user.openidl_apps_user.name
  policy = var.org_name == "aais" ? jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "ListBucket",
            "Effect": "Allow",
            "Action": "s3:ListAllMyBuckets",
            "Resource": "*"
        },
        {
            "Sid": "AllowKMS",
            "Effect": "Allow",
            "Action": [
                "kms:Decrypt",
                "kms:Encrypt",
                "kms:DescribeKey"
            ],
            "Resource": "*"
        },
        {
            "Sid": "GetAllowPublicBucket",
            "Effect": "Allow",
            "Action": "s3:GetObject",
            "Resource": [
                "arn:aws:s3:::${local.std_name}-${var.s3_bucket_name_logos}",
                "arn:aws:s3:::${local.std_name}-${var.s3_bucket_name_logos}/*"
            ]
        },
        {
          "Sid": "AllowCognito",
          "Effect": "Allow",
          "Action": "cognito-idp:*",
          "Resource": var.create_cognito_userpool ? "${aws_cognito_user_pool.user_pool[0].arn}" :  "arn:aws:cognito-idp:${var.aws_region}:${var.aws_account_number}:userpool/null"
        },
        {
          "Sid": "AllowSecretsManager",
          "Effect": "Allow",
          "Action": [
            "secretsmanager:GetSecretValue",
            "secretsmanager:DescribeSecret",
          ],
          "Resource": ["arn:aws:secretsmanager:${var.aws_region}:${var.aws_account_number}:secret:${var.org_name}-${var.aws_env}-kvs-vault-??????"]
        }
    ]
  }) : jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "ListBucket",
            "Effect": "Allow",
            "Action": "s3:ListAllMyBuckets",
            "Resource": "*"
        },
        {
            "Sid": "GetPutAllowHDS",
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
            "Resource": "*"
        },
        {
            "Sid": "GetAllowPublicBucket",
            "Effect": "Allow",
            "Action": "s3:GetObject",
            "Resource": [
                "arn:aws:s3:::${local.std_name}-${var.s3_bucket_name_logos}",
                "arn:aws:s3:::${local.std_name}-${var.s3_bucket_name_logos}/*"
            ]
        },
        {
          "Sid": "AllowCognito",
          "Effect": "Allow",
          "Action": "cognito-idp:*",
          "Resource": var.create_cognito_userpool ? "${aws_cognito_user_pool.user_pool[0].arn}" : "arn:aws:cognito-idp:${var.aws_region}:${var.aws_account_number}:userpool/null"
        },
        {
          "Sid": "AllowSecretsManager",
          "Effect": "Allow",
          "Action": [
            "secretsmanager:GetSecretValue",
            "secretsmanager:DescribeSecret",
          ],
          "Resource": ["arn:aws:secretsmanager:${var.aws_region}:${var.aws_account_number}:secret:${var.org_name}-${var.aws_env}-kvs-vault-??????"]
        }
    ]
  })
}
