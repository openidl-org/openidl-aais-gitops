
#S3 specifics for Reporting
resource "aws_s3_bucket" "reporting" {
  bucket = "${local.std_name}-${var.s3_bucket_name_reporting}"
  force_destroy = true
  tags = merge(local.tags, {"name" = "${local.std_name}-${var.s3_bucket_name_reporting}"})
}
resource "aws_s3_bucket_acl" "reporting" { 
  bucket = aws_s3_bucket.reporting.id
  acl = "private"
  depends_on = [aws_s3_bucket.reporting]
}
resource "aws_s3_bucket_lifecycle_configuration" "reporting" {
  bucket = aws_s3_bucket.reporting.id
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
  depends_on = [aws_s3_bucket.reporting]
}
resource "aws_s3_bucket_versioning" "reporting" {
  bucket = aws_s3_bucket.reporting.id
  versioning_configuration {
    status = "Enabled"
  }
  depends_on = [aws_s3_bucket.reporting]
}
resource "aws_s3_bucket_server_side_encryption_configuration" "reporting" {
  bucket = aws_s3_bucket.reporting.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = var.create_kms_keys ? aws_kms_key.s3_kms_key[0].id : var.s3_kms_key_arn
    }
  }
  depends_on = [aws_s3_bucket.reporting]
}
resource "aws_s3_bucket_public_access_block" "reporting" {
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
  bucket                  = aws_s3_bucket.reporting.id
  depends_on = [aws_s3_bucket.reporting]
}
resource "aws_s3_bucket_cors_configuration" "reporting" {
  depends_on = [aws_s3_bucket.reporting]
  bucket = aws_s3_bucket.reporting.id
  cors_rule {
    allowed_headers = []
    allowed_methods = ["GET", "HEAD", "POST"]
    allowed_origins = ["*"]
    expose_headers = []
  }
}
resource "aws_s3_bucket_policy" "reporting" {
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
          "Sid": "AllowLambda",
          "Effect": "Allow",
          "Principal": {
              "AWS": [
                "${aws_iam_role.reporting_lambda.arn}"
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
              "arn:aws:s3:::${local.std_name}-${var.s3_bucket_name_reporting}",
              "arn:aws:s3:::${local.std_name}-${var.s3_bucket_name_reporting}/*"
          ]
        },
    ]
  })
}
#Lambda specifics
resource "aws_iam_role" "reporting_lambda" {
  name = "${local.std_name}-openidl-reporting-lambda"
  managed_policy_arns = [aws_iam_policy.reporting_lambda_role_policy.arn]
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
                "kms:Encrypt",
                "kms:DescribeKey"
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
  content = local.config-reporting-processor-datacall
  filename = "./resources/openidl-reporting-processor/server/config/datacall-config.json"
}
resource "local_file" "config_reporting_s3" {
  content = local.config-reporting-processor-s3
  filename = "./resources/openidl-reporting-processor/server/config/s3-bucket-config.json"
}
resource "aws_lambda_function" "reporting-processor" {
  function_name = "${local.std_name}-openidl-reporting-processor"
  role              = aws_iam_role.reporting_lambda.arn
  architectures     = ["x86_64"]
  description       = "Openidl Reporting Processor"
  #environment {}
  package_type = "Zip"
  runtime = "nodejs16.x"
  handler = "index.handler"
  filename = "./resources/openidl-reporting-processor.zip"
  timeout = "3"
  tags = merge(local.tags,{ "name" = "${local.std_name}-openidl-reporting-processor"})
  depends_on = [data.archive_file.reporting_processor_zip]
}
resource "aws_s3_bucket_notification" "reporting_processor" {
  depends_on = [aws_s3_bucket.s3_bucket_hds, aws_lambda_permission.allow_bucket_reporting_processor]
  bucket = aws_s3_bucket.s3_bucket_hds.id
  lambda_function {
    lambda_function_arn = aws_lambda_function.reporting_processor.arn
    events = ["s3:ObjectCreated:*"]
    filter_prefix = "results-"
  }
}
resource "aws_lambda_permission" "allow_bucket_reporting_processor" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.reporting_processor.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.s3_bucket_hds.arn
  depends_on = [aws_s3_bucket.s3_bucket_hds]
}