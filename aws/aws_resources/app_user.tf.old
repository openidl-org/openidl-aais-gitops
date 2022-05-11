#IAM user for openidl application configuration
resource "aws_iam_user" "openidl_apps_user" {
  name = "${local.std_name}-openidl-apps-user"
  force_destroy = true
  tags = merge(local.tags, { Name = "${local.std_name}-openidl-apps-user", Cluster_type = "both" })
}
resource "aws_iam_access_key" "openidl_apps_access_key" {
  user = aws_iam_user.openidl_apps_user.name
  status = "Active"
  lifecycle {
    ignore_changes = [status]
  }
}
resource "aws_iam_user_policy" "openidl_nonaais_apps_user_policy" {
  count = var.org_name == "aais" ? 0 : 1
  name = "${local.std_name}-openidl-apps-user-policy"
  user = aws_iam_user.openidl_apps_user.name
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
          "Resource": "${aws_cognito_user_pool.user_pool.arn}"
        },
        {
          "Sid": "AllowSecretsManager",
          "Effect": "Allow",
          "Action": [
            "secretsmanager:GetSecretValue",
            "secretsmanager:DescribeSecret",
          ],
          "Resource": "*"
        }
    ]
  })
}
resource "aws_iam_user_policy" "openidl_aais_apps_user_policy" {
  count = var.org_name == "aais" ? 1 : 0
  name = "${local.std_name}-openidl-apps-user-policy"
  user = aws_iam_user.openidl_apps_user.name
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
          "Resource": "${aws_cognito_user_pool.user_pool.arn}"
        },
        {
          "Sid": "AllowSecretsManager",
          "Effect": "Allow",
          "Action": [
            "secretsmanager:GetSecretValue",
            "secretsmanager:DescribeSecret",
          ],
          "Resource": "*"
        }
    ]
  })
}