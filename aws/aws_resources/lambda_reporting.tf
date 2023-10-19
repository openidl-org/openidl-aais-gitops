
#S3 specifics for Reporting
resource "aws_s3_bucket" "reporting" {
  count = local.org_name == "anal" ? 1 : 0
  bucket = "${local.std_name}-${var.s3_bucket_name_reporting}"
  force_destroy = true
  tags = merge(local.tags, {"name" = "${local.std_name}-${var.s3_bucket_name_reporting}"})
}
resource "aws_s3_bucket_acl" "reporting" {
  count = local.org_name == "anal" ? 1 : 0
  bucket = aws_s3_bucket.reporting[count.index].id
  acl = "private"
  depends_on = [aws_s3_bucket.reporting]
}
resource "aws_s3_bucket_lifecycle_configuration" "reporting" {
  count = local.org_name == "anal" ? 1 : 0
  bucket = aws_s3_bucket.reporting[count.index].id
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
      noncurrent_days = 0
      storage_class = "GLACIER"
    }
    noncurrent_version_expiration {
      noncurrent_days = 1
    }
  }
  depends_on = [aws_s3_bucket.reporting]
}
resource "aws_s3_bucket_versioning" "reporting" {
  count = local.org_name == "anal" ? 1 : 0
  bucket = aws_s3_bucket.reporting[count.index].id
  versioning_configuration {
    status = "Suspended"
  }
  depends_on = [aws_s3_bucket.reporting]
}
#resource "aws_s3_bucket_server_side_encryption_configuration" "reporting" {
#  count = local.org_name == "anal" ? 1 : 0
#  bucket = aws_s3_bucket.reporting[count.index].id
#  rule {
#    apply_server_side_encryption_by_default {
#      sse_algorithm     = "aws:kms"
#      kms_master_key_id = var.create_kms_keys ? aws_kms_key.s3_kms_key[0].id : var.s3_kms_key_arn
#    }
#  }
#  depends_on = [aws_s3_bucket.reporting]
#}
resource "aws_s3_bucket_public_access_block" "reporting" {
  count = local.org_name == "anal" ? 1 : 0
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
  bucket                  = aws_s3_bucket.reporting[count.index].id
  depends_on = [aws_s3_bucket.reporting]
}
resource "aws_s3_bucket_cors_configuration" "reporting" {
  count = local.org_name == "anal" ? 1 : 0
  depends_on = [aws_s3_bucket.reporting]
  bucket = aws_s3_bucket.reporting[count.index].id
  cors_rule {
    allowed_headers = []
    allowed_methods = ["GET", "HEAD", "POST"]
    allowed_origins = ["*"]
    expose_headers = []
  }
}
resource "aws_s3_bucket_policy" "reporting" {
  count = local.org_name == "anal" ? 1 : 0
  depends_on = [aws_s3_bucket.reporting]
  bucket     = "${local.std_name}-${var.s3_bucket_name_reporting}"
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
          "Sid": "AllowGetAndPutObjects",
          "Effect": "Allow",
          "Principal": {
              "AWS": "${aws_iam_role.openidl_apps_iam_role.arn}"
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
              "arn:aws:s3:::${local.std_name}-${var.s3_bucket_name_reporting}",
              "arn:aws:s3:::${local.std_name}-${var.s3_bucket_name_reporting}/*"
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
              "arn:aws:s3:::${local.std_name}-${var.s3_bucket_name_reporting}",
              "arn:aws:s3:::${local.std_name}-${var.s3_bucket_name_reporting}/*"
          ]
        },
        {
          "Sid": "HTTPRestrict",
          "Effect": "Deny",
          "Principal": "*",
          "Action": "s3:*",
          "Resource": ["arn:aws:s3:::${local.std_name}-${var.s3_bucket_name_reporting}/*", "arn:aws:s3:::${local.std_name}-${var.s3_bucket_name_reporting}" ],
          "Condition": {
              "Bool": {
                  "aws:SecureTransport" = "false"
              }
          }
        },
        {
          "Sid":"AddPerm",
          "Effect":"Allow",
          "Principal": "*",
          "Action":["s3:GetObject"],
          "Resource":["arn:aws:s3:::${local.std_name}-${var.s3_bucket_name_reporting}/report-*"]
        },
        #{
        #  "Sid":"Allow GET requests",
        #  "Effect":"Allow",
        #  "Principal":"*",
        #  "Action":["s3:GetObject"],
        #  "Resource":"arn:aws:s3:::${local.std_name}-${var.s3_bucket_name_reporting}/*",
        #  "Condition":{
        #    "StringLike":{"aws:Referer":["https://openidl.${var.aws_env}.${local.public_domain}/*"]}
        #  }
        #},
        {
          "Sid": "AllowLambda",
          "Effect": "Allow",
          "Principal": {
              "AWS": [
                "${aws_iam_role.reporting_lambda[count.index].arn}"
              ]
          },
          "Action": [
              "s3:PutObject",
              "s3:DeleteObject",
              "s3:ListBucket",
              "s3:GetObject"
          ],
          "Resource": [
              "arn:aws:s3:::${local.std_name}-${var.s3_bucket_name_reporting}",
              "arn:aws:s3:::${local.std_name}-${var.s3_bucket_name_reporting}/*"
          ]
        },
    ]
  })
}
#Lambda specifics
resource "aws_iam_role" "reporting_lambda" {
  count = local.org_name == "anal" ? 1 : 0
  name = "${local.std_name}-openidl-reporting-lambda"
  managed_policy_arns = [aws_iam_policy.reporting_lambda_role_policy[count.index].arn]
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
  tags = merge(local.tags, { "name" = "${local.std_name}-openidl-reporting-lambda"})
}
resource "aws_iam_policy" "reporting_lambda_role_policy" {
  count = local.org_name == "anal" ? 1 : 0
  name = "${local.std_name}-reporting-lambda-role-policy"
  policy = jsonencode(
    {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowCloudWatchLogGroups",
            "Effect": "Allow",
            "Action": "logs:CreateLogGroup",
            "Resource": "arn:aws:logs:${var.aws_region}:${var.aws_account_number}:*"
        },
        {
            "Sid": "AllowCWLogStream",
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": "*",
        },
        {
            "Sid": "AllowS3",
            "Effect": "Allow",
            "Action": [
              "s3:PutObject",
              "s3:GetObject",
              "s3:DeleteObject",
              "s3:ListBucket",
              "s3-object-lambda:*"
			      ],
            "Resource": [
                "arn:aws:s3:::${local.std_name}-${var.s3_bucket_name_reporting}/*",
                "arn:aws:s3:::${local.std_name}-${var.s3_bucket_name_hds_analytics}/*"
            ]
        },
        {
            "Sid": "AllowKMS",
            "Effect": "Allow",
            "Action": [
                "kms:Decrypt",
                "kms:GenerateDataKey"
            ],
            "Resource": "*"
        }
    ]
  })
  tags = merge(local.tags, {
    name = "${local.std_name}-reporting-lambda-role-policy"
  })
}
resource "local_file" "config_reporting_datacall" {
  count = local.org_name == "anal" ? 1 : 0
  content = local.config-reporting-processor-datacall
  filename = "./resources/openidl-reporting-processor/config/datacall-config.json"
}
resource "local_file" "config_reporting_default" {
  count = local.org_name == "anal" ? 1 : 0
  content = local.config-reporting-processor-default
  filename = "./resources/openidl-reporting-processor/config/default.json"
}
resource "local_file" "config_reporting_s3" {
  count = local.org_name == "anal" ? 1 : 0
  content = local.config-reporting-processor-s3
  filename = "./resources/openidl-reporting-processor/config/s3-bucket-config.json"
  depends_on = [aws_s3_bucket.reporting]
}
resource "zipper_file" "reporting_processor_zip" {
  count = local.org_name == "anal" ? 1 : 0
  source      = "./resources/openidl-reporting-processor/"
  output_path = "./resources/openidl-reporting-processor.zip"
  depends_on = [local_file.config_reporting_s3, local_file.config_reporting_datacall, local_file.config_reporting_default]
}
resource "aws_lambda_function" "reporting-processor" {
  count = local.org_name == "anal" ? 1 : 0
  function_name = "${local.std_name}-openidl-reporting-processor"
  role              = aws_iam_role.reporting_lambda[count.index].arn
  architectures     = ["x86_64"]
  description       = "Openidl Reporting Processor"
  environment {
    variables = {
      REGION = "${var.aws_region}"
    }
  }
  package_type = "Zip"
  source_code_hash = "${zipper_file.reporting_processor_zip[count.index].output_sha}"
  runtime = "nodejs16.x"
  handler = "index.handler"
  filename = "./resources/openidl-reporting-processor.zip"
  timeout = "600"
  memory_size = "8192"
  publish = "true"
  tags = merge(local.tags,{ "name" = "${local.std_name}-openidl-reporting-processor"})
  depends_on = [zipper_file.reporting_processor_zip]
}
resource "aws_s3_bucket_notification" "reporting-processor" {
  count = local.org_name == "anal" ? 1 : 0
  depends_on = [data.aws_s3_bucket.s3_bucket_hds_data, aws_lambda_permission.allow_bucket_reporting_processor]
  bucket = data.aws_s3_bucket.s3_bucket_hds_data[0].id
  lambda_function {
    lambda_function_arn = aws_lambda_function.reporting-processor[count.index].arn
    events = ["s3:ObjectCreated:*"]
    filter_prefix = "result-"
  }
}
resource "aws_lambda_permission" "allow_bucket_reporting_processor" {
  count = local.org_name == "anal" ? 1 : 0
  depends_on = [data.aws_s3_bucket.s3_bucket_hds_data]
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.reporting-processor[count.index].arn
  principal     = "s3.amazonaws.com"
  source_arn    = data.aws_s3_bucket.s3_bucket_hds_data[0].arn
}
