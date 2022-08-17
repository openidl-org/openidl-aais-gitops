#S3 bucket for static content - UI
resource "aws_s3_bucket" "upload_ui" {
    bucket = "${local.std_name}-${var.s3_bucket_name_upload_ui}"
    force_destroy = true
    tags = merge(local.tags, {"name" = "${local.std_name}-${var.s3_bucket_name_upload_ui}"})
}
resource "aws_s3_bucket_acl" "upload_ui" {
    bucket = aws_s3_bucket.upload_ui.id
    acl = "public-read"
    depends_on = [aws_s3_bucket.upload_ui]
}
resource "aws_s3_bucket_lifecycle_configuration" "upload_ui" {
    bucket = aws_s3_bucket.upload_ui.id
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
  depends_on = [aws_s3_bucket.upload_ui]
}
resource "aws_s3_bucket_versioning" "upload_ui" {
      bucket = aws_s3_bucket.upload_ui.id
      versioning_configuration {
      status = "Enabled"
      }
    depends_on = [aws_s3_bucket.upload_ui]
}
resource "aws_s3_bucket_logging" "upload_ui" {
    bucket = aws_s3_bucket.upload_ui.id
    target_prefix = "logs-upload-ui"
    target_bucket = aws_s3_bucket.s3_bucket_access_logs.id
    depends_on = [aws_s3_bucket.upload_ui]
}
resource "aws_s3_bucket_server_side_encryption_configuration" "upload_ui" {
    bucket = aws_s3_bucket.upload_ui.id
    rule {
      apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = var.create_kms_keys ? aws_kms_key.s3_kms_key[0].id : var.s3_kms_key_arn
      }
    }
 depends_on = [aws_s3_bucket.upload_ui]
}
resource "aws_s3_bucket_public_access_block" "upload_ui" {
    block_public_acls       = false
    block_public_policy     = false
    ignore_public_acls      = false
    restrict_public_buckets = false
    bucket = aws_s3_bucket.upload_ui.id
    depends_on = [aws_s3_bucket.upload_ui]
}
resource "aws_s3_bucket_policy" "upload_ui" {
  depends_on = [aws_s3_bucket.upload_ui]
  bucket = aws_s3_bucket.upload_ui.id
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowPublicAccess",
            "Effect": "Allow",
            "Principal": "*",
            "Action": [ "s3:GetObject", "s3:GetObjectVersion"],
            "Resource": [
                "arn:aws:s3:::${local.std_name}-${var.s3_bucket_name_upload_ui}",
                "arn:aws:s3:::${local.std_name}-${var.s3_bucket_name_upload_ui}/*",
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
                "arn:aws:s3:::${local.std_name}-${var.s3_bucket_name_upload_ui}",
                "arn:aws:s3:::${local.std_name}-${var.s3_bucket_name_upload_ui}/*",
            ]
        },
        {
        "Sid":  "HTTPRestrict",
        "Effect": "Deny",
        "Principal":  "*",
        "Action": "s3:*",
        "Resource": ["arn:aws:s3:::${local.std_name}-${var.s3_bucket_name_upload_ui}/*", "arn:aws:s3:::${local.std_name}-${var.s3_bucket_name_upload_ui}" ]
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
          "arn:aws:s3:::${local.std_name}-${var.s3_bucket_name_upload_ui}",
          "arn:aws:s3:::${local.std_name}-${var.s3_bucket_name_upload_ui}/*",
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
resource "aws_s3_bucket_website_configuration" "upload_ui" {
  depends_on = [aws_s3_bucket.upload_ui]
  bucket = aws_s3_bucket.upload_ui.id
  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "index.html"
  }
 }
#Lambda specifics related to openidl upload ui
resource "aws_iam_role" "upload" {
  name = "${local.std_name}-openidl-upload"
  managed_policy_arns = [aws_iam_policy.upload.arn]
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
  tags = merge(local.tags, { "name" = "${local.std_name}-openidl-upload"})
}
resource "aws_lambda_function" "upload" {
  function_name = "${local.std_name}-openidl-upload"
  role              = aws_iam_role.upload.arn
  architectures     = ["x86_64"]
  description       = "ETL-IDM intake processor"
  environment {
    FILE_UPLOAD_BUCKET = aws_s3_bucket.etl["intake"].id
  }
  package_type = "Zip"
  runtime = "nodejs14.x"
  handler = "src/getSignedUrl.handler"
  filename = "./resources/openidl-upload.zip"
  timeout = "3"
  tags = merge(local.tags,{ "name" = "${local.std_name}-openidl-upload"})
  depends_on = [data.archive_file.upload_zip]
}
resource "aws_iam_policy" "upload" {
  name = "${local.std_name}-openidl-upload"
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
            "Effect": "Allow",
            "Action": [
                "xray:PutTraceSegments",
                "xray:PutTelemetryRecords",
                "xray:GetSamplingRules",
                "xray:GetSamplingTargets",
                "xray:GetSamplingStatisticSummaries"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Sid": "AllowS3",
            "Effect": "Allow",
            "Action": [
				"s3:GetObject",
                "s3:GetObjectAcl",
                "s3:GetObjectVersion",
                "s3:PutObject",
                "s3:PutObjectAcl",
                "s3:DeleteObject",
                "s3:DeleteObjectTagging",
                "s3:DeleteObjectVersionTagging",
                "s3:GetObjectTagging",
                "s3:GetObjectVersionTagging",
                "s3:PutObjectTagging",
                "s3:PutObjectVersionTagging"
			],
            "Resource": [
                "arn:aws:s3:::${local.std_name}-${var.s3_bucket_names_etl.intake}/*",
            ]
        },
        {
            "Sid": "AllowS3Bucket",
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket",
                "s3:GetBucketLocation",
                "s3:GetLifecycleConfiguration",
                "s3:PutLifecycleConfiguration"
            ],
            "Resource": "arn:aws:s3:::${local.std_name}-${var.s3_bucket_names_etl.intake}"
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
    ]
  })
  tags = merge(local.tags, {
    name = "${local.std_name}-openidl-upload"})
}
#update source_arn after API GW is defined
resource "aws_lambda_permission" "upload" {
  statement_id  = "AllowExecutionFromAPIGW"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.upload.arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.aws_region}:${var.aws_account_number}:${aws_api_gateway_rest_api.id}/*/POST/getSignedUrl"
}
#create APIGW
resource "aws_api_gateway_rest_api" "upload_ui" {
  name          = "${local.std_name}-upload-ui"
  endpoint_configuration {
    types = ["EDGE"]
  }
}
resource "aws_api_gateway_authorizer" "upload" {
  name = "${local.std_name}-openidl-upload"
  rest_api_id = aws_api_gateway_rest_api.upload_ui.id
  authorizer_uri = aws_lambda_function.upload.invoke_arn
  type = "COGNITO_USER_POOLS"
  provider_arns = ["arn:aws:cognito-idp:${var.aws_region}:${var.aws_account_number}:userpool/${aws_cognito_user_pool.user_pool.id}"]

}
resource "aws_api_gateway_documentation_part" "upload_method" {
  rest_api_id = aws_api_gateway_rest_api.upload_ui.id
  location {
    type = "METHOD"
    path = "/getSignedUrl"
    method = "OPTIONS"
  }
  properties = jsonencode(
    {
     "summary": "CORS support"
    })
}
resource "aws_api_gateway_documentation_part" "upload_response" {
  rest_api_id = aws_api_gateway_rest_api.upload_ui.id
  location {
    type = "RESPONSE"
    path = "/getSignedUrl"
    method = "OPTIONS"
    status_code = "200"
  }
  properties = jsonencode(
    {
      "description": "Default response for CORS method"
    })
}
resource "aws_api_gateway_resource" "getSignedUrl" {
  rest_api_id = aws_api_gateway_rest_api.upload_ui.id
  parent_id = aws_api_gateway_rest_api.upload_ui.root_resource_id
  path_part = "getSignedUrl"
}
resource "aws_api_gateway_method" "getSignedUrl_Options" {
  rest_api_id = aws_api_gateway_rest_api.upload_ui.id
  resource_id = aws_api_gateway_resource.getSignedUrl.id
  http_method = "OPTIONS"
  authorization = "NONE"
  request_models = {}
}
resource "aws_api_gateway_method_response" "getSignedUrl_Options" {
  rest_api_id = aws_api_gateway_rest_api.upload_ui.id
  resource_id = aws_api_gateway_resource.getSignedUrl.id
  http_method = "OPTIONS"
  status_code = "200"
}
resource "aws_api_gateway_integration" "getSignedUrl_Options" {
  rest_api_id = aws_api_gateway_rest_api.upload_ui.id
  resource_id = aws_api_gateway_resource.getSignedUrl.id
  http_method = aws_api_gateway_method.getSignedUrl_Options.http_method
  type        = "MOCK"
}
resource "aws_api_gateway_integration_response" "getSignedUrl_Options" {
  rest_api_id = aws_api_gateway_rest_api.upload_ui.id
  resource_id = aws_api_gateway_resource.getSignedUrl.id
  http_method = aws_api_gateway_method.getSignedUrl_Options.http_method
  status_code = aws_api_gateway_method_response.getSignedUrl_Options.status_code
}
resource "aws_api_gateway_method" "getSignedUrl_Post" {
  rest_api_id = aws_api_gateway_rest_api.upload_ui.id
  resource_id = aws_api_gateway_resource.getSignedUrl.id
  http_method = "POST"
  authorization = "NONE"
  request_models = {}
}
resource "aws_api_gateway_method_response" "getSignedUrl_Post" {
  rest_api_id = aws_api_gateway_rest_api.upload_ui.id
  resource_id = aws_api_gateway_resource.getSignedUrl.id
  http_method = "POST"
  status_code = "200"
}
resource "aws_api_gateway_integration" "getSignedUrl_Post" {
  rest_api_id = aws_api_gateway_rest_api.upload_ui.id
  resource_id = aws_api_gateway_resource.getSignedUrl.id
  http_method = aws_api_gateway_method.getSignedUrl_Post.http_method
  type        = "AWS_PROXY"
  uri = aws_lambda_function.upload.invoke_arn
}
resource "aws_api_gateway_integration_response" "getSignedUrl_Post" {
  rest_api_id = aws_api_gateway_rest_api.upload_ui.id
  resource_id = aws_api_gateway_resource.getSignedUrl.id
  http_method = aws_api_gateway_method.getSignedUrl_Post.http_method
  status_code = aws_api_gateway_method_response.getSignedUrl_Post.status_code
}
resource "aws_api_gateway_resource" "lambda" {
  rest_api_id = aws_api_gateway_rest_api.upload_ui.id
  parent_id = aws_api_gateway_rest_api.upload_ui.root_resource_id
  path_part = aws_lambda_function.upload.function_name
}
resource "aws_api_gateway_method" "lambda_Any" {
  rest_api_id = aws_api_gateway_rest_api.upload_ui.id
  resource_id = aws_api_gateway_resource.lambda.id
  http_method = "ANY"
  authorization = "NONE"
  request_models = {}
}
resource "aws_api_gateway_method_response" "lambda_Any" {
  rest_api_id = aws_api_gateway_rest_api.upload_ui.id
  resource_id = aws_api_gateway_resource.lambda.id
  http_method = "ANY"
  status_code = "200"
}
resource "aws_api_gateway_integration" "lambda_Any" {
  rest_api_id = aws_api_gateway_rest_api.upload_ui.id
  resource_id = aws_api_gateway_resource.lambda.id
  http_method = aws_api_gateway_method.lambda_Any.http_method
  type        = "AWS_PROXY"
  uri = aws_lambda_function.upload.invoke_arn
}
resource "aws_api_gateway_integration_response" "lambda_Any" {
  rest_api_id = aws_api_gateway_rest_api.upload_ui.id
  resource_id = aws_api_gateway_resource.lambda.id
  http_method = aws_api_gateway_method.lambda_Any.http_method
  status_code = aws_api_gateway_method_response.lambda_Any.status_code
}
resource "aws_api_gateway_deployment" "upload_v1" {
  rest_api_id = aws_api_gateway_rest_api.upload_ui.id
  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.upload_ui.body))
  }
  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_api_gateway_stage" "upload_stage" {
  deployment_id = aws_api_gateway_deployment.upload_v1.id
  rest_api_id   = aws_api_gateway_rest_api.upload_ui.id
  stage_name    = "Stage"
}