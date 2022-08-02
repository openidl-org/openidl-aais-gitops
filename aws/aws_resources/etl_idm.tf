#S3 specifics for ETL-IDM Extraction Patterns
resource "aws_s3_bucket" "etl" {
  for_each = var.s3_bucket_names_etl
    bucket = "${local.std_name}-${each.key}"
    force_destroy = true
    tags = merge(local.tags, {"name" = "${local.std_name}-${each.value}"})
  depends_on = [aws_sns_topic.etl]
}
resource "aws_s3_bucket_acl" "etl" {
  for_each = var.s3_bucket_names_etl
    bucket = aws_s3_bucket.etl[each.key].id
    acl = "private"
  depends_on = [aws_s3_bucket.etl]
}
resource "aws_s3_bucket_lifecycle_configuration" "etl" {
  for_each = var.s3_bucket_names_etl
    bucket = aws_s3_bucket.etl[each.key].id
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
        noncurrent_days = 90
        storage_class = "GLACIER"
      }
      noncurrent_version_expiration {
        noncurrent_days = 180
      }
    }
  depends_on = [aws_s3_bucket.etl]
}
resource "aws_s3_bucket_versioning" "etl" {
  for_each = var.s3_bucket_names_etl
    bucket = aws_s3_bucket.etl[each.key].id
    versioning_configuration {
      status = "Enabled"
    }
  depends_on = [aws_s3_bucket.etl]
}
resource "aws_s3_bucket_logging" "etl" {
  for_each = var.s3_bucket_names_etl
    bucket = aws_s3_bucket.etl[each.key].id
    target_prefix = "logs-${each.value}"
    target_bucket = ""
  depends_on = [aws_s3_bucket.etl]
}
resource "aws_s3_bucket_server_side_encryption_configuration" "etl" {
  for_each = var.s3_bucket_names_etl
    bucket = aws_s3_bucket.etl[each.key].id
    rule {
      apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = var.create_kms_keys ? aws_kms_key.s3_kms_key[0].id : var.s3_kms_key_arn
      }
    }
 depends_on = [aws_s3_bucket.etl]
}
resource "aws_s3_bucket_public_access_block" "etl" {
  for_each = var.s3_bucket_names_etl
    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
    bucket                  = aws_s3_bucket.etl[each.key].id
  depends_on = [aws_s3_bucket.etl]
}
resource "aws_s3_bucket_notification" "etl_idm_loader" {
  depends_on = [aws_s3_bucket.etl, aws_sns_topic.etl]
  bucket = aws_s3_bucket.etl["idm-loader"].id
  lambda_function {
    lambda_function_arn = aws_lambda_function.etl_success_processor.arn
    events = ["s3:ObjectCreated:*"]
  }
}
resource "aws_s3_bucket_notification" "etl_intake" {
  #depends_on = [aws_s3_bucket.etl, aws_lambda_permission.etl_allow_bucket_intake_processor]
  bucket = aws_s3_bucket.etl["intake"].id
  lambda_function {
    lambda_function_arn = aws_lambda_function.etl_intake_processor.arn
    events = ["s3:ObjectCreated:*"]
  }
}
resource "aws_s3_bucket_policy" "etl" {
  depends_on = [aws_s3_bucket.etl]
  for_each = var.s3_bucket_names_etl
    bucket     = "${local.std_name}-${each.key}"
    policy = jsonencode({
      "Version": "2012-10-17",
      "Statement": [
          {
            "Sid": "AllowGetAndPutObjects",
            "Effect": "Allow",
            "Principal": {
                "AWS": "${var.aws_user_arn}"
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
                "arn:aws:s3:::${local.std_name}-${each.key}",
                "arn:aws:s3:::${local.std_name}-${each.key}/*"
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
                "arn:aws:s3:::${local.std_name}-${each.key}",
                "arn:aws:s3:::${local.std_name}-${each.key}/*"
            ]
          },
          {
            "Sid": "HTTPRestrict",
            "Effect": "Deny",
            "Principal": "*",
            "Action": "s3:*",
            "Resource": ["arn:aws:s3:::${local.std_name}-${each.key}/*", "arn:aws:s3:::${local.std_name}-${each.key}" ],
            "Condition": {
                "Bool": {
                    "aws:SecureTransport" = "false"
                }
            }
          },
          {
            "Sid": "AllowLambda",
            "Effect": "Allow",
            "Principal": {
                "AWS": [
                  "${aws_iam_role.etl_lambda.arn}",
                ]
            },
            "Action": [
                "s3:GetObject",
                "s3:PutObject",
                "s3:RestoreObject",
                "s3:DeleteObject",
                "s3:ListMultipartUploadParts",
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::${local.std_name}-${each.key}",
                "arn:aws:s3:::${local.std_name}-${each.key}/*"
            ]
          },
      ]
    })
}
#DyanmoDB table specifics for ETL-IDM Extraction Patterns
resource "aws_dynamodb_table" "etl" {
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
  resource_id        = "table/${aws_dynamodb_table.etl.name}"
  scalable_dimension = "dynamodb:table:ReadCapacityUnits"
  service_namespace  = "dynamodb"
}
resource "aws_appautoscaling_target" "table_write" {
  max_capacity       = 10
  min_capacity       = 1
  resource_id        = "table/${aws_dynamodb_table.etl.name}"
  scalable_dimension = "dynamodb:table:WriteCapacityUnits"
  service_namespace  = "dynamodb"
}
resource "aws_appautoscaling_policy" "table_read_policy" {
  name               = "DynamoDBReadCapacityUtilization:${aws_appautoscaling_target.table_read.resource_id}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.table_read.resource_id
  scalable_dimension = aws_appautoscaling_target.table_read.scalable_dimension
  service_namespace  = aws_appautoscaling_target.table_read.service_namespace
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
  name               = "DynamoDBWriteCapacityUtilization:${aws_appautoscaling_target.table_write.resource_id}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.table_write.resource_id
  scalable_dimension = aws_appautoscaling_target.table_write.scalable_dimension
  service_namespace  = aws_appautoscaling_target.table_write.service_namespace
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
resource "aws_sns_topic" "etl" {
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
          "backoffFunction": "linear"
        },
        "disableSubscriptionOverrides": false,
        "defaultThrottlePolicy": {
          "maxReceivesPerSecond": 1
        }
      }
   }
   EOF
  tags = merge(local.tags, { "name" = "${local.std_name}-${each.value}"})
}
#SNS topic subscription
resource "aws_sns_topic_subscription" "etl_success" {
  for_each = toset(var.sns_subscription_email_ids)
    endpoint  = each.value
    protocol  = "email"
    topic_arn = aws_sns_topic.etl["success"].arn
}
resource "aws_sns_topic_subscription" "etl_failure" {
  for_each = toset(var.sns_subscription_email_ids)
    endpoint  = each.value
    protocol  = "email"
    topic_arn = aws_sns_topic.etl["failure"].arn
}
#Lambda specifics
resource "aws_iam_role" "etl_lambda" {
  name = "${local.std_name}-openidl-etl-lambda"
  managed_policy_arns = [aws_iam_policy.etl_lambda_role_policy.arn]
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "lambda.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
      }
    ]
  })
  tags = merge(local.tags, { "name" = "${local.std_name}-openidl-etl-intake-lambda"})
}
resource "aws_lambda_function" "etl_intake_processor" {
  function_name = "${local.std_name}-openidl-etl-intake-processor"
  role              = aws_iam_role.etl_lambda.arn
  architectures     = ["x86_64"]
  description       = "ETL-IDM intake processor"
  #environment {}
  package_type = "Zip"
  runtime = "nodejs16.x"
  handler = "index.handler"
  filename = "./resources/openidl-etl-intake-processor.zip"
  timeout = "3"
  source_code_hash = base64sha256(filebase64("./resources/openidl-etl-intake-processor.zip"))
  tags = merge(local.tags,{ "name" = "${local.std_name}-openidl-etl-intake-processor"})
  depends_on = [data.archive_file.etl_intake_processor_zip]
}
resource "aws_lambda_function" "etl_success_processor" {
  function_name = "${local.std_name}-openidl-etl-idm-loader"
  role              = aws_iam_role.etl_lambda.arn
  architectures     = ["x86_64"]
  description       = "ETL-IDM loader processor"
  #environment {}
  package_type = "Zip"
  runtime = "nodejs16.x"
  handler = "index.handler"
  filename = "./resources/openidl-etl-success-processor.zip"
  timeout = "3"
  source_code_hash = base64sha256(filebase64("./resources/openidl-etl-success-processor.zip"))
  tags = merge(local.tags,{ "name" = "${local.std_name}-openidl-etl-idm-loader"})
  depends_on = [data.archive_file.etl_success_processor_zip]
}
resource "local_file" "config_intake" {
  content = local.config-intake
  filename = "./resources/openidl-etl-intake-processor/config/config.json"
}
resource "local_file" "config_success" {
  content = local.config-success
  filename = "./resources/openidl-etl-success-processor/config/config.json"
}
resource "aws_iam_policy" "etl_lambda_role_policy" {
  name = "${local.std_name}-etl-lambda-role-policy"
  policy = jsonencode(
    {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowCloudWatchLogGroups",
            "Effect": "Allow",
            "Action": "logs:CreateLogGroup",
            "Resource": "arn:aws:logs:${var.aws_region}:650795358261:*"
        },
        {
            "Sid": "AllowCWLogStream",
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": [
				"arn:aws:logs:${var.aws_region}:${var.aws_account_number}:log-group:/aws/lambda/${local.std_name}-openidl-intake-processor:*",
				"arn:aws:logs:${var.aws_region}:${var.aws_account_number}:log-group:/aws/lambda/${local.std_name}-openidl-etl-idm-loader:*"
			]
        },
        {
            "Sid": "AllowS3",
            "Effect": "Allow",
            "Action": [
				"s3:PutObject",
				"s3:GetObject",
				"s3-object-lambda:*"
			],
            "Resource": [
                "arn:aws:s3:::${local.std_name}-${var.s3_bucket_names_etl.idm-loader}/*",
                "arn:aws:s3:::${local.std_name}${var.s3_bucket_names_etl.failure}/*",
				"arn:aws:s3:::${local.std_name}${var.s3_bucket_names_etl.intake}/*"
            ]
        },
        {
            "Sid": "AllowDynamoDB",
            "Effect": "Allow",
            "Action": [
                "dynamodb:PutItem",
                "dynamodb:GetItem",
                "dynamodb:UpdateItem"
            ],
            "Resource": "arn:aws:dynamodb:${var.aws_region}:${var.aws_account_number}:table/${local.std_name}-openidl-etl-control-table"
        },
        {
            "Sid": "AllowSNS",
            "Effect": "Allow",
            "Action": "sns:Publish",
            "Resource": [
                "arn:aws:sns:${var.aws_region}:${var.aws_account_number}:${local.std_name}-openidl-etl-success",
                "arn:aws:sns:${var.aws_region}:${var.aws_account_number}:${local.std_name}-openidl-etl-failure"
            ]
        }
    ]
  })
  tags = merge(local.tags, {
    name = "${local.std_name}-etl-lambda-role-policy"})
}
resource "aws_lambda_permission" "etl_allow_bucket_intake_processor" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.etl_intake_processor.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.etl["intake"].arn
}
resource "aws_lambda_permission" "etl_allow_bucket_success_processor" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.etl_success_processor.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.etl["idm-loader"].arn
}
