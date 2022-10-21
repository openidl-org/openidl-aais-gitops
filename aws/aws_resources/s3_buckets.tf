#Creating kms key that is used to encrypt data at rest in S3 bucket
resource "aws_kms_key" "s3_kms_key" {
  count = var.create_kms_keys ? 1 : 0
  description             = "The kms key for ${var.org_name}-${var.aws_env}-s3-key"
  deletion_window_in_days = 30
  key_usage               = "ENCRYPT_DECRYPT"
  enable_key_rotation     = true
  tags = merge(
    local.tags,
    {
      "name" = "s3-kms-key"
    },)
  policy = jsonencode({
    "Id": "key-consolepolicy-3",
    "Version": "2012-10-17",
    "Statement": [
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
            "Sid": "Allow access for Key Administrators",
            "Effect": "Allow",
            "Principal": {
                "AWS": ["${var.aws_role_arn}"]
            },
            "Action": "*",
            "Resource": "*"
        },
        {
            "Sid": "Allow use of the key",
            "Effect": "Allow",
            "Principal": {
                "AWS": ["${aws_iam_role.openidl_apps_iam_role.arn}", "${var.aws_role_arn}", "${aws_iam_role.etl_lambda.arn}", "${aws_iam_role.upload.arn}", "${aws_iam_role.reporting_lambda[0].arn}"]
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
            "Sid": "Allow attachment of persistent resources",
            "Effect": "Allow",
            "Principal": {
                "AWS": "${var.aws_role_arn}"
            },
            "Action": [
                "kms:CreateGrant",
                "kms:ListGrants",
                "kms:RevokeGrant"
            ],
            "Resource": "*",
            "Condition": {
                "Bool": {
                    "kms:GrantIsForAWSResource": "true"
                }
            }
        }
    ]
})
}
#Setting up an alias for the kms key used with s3 bucket data encryption
resource "aws_kms_alias" "s3_kms_key_alais" {
  count = var.create_kms_keys ? 1 : 0
  name          = "alias/${local.std_name}-s3-key"
  target_key_id = aws_kms_key.s3_kms_key[0].id
}
#Creating an s3 bucket for HDS data extract for analytics node
resource "aws_s3_bucket" "s3_bucket_hds" {
  count = var.org_name == "aais" ? 1 : 1 #update to 0 : 1
  bucket = "${local.std_name}-${var.s3_bucket_name_hds_analytics}"
  acl    = "private"
  force_destroy = true
  versioning {
    enabled = true
  }
  tags = merge(
    local.tags,
    {
      "name" = "${local.std_name}-${var.s3_bucket_name_hds_analytics}"
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
    target_prefix = "logs-hds/"
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
#Blocking public access to s3 bucket used for HDS data extract for analytics node
resource "aws_s3_bucket_public_access_block" "s3_bucket_public_access_block_hds" {
  count = var.org_name == "aais" ? 0 : 1
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  bucket                  = aws_s3_bucket.s3_bucket_hds[0].id
  depends_on              = [aws_s3_bucket.s3_bucket_hds, aws_s3_bucket_policy.s3_bucket_policy_hds]
}
#Setting up a bucket policy to restrict access to s3 bucket used for HDS data extract for analytics node
resource "aws_s3_bucket_policy" "s3_bucket_policy_hds" {
  count = var.org_name == "aais" ? 0 : 1 #update to 0:1
  bucket     = "${local.std_name}-${var.s3_bucket_name_hds_analytics}"
  depends_on = [aws_s3_bucket.s3_bucket_hds]
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowGetAndPutObjects",
            "Effect": "Allow",
            "Principal": {
                "AWS": ["${aws_iam_role.openidl_apps_iam_role.arn}", "${aws_iam_user.openidl_apps_user.arn}", "${aws_iam_role.reporting_lambda[0].arn}"]
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
                "arn:aws:s3:::${local.std_name}-${var.s3_bucket_name_hds_analytics}",
                "arn:aws:s3:::${local.std_name}-${var.s3_bucket_name_hds_analytics}/*"
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
                "arn:aws:s3:::${local.std_name}-${var.s3_bucket_name_hds_analytics}",
                "arn:aws:s3:::${local.std_name}-${var.s3_bucket_name_hds_analytics}/*"
            ]
        },
        {
            "Sid": "HTTPRestrict",
            "Effect": "Deny",
            "Principal": "*",
            "Action": "s3:*",
            "Resource": ["arn:aws:s3:::${local.std_name}-${var.s3_bucket_name_hds_analytics}/*", "arn:aws:s3:::${local.std_name}-${var.s3_bucket_name_hds_analytics}" ],
            "Condition": {
                "Bool": {
                    "aws:SecureTransport" = "false"
                }
            }
#        },
#        {
#			      "Sid": "DenyOthers",
#			      "Effect": "Deny",
#			      "Principal": "*",
#            "Action": "*",
#			      "Resource": [
#                "arn:aws:s3:::${local.std_name}-${var.s3_bucket_name_hds_analytics}",
#                "arn:aws:s3:::${local.std_name}-${var.s3_bucket_name_hds_analytics}/*"
#            ],
#			      "Condition": {
#				      "StringNotLike": {
#					      "aws:userid": [
#                        "${aws_iam_role.openidl_apps_iam_role.unique_id}:*",
#                        "${aws_iam_user.openidl_apps_user.unique_id}",
#                        "${data.aws_iam_role.terraform_role.unique_id}:*",
#						            "${var.aws_account_number}",
#                        "arn:aws:sts:::${var.aws_account_number}:assumed-role/${local.terraform_role_name[1]}/terraform",
#                        "arn:aws:sts:::${var.aws_account_number}:assumed-role/${aws_iam_role.openidl_apps_iam_role.name}/openidl"
#					      ]
#				      }
#			      }
		    }
    ]
})
}
#Creating an s3 bucket for HDS data extract for analytics node
resource "aws_s3_bucket" "s3_bucket_logos_public" {
  count = var.create_s3_bucket_public ? 1 : 0
  bucket = "${local.std_name}-${var.s3_bucket_name_logos}"
  acl    = "private"
  force_destroy = true
  versioning {
    enabled = false
  }
  tags = merge(
    local.tags,
    {
      "name" = "${local.std_name}-${var.s3_bucket_name_logos}"
    },)
}
#Blocking public access to s3 bucket
resource "aws_s3_bucket_public_access_block" "s3_bucket_logos_public_access_block" {
  count = var.create_s3_bucket_public ? 1 : 0
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
  bucket                  = aws_s3_bucket.s3_bucket_logos_public[0].id
  depends_on              = [aws_s3_bucket.s3_bucket_logos_public, aws_s3_bucket_policy.s3_bucket_logos_policy]
}
#S3 bucket policy for public s3 bucket
resource "aws_s3_bucket_policy" "s3_bucket_logos_policy" {
  count = var.create_s3_bucket_public ? 1 : 0
  bucket     = "${local.std_name}-${var.s3_bucket_name_logos}"
  depends_on = [aws_s3_bucket.s3_bucket_logos_public]
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowPublicAccess",
            "Effect": "Allow",
            "Principal": "*",
            "Action": [ "s3:GetObject", "s3:GetObjectVersion"],
            "Resource": [
                "arn:aws:s3:::${local.std_name}-${var.s3_bucket_name_logos}",
                "arn:aws:s3:::${local.std_name}-${var.s3_bucket_name_logos}/*",

            ]
        },
      {
            "Sid": "AllowIAMAccess",
            "Effect": "Allow",
            "Principal": {
                "AWS": ["${var.aws_role_arn}"]
            },
            "Action": "*",
            "Resource": [
                "arn:aws:s3:::${local.std_name}-${var.s3_bucket_name_logos}",
                "arn:aws:s3:::${local.std_name}-${var.s3_bucket_name_logos}/*",
            ]
        },
        {
        "Sid":  "HTTPRestrict",
        "Effect": "Deny",
        "Principal":  "*",
        "Action": "s3:*",
        "Resource": ["arn:aws:s3:::${local.std_name}-${var.s3_bucket_name_logos}/*", "arn:aws:s3:::${local.std_name}-${var.s3_bucket_name_logos}" ]
        "Condition": {
          "Bool": {
            "aws:SecureTransport": "false"
          }
        }
      },
      {
        "Sid": "DenyOthers",
        "Effect": "Deny",
        "Principal": "*",
        "NotAction": [ "s3:GetObject", "s3:GetObjectVersion"],
        "Resource": [
          "arn:aws:s3:::${local.std_name}-${var.s3_bucket_name_logos}",
          "arn:aws:s3:::${local.std_name}-${var.s3_bucket_name_logos}/*",
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
#S3 bucket for storing access logs of s3 and its objects
resource "aws_s3_bucket" "s3_bucket_access_logs" {
  bucket = "${local.std_name}-${var.s3_bucket_name_access_logs}"
  acl    = "log-delivery-write"
  force_destroy = true
  versioning {
    enabled = true
  }
  tags = merge(
    local.tags,
    {
      "name" = "${local.std_name}-${var.s3_bucket_name_access_logs}"
    },)
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "AES256"
      }
    }
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
#Blocking public access to s3 bucket used for s3 access logging
resource "aws_s3_bucket_public_access_block" "s3_bucket_public_access_block_access_logs" {
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  bucket                  = aws_s3_bucket.s3_bucket_access_logs.id
  depends_on              = [aws_s3_bucket.s3_bucket_access_logs, aws_s3_bucket_policy.s3_bucket_policy_access_logs]
}
#Setting up a bucket policy to restrict access to s3 bucket used for s3 access logging
resource "aws_s3_bucket_policy" "s3_bucket_policy_access_logs" {
  bucket     = "${local.std_name}-${var.s3_bucket_name_access_logs}"
  depends_on = [aws_s3_bucket.s3_bucket_access_logs]
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowAccessIAMRole",
            "Effect": "Allow",
            "Principal": {
                "AWS": "${var.aws_role_arn}"
            },
            "Action": "*",
            "Resource": [
                "arn:aws:s3:::${local.std_name}-${var.s3_bucket_name_access_logs}",
                "arn:aws:s3:::${local.std_name}-${var.s3_bucket_name_access_logs}/*"
            ]
        },
        {
            "Sid": "HTTPRestrict",
            "Effect": "Deny",
            "Principal": "*",
            "Action": "s3:*",
            "Resource": ["arn:aws:s3:::${local.std_name}-${var.s3_bucket_name_access_logs}/*", "arn:aws:s3:::${local.std_name}-${var.s3_bucket_name_access_logs}"],
            "Condition": {
                "Bool": {
                    "aws:SecureTransport" = "false"
                }
            }
        },
        {
            "Sid": "AllowRestrictedServices",
			"Effect": "Allow",
			"Principal": {
                "Service": ["logging.s3.amazonaws.com"]
            },
			"Action": "*",
			"Resource":[
                "arn:aws:s3:::${local.std_name}-${var.s3_bucket_name_access_logs}",
                "arn:aws:s3:::${local.std_name}-${var.s3_bucket_name_access_logs}/*"
            ]
        }
        /*{
			"Sid": "DenyOthers",
			"Effect": "Deny",
			"Principal": "*",
            "Action": "*",
			"Resource": [
                "arn:aws:s3:::${local.std_name}-${var.s3_bucket_name_access_logs}",
                "arn:aws:s3:::${local.std_name}-${var.s3_bucket_name_access_logs}/*"
            ],
			"Condition": {
				"StringNotLike": {
					"aws:userid": [
                        "${data.aws_iam_role.terraform_role.unique_id}:*",
						"${var.aws_account_number}",
                        "arn:aws:sts:::${var.aws_account_number}:assumed-role/${local.terraform_role_name[1]}/terraform",
					]
        		}
			}
		}*/
    ]
  })
}