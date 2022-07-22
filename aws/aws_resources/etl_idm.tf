#S3 specifics for ETL-IDM Extraction Patterns
resource "aws_s3_bucket" "s3_bucket_etl" {
  for_each = var.s3_bucket_names_etl
    bucket = "${local.std_name}-${each.value}"
    force_destroy = true
    tags = merge(
     local.tags,
      {
        "name" = "${local.std_name}-${each.value}"
      },)
}
resource "aws_s3_bucket_acl" "s3_bucket_acl_etl" {
  for_each = var.s3_bucket_names_etl
    bucket = aws_s3_bucket.s3_bucket_etl[each.value].id
    acl = "private"
}
resource "aws_s3_bucket_lifecycle_configuration" "s3_bucket_lifecycle_etl" {
  for_each = var.s3_bucket_names_etl
    bucket = aws_s3_bucket.s3_bucket_etl[each.value].id
    rule {
      id = "log"
      status = "Disabled"
      transition {
        days = 90
        storage_class = "STANDARD_IA"
      }
      transition {
        days = 180
        storage_class = "GLACIER"
      }
      expiration {
          days = 365
      }
      noncurrent_version_transition {
        days = 90
        storage_class = "GLACIER"
      }
      noncurrent_version_expiration {
        days = 180
      }
    }
}
resource "aws_s3_bucket_versioning" "s3_bucket_versioning_etl" {
  for_each = var.s3_bucket_names_etl
    bucket = aws_s3_bucket.s3_bucket_etl[each.value].id
    versioning_configuration {
      status = "Enabled"
    }
}
resource "aws_s3_bucket_logging" "s3_bucket_logging_etl" {
  for_each = var.s3_bucket_names_etl
    bucket = aws_s3_bucket.s3_bucket_etl[each.key].id
    target_prefix = "logs-${each.value}"
}
resource "aws_s3_bucket_server_side_encryption_configuration" "s3_bucket_encryption_etl" {
  for_each = var.s3_bucket_names_etl
    bucket = aws_s3_bucket.s3_bucket_etl[each.value].id
    rule {
      apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = var.create_kms_keys ? aws_kms_key.s3_kms_key[0].id : var.s3_kms_key_arn
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
resource "aws_s3_bucket_notification" "s3_bucket_notification" {
  for_each = var.s3_bucket_names_etl
    bucket = aws_s3_bucket.s3_bucket_etl[each.value].id
    lambda_function {
      lambda_function_arn = "<include ARN here>"
      events = ["s3:ObjectCreated:*"]
    }
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
#DyanmoDB table specifics for ETL-IDM Extraction Patterns
resource "aws_dynamodb_table" "etl_dynamodb" {
  name = "${local.std_name}-openidl-etl-control-table"
  billing_mode = "PROVISIONED"
  read_capacity = 1
  write_capacity = 1
  hash_key = "SubmissionFileName"
  #range_key = ""
  table_class = "STANDARD"
  #server_side_encryption {
      #enabled = false
      #kms_key_arn = ""
  #}
  attribute {
    name = "SubmissionFileName"
    type = "S"
  }
  attribute {
    name = "IDMLoaderStatus"
    type = "S"
  }
  attribute {
    name = "IntakeStatus"
    type = "S"
  }
  point_in_time_recovery {
    enabled = false
  }
  lifecycle {
    ignore_changes = [read_capacity,write_capacity]
  }
  tags = merge(local.tags, {"name" = "${local.std_name}-openidl-etl-control-table"})
}
resource "aws_appautoscaling_target" "table_read" {
  max_capacity       = 10
  min_capacity       = 1
  resource_id        = "table/${aws_dynamodb_table.etl_dynamodb.name}"
  scalable_dimension = "dynamodb:table:ReadCapacityUnits"
  service_namespace  = "dynamodb"
}
resource "aws_appautoscaling_target" "table_write" {
  max_capacity       = 10
  min_capacity       = 1
  resource_id        = "table/${aws_dynamodb_table.etl_dynamodb.name}"
  scalable_dimension = "dynamodb:table:WriteCapacityUnits"
  service_namespace  = "dynamodb"
}
resource "aws_appautoscaling_policy" "table_read_policy" {
  name               = "DynamoDBReadCapacityUtilization:${aws_appautoscaling_target.table_read[0].resource_id}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.table_read[0].resource_id
  scalable_dimension = aws_appautoscaling_target.table_read[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.table_read[0].service_namespace
  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBReadCapacityUtilization"
    }
    scale_in_cooldown  = 5
    scale_out_cooldown = 5
    target_value       = 85
  }
}
resource "aws_appautoscaling_policy" "table_write_policy" {
  name               = "DynamoDBWriteCapacityUtilization:${aws_appautoscaling_target.table_write[0].resource_id}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.table_write[0].resource_id
  scalable_dimension = aws_appautoscaling_target.table_write[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.table_write[0].service_namespace
  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBWriteCapacityUtilization"
    }
    scale_in_cooldown  = 5
    scale_out_cooldown = 5
    target_value       = 85
  }
}
#SNS topic
resource "aws_sns_topic" "sns_topic_etl" {
  for_each = toset(["failure", "success"])
  name     = "${local.std_name}-openidl-etl-${each.value}"
  policy = <<EOT
    {
      "Version": "2008-10-17",
      "Id": "__default_policy_ID",
      "Statement": [
      {
        "Sid": "__default_statement_ID",
        "Effect": "Allow",
        "Principal": {
          "AWS": "*"
        },
        "Action": [
          "SNS:GetTopicAttributes",
          "SNS:SetTopicAttributes",
          "SNS:AddPermission",
          "SNS:RemovePermission",
          "SNS:DeleteTopic",
          "SNS:Subscribe",
          "SNS:ListSubscriptionsByTopic",
          "SNS:Publish"
        ],
        "Resource": "arn:aws:sns:${var.aws_region}:${var.aws_account_number}:${local.std_name}-openidl-etl-${each.value}",
        "Condition": {
          "StringEquals": {
            "AWS:SourceOwner": "${var.aws_account_number}"
          }
        }
      }
    ]
  }
  EOT
  delivery_policy = <<EOF
    {
      "http": {
        "defaultHealthyRetryPolicy": {
          "minDelayTarget": 20,
          "maxDelayTarget": 20,
          "numRetries": 3,
          "numMaxDelayRetries": 0,
          "numNoDelayRetries": 0,
          "numMinDelayRetries": 0,
          "backoffFunction": "linear",
        },
        "disableSubscriptionOverrides: false,
        "defaultThrottlePolicy": {
          "maxReceivesPerSecond": 1
        }
      }
   }
   EOF
  tags = merge(local.tags, { "name" = "${local.std_name}-${each.value}"})
}
#amend SNS topic subscription
resource "aws_sns_topic_subscription" "sns_topic_subscription_etl" {
    for_each = local.sns_topic_endpoint_map
      endpoint  = each.value[1]
      protocol  = "email"
      topic_arn = each.value[0]
}
#Lambda
locals {
  sns_topic_arn_list = ["${aws_sns_topic.sns_topic_etl["failure"].arn}", "${aws_sns_topic.sns_topic_etl["success"].arn}"]
  email_endpoints_list = ["peter@aaisonline.com", "kens@aaisonline.com"]
  sns_topic_endpoint_map = setproduct(local.sns_topic_arn_list, local.email_endpoints_list)
}

