resource "aws_s3_bucket" "s3_bucket_etl" {
  for_each = var.s3_bucket_names_etl
    bucket = "${local.std_name}-${each.value}"
    acl    = "private"
    force_destroy = true
    versioning {
      enabled = true
    }
    tags = merge(
     local.tags,
      {
        "name" = "${local.std_name}-${each.value}"
      },)
    server_side_encryption_configuration {
      rule {
        apply_server_side_encryption_by_default {
          sse_algorithm     = "aws:kms"
          kms_master_key_id = var.create_kms_keys ? aws_kms_key.s3_kms_key[0].id : var.s3_kms_key_arn
        }
      }
    }
    logging {
      target_bucket = aws_s3_bucket.s3_bucket_access_logs.id
      target_prefix = "logs-${each.value}/"
    }
    lifecycle_rule {
      enabled = false
      #prefix = ""
      transition {
        days = "90"
        storage_class = "STANDARD_IA"
      }
      transition {
        days = "180"
        storage_class = "GLACIER"
      }
      expiration {
        days = "365"
      }
      noncurrent_version_transition {
        days = "90"
        storage_class = "GLACIER"
      }
      noncurrent_version_expiration {
        days = "180"
      }
    }
}
resource "aws_s3_bucket_public_access_block" "s3_bucket_public_access_block_etl" {
  for_each = var.s3_bucket_names_etl
    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
    bucket                  = aws_s3_bucket.s3_bucket_etl[each.key].id
}
resource "aws_s3_bucket_policy" "s3_bucket_policy_etl" {
  for_each = var.s3_bucket_names_etl
    bucket     = "${local.std_name}-${each.value}"
    policy = jsonencode({
      "Version": "2012-10-17",
      "Statement": [
          {
            "Sid": "AllowGetAndPutObjects",
            "Effect": "Allow",
            "Principal": {
                "AWS": ["${aws_iam_role.openidl_apps_iam_role.arn}", "${aws_iam_user.openidl_apps_user.arn}"]
            },
            "Action": [
                "s3:GetObject",
                "s3:PutObject",
                "s3:AbortMultipartUpload",
                "s3:RestoreObject",
                "s3:DeleteObject",
                "s3:ListMultipartUploadParts",
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::${local.std_name}-${each.value}",
                "arn:aws:s3:::${local.std_name}-${each.value}/*"
            ]
          },
          {
            "Sid": "AllowAccessIAMRole",
            "Effect": "Allow",
            "Principal": {
                "AWS": "${var.aws_role_arn}"
            },
            "Action": "*",
            "Resource": [
                "arn:aws:s3:::${local.std_name}-${each.value}",
                "arn:aws:s3:::${local.std_name}-${each.value}/*"
            ]
          },
          {
            "Sid": "HTTPRestrict",
            "Effect": "Deny",
            "Principal": "*",
            "Action": "s3:*",
            "Resource": ["arn:aws:s3:::${local.std_name}-${each.value}/*", "arn:aws:s3:::${local.std_name}-${each.value}" ],
            "Condition": {
                "Bool": {
                    "aws:SecureTransport" = "false"
                }
            }
          },
          {
			"Sid": "DenyOthers",
			"Effect": "Deny",
			"Principal": "*",
            "Action": "*",
			"Resource": [
                "arn:aws:s3:::${local.std_name}-${each.value}",
                "arn:aws:s3:::${local.std_name}-${each.value}/*"
            ],
			"Condition": {
				"StringNotLike": {
					"aws:userid": [
                        "${aws_iam_role.openidl_apps_iam_role.unique_id}:*",
                        "${aws_iam_user.openidl_apps_user.unique_id}",
                        "${data.aws_iam_role.terraform_role.unique_id}:*",
						"${var.aws_account_number}",
                        "arn:aws:sts:::${var.aws_account_number}:assumed-role/${local.terraform_role_name[1]}/terraform",
                        "arn:aws:sts:::${var.aws_account_number}:assumed-role/${aws_iam_role.openidl_apps_iam_role.name}/openidl"

					]
				}
			}
		  }
      ]
})
}

