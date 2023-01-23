#S3 bucket for static content - UI
resource "aws_s3_bucket" "upload_ui" {
  bucket = "${local.std_name}-${var.s3_bucket_name_upload_ui}.${var.aws_env}.${local.public_domain}"
  force_destroy = true
  tags = merge( local.tags, {"name" = "${local.std_name}-${var.s3_bucket_name_upload_ui}.${var.aws_env}.${local.public_domain}"})
  acl  = "public-read"
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
#resource "aws_s3_bucket_logging" "upload_ui" {
#    bucket = aws_s3_bucket.upload_ui.id
#    target_prefix = "logs-upload-ui"
#    target_bucket = aws_s3_bucket.s3_bucket_access_logs.id
#    depends_on = [aws_s3_bucket.upload_ui]
#}
resource "aws_s3_bucket_public_access_block" "upload_ui" {
    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
    bucket = aws_s3_bucket.upload_ui.id
    depends_on = [aws_s3_bucket.upload_ui]
}
resource "aws_s3_bucket_policy" "upload_ui" {
  depends_on = [aws_cloudfront_origin_access_identity.origin_access_identity,aws_cloudfront_distribution.upload_ui]
  bucket = aws_s3_bucket.upload_ui.id
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowCloudFrontServicePrincipalReadOnly",
            "Effect": "Allow",
            "Principal": {
                "Service": "cloudfront.amazonaws.com"
            },
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::${local.std_name}-${var.s3_bucket_name_upload_ui}.${var.aws_env}.${local.public_domain}/*",
            "Condition": {
                "StringEquals": {
                    "AWS:SourceArn": "${aws_cloudfront_distribution.upload_ui.arn}"
                }
            }
        },
        {
            "Sid": "AllowPutObjects",
            "Effect": "Allow",
            "Principal": {
                "AWS": "${aws_iam_role.git_actions_admin_role.arn}"
            },
            "Action": [
                "s3:PutObject"
            ],
            "Resource": [
                "arn:aws:s3:::${local.std_name}-${var.s3_bucket_name_upload_ui}.${var.aws_env}.${local.public_domain}",
                "arn:aws:s3:::${local.std_name}-${var.s3_bucket_name_upload_ui}.${var.aws_env}.${local.public_domain}/*"
            ]
        },
        {
            "Sid": "AllowLegacyOAIReadOnly",
            "Effect": "Allow",
            "Principal": {
                "AWS": "${aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn}"
            },
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::${local.std_name}-${var.s3_bucket_name_upload_ui}.${var.aws_env}.${local.public_domain}/*"
        },
        #{
        #    "Sid": "AllowPublicAccess",
        #    "Effect": "Allow",
        #    "Principal": "*",
        #    "Action": [ "s3:GetObject", "s3:GetObjectVersion", "s3:ListBucket"],
        #    "Resource": [
        #        "arn:aws:s3:::${local.std_name}-${var.s3_bucket_name_upload_ui}.${var.aws_env}.${local.public_domain}",
        #        "arn:aws:s3:::${local.std_name}-${var.s3_bucket_name_upload_ui}.${var.aws_env}.${local.public_domain}/*",
        #    ]
        #},
        {
            "Sid": "AllowIAMAccess",
            "Effect": "Allow",
            "Principal": {
                "AWS": ["${var.aws_role_arn}"]
            },
            "Action": "*",
            "Resource": [
                "arn:aws:s3:::${local.std_name}-${var.s3_bucket_name_upload_ui}.${var.aws_env}.${local.public_domain}",
                "arn:aws:s3:::${local.std_name}-${var.s3_bucket_name_upload_ui}.${var.aws_env}.${local.public_domain}/*",
            ]
        },
        {
        "Sid": "DenyOthers",
        "Effect": "Deny",
        "Principal": "*",
        "NotAction": [ "s3:GetObject", "s3:GetObjectVersion", "s3:ListBucket", "s3:PutObject", "s3:PutBucketAcl", "s3:PutObjectAcl", "s3:PutObjectVersionAcl"],
        "Resource": [
          "arn:aws:s3:::${local.std_name}-${var.s3_bucket_name_upload_ui}.${var.aws_env}.${local.public_domain}",
          "arn:aws:s3:::${local.std_name}-${var.s3_bucket_name_upload_ui}.${var.aws_env}.${local.public_domain}/*",
        ],
        "Condition": {
		      "StringNotLike": {
		          "aws:userid": [
                  "${data.aws_iam_role.terraform_role.unique_id}:*",
                  "${data.aws_iam_user.terraform_user.user_id}",
				          "${var.aws_account_number}",
                  "arn:aws:sts:::${var.aws_account_number}:assumed-role/${local.terraform_role_name[1]}/terraform",
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
resource "zipper_file" "upload_zip" {
  source      = "./resources/openidl-upload-lambda/"
  output_path = "./openidl-upload-lambda.zip"
}
resource "aws_lambda_function" "upload" {
  function_name = "${local.std_name}-openidl-upload"
  role              = aws_iam_role.upload.arn
  architectures     = ["x86_64"]
  description       = "Openidl Upload UI"
  environment {
    variables = {
      FILE_UPLOAD_BUCKET = aws_s3_bucket.etl["intake"].id
    }
  }
  package_type = "Zip"
  runtime = "nodejs16.x"
  source_code_hash = "${zipper_file.upload_zip.output_sha}"
  handler = "src/getSignedUrl.handler"
  filename = "./openidl-upload-lambda.zip"
  timeout = "60"
  tags = merge(local.tags,{ "name" = "${local.std_name}-openidl-upload"})
  depends_on = [zipper_file.upload_zip]
}
resource "aws_lambda_function" "upload-control-table" {
  function_name = "${local.std_name}-openidl-upload-control-table"
  role              = aws_iam_role.upload.arn
  architectures     = ["x86_64"]
  description       = "Openidl Upload UI Control Table"
  environment {
    variables = {
      ETL_CONTROL_TABLE = "${aws_dynamodb_table.etl.name}"
    }
  }
  package_type = "Zip"
  runtime = "nodejs16.x"
  source_code_hash = "${zipper_file.upload_zip.output_sha}"
  handler = "src/control-table/read.handler"
  filename = "./openidl-upload-lambda.zip"
  timeout = "60"
  tags = merge(local.tags,{ "name" = "${local.std_name}-openidl-upload-control-table"})
  depends_on = [zipper_file.upload_zip,aws_dynamodb_table.etl]
}
resource "aws_lambda_function" "upload-cors" {
  function_name = "${local.std_name}-openidl-upload-cors"
  role              = aws_iam_role.upload.arn
  architectures     = ["x86_64"]
  description       = "Openidl Upload UI Cors"
  package_type = "Zip"
  runtime = "nodejs16.x"
  source_code_hash = "${zipper_file.upload_zip.output_sha}"
  handler = "src/cors/options.handler"
  filename = "./openidl-upload-lambda.zip"
  timeout = "30"
  tags = merge(local.tags,{ "name" = "${local.std_name}-openidl-upload-cors"})
  depends_on = [zipper_file.upload_zip]
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
                "s3:PutObject"
			],
            "Resource": [
                "arn:aws:s3:::${aws_s3_bucket.etl["intake"].id}/*",
            ]
        },
        {
            "Sid": "AllowS3Bucket",
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket",
                "s3:GetBucketLocation"
            ],
            "Resource": "arn:aws:s3:::${aws_s3_bucket.etl["intake"].id}"
        },
        {
            "Sid": "AllowDynamoDB",
            "Effect": "Allow",
            "Action": [
                "dynamodb:PutItem",
                "dynamodb:GetItem",
                "dynamodb:UpdateItem",
                "dynamodb:Scan"
            ],
            "Resource": "arn:aws:dynamodb:${var.aws_region}:${var.aws_account_number}:table/${local.std_name}-openidl-etl-control-table"
        },
        {
            "Sid": "AllowKMS",
            "Effect": "Allow",
            "Action": [
                "kms:Decrypt",
                "kms:GenerateDataKey"
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
  source_arn    = "arn:aws:execute-api:${var.aws_region}:${var.aws_account_number}:${aws_api_gateway_rest_api.upload_ui.id}/*/POST/getSignedUrl"
}
#update source_arn after API GW is defined
resource "aws_lambda_permission" "upload-cors" {
  statement_id  = "AllowExecutionFromAPIGW"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.upload-cors.arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.aws_region}:${var.aws_account_number}:${aws_api_gateway_rest_api.upload_ui.id}/*/OPTIONS/getSignedUrl"
}
resource "aws_lambda_permission" "upload-control-table" {
  statement_id  = "AllowExecutionFromAPIGW"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.upload-control-table.arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.aws_region}:${var.aws_account_number}:${aws_api_gateway_rest_api.upload_ui.id}/*/GET/control-table"
}
#create APIGW
resource "aws_api_gateway_rest_api" "upload_ui" {
  name          = "${local.std_name}-upload-ui"
  endpoint_configuration {
    types = ["EDGE"]
  }
}
resource "aws_lambda_permission" "upload-control-table-cors" {
  statement_id  = "AllowExecutionFromAPIGWControlTable"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.upload-cors.arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.aws_region}:${var.aws_account_number}:${aws_api_gateway_rest_api.upload_ui.id}/*/OPTIONS/control-table"
}
resource "aws_api_gateway_authorizer" "upload" {
  depends_on = [data.aws_cognito_user_pools.user_pool]
  name = "${local.std_name}-openidl-upload"
  rest_api_id = aws_api_gateway_rest_api.upload_ui.id
  authorizer_uri = aws_lambda_function.upload.invoke_arn
  type = "COGNITO_USER_POOLS"
  provider_arns = data.aws_cognito_user_pools.user_pool.arns
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
resource "aws_api_gateway_documentation_part" "upload-control-table_method" {
  rest_api_id = aws_api_gateway_rest_api.upload_ui.id
  location {
    type = "METHOD"
    path = "/control-table"
    method = "OPTIONS"
  }
  properties = jsonencode(
    {
     "summary": "CORS support"
    })
}
resource "aws_api_gateway_documentation_part" "upload-control-table_response" {
  rest_api_id = aws_api_gateway_rest_api.upload_ui.id
  location {
    type = "RESPONSE"
    path = "/control-table"
    method = "OPTIONS"
    status_code = "200"
  }
  properties = jsonencode(
    {
      "description": "Default response for CORS method"
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
resource "aws_api_gateway_resource" "control-table" {
  rest_api_id = aws_api_gateway_rest_api.upload_ui.id
  parent_id = aws_api_gateway_rest_api.upload_ui.root_resource_id
  path_part = "control-table"
}
resource "aws_api_gateway_method" "getSignedUrl_Options" {
  rest_api_id = aws_api_gateway_rest_api.upload_ui.id
  resource_id = aws_api_gateway_resource.getSignedUrl.id
  http_method = "OPTIONS"
  authorization = "NONE"
}
resource "aws_api_gateway_method_response" "getSignedUrl_Options" {
  rest_api_id = aws_api_gateway_rest_api.upload_ui.id
  resource_id = aws_api_gateway_resource.getSignedUrl.id
  http_method = "OPTIONS"
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Origin" = true
  }
  response_models = {
    "application/json" = "Empty"
  }
  depends_on = [aws_api_gateway_method.getSignedUrl_Options]
}
resource "aws_api_gateway_integration" "getSignedUrl_Options" {
  rest_api_id = aws_api_gateway_rest_api.upload_ui.id
  resource_id = aws_api_gateway_resource.getSignedUrl.id
  http_method = aws_api_gateway_method.getSignedUrl_Options.http_method
  type        = "AWS_PROXY"
  integration_http_method = "POST"
  uri = aws_lambda_function.upload-cors.invoke_arn
  depends_on = [aws_api_gateway_method.getSignedUrl_Options, aws_api_gateway_method_response.getSignedUrl_Options]
}
resource "aws_api_gateway_integration_response" "getSignedUrl_Options" {
  rest_api_id = aws_api_gateway_rest_api.upload_ui.id
  resource_id = aws_api_gateway_resource.getSignedUrl.id
  http_method = aws_api_gateway_method.getSignedUrl_Options.http_method
  status_code = aws_api_gateway_method_response.getSignedUrl_Options.status_code
  depends_on = [aws_api_gateway_integration.getSignedUrl_Options]
}
resource "aws_api_gateway_method" "getSignedUrl_Post" {
  rest_api_id = aws_api_gateway_rest_api.upload_ui.id
  resource_id = aws_api_gateway_resource.getSignedUrl.id
  http_method = "POST"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.upload.id
  request_models = {}
}
resource "aws_api_gateway_method_response" "getSignedUrl_Post" {
  rest_api_id = aws_api_gateway_rest_api.upload_ui.id
  resource_id = aws_api_gateway_resource.getSignedUrl.id
  http_method = aws_api_gateway_method.getSignedUrl_Post.http_method
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Origin" = true
  }
  response_models = {
    "application/json" = "Empty"
  }
  depends_on = [aws_api_gateway_method.getSignedUrl_Post]
}
resource "aws_api_gateway_integration" "getSignedUrl_Post" {
  rest_api_id = aws_api_gateway_rest_api.upload_ui.id
  resource_id = aws_api_gateway_resource.getSignedUrl.id
  http_method = aws_api_gateway_method.getSignedUrl_Post.http_method
  type        = "AWS_PROXY"
  integration_http_method = "POST"
  uri = aws_lambda_function.upload.invoke_arn
  depends_on = [aws_api_gateway_method_response.getSignedUrl_Post]
}
resource "aws_api_gateway_integration_response" "getSignedUrl_Post" {
  rest_api_id         = aws_api_gateway_rest_api.upload_ui.id
  resource_id         = aws_api_gateway_resource.getSignedUrl.id
  http_method         = aws_api_gateway_method.getSignedUrl_Post.http_method
  status_code         = aws_api_gateway_method_response.getSignedUrl_Post.status_code
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'OPTIONS,POST'",
    "method.response.header.Access-Control-Allow-Origin" = "'*.${var.aws_env}.${local.public_domain}'"
  }
  depends_on = [aws_api_gateway_integration.getSignedUrl_Post]
}
resource "aws_api_gateway_method" "control-table_Get" {
  rest_api_id = aws_api_gateway_rest_api.upload_ui.id
  resource_id = aws_api_gateway_resource.control-table.id
  http_method = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.upload.id
  request_models = {}
}
resource "aws_api_gateway_method_response" "control-table_Get" {
  rest_api_id = aws_api_gateway_rest_api.upload_ui.id
  resource_id = aws_api_gateway_resource.control-table.id
  http_method = aws_api_gateway_method.control-table_Get.http_method
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Origin" = true
  }
  response_models = {
    "application/json" = "Empty"
  }
  depends_on = [aws_api_gateway_method.control-table_Get]
}
resource "aws_api_gateway_integration" "control-table_Get" {
  rest_api_id = aws_api_gateway_rest_api.upload_ui.id
  resource_id = aws_api_gateway_resource.control-table.id
  http_method = aws_api_gateway_method.control-table_Get.http_method
  type        = "AWS_PROXY"
  integration_http_method = "POST"
  uri = aws_lambda_function.upload-control-table.invoke_arn
  depends_on = [aws_api_gateway_method_response.control-table_Get]
}
resource "aws_api_gateway_integration_response" "control-table_Get" {
  rest_api_id         = aws_api_gateway_rest_api.upload_ui.id
  resource_id         = aws_api_gateway_resource.control-table.id
  http_method         = aws_api_gateway_method.control-table_Get.http_method
  status_code         = aws_api_gateway_method_response.control-table_Get.status_code
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'OPTIONS,GET'",
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
  depends_on = [aws_api_gateway_integration.control-table_Get]
}
resource "aws_api_gateway_method" "control-table_Options" {
  rest_api_id = aws_api_gateway_rest_api.upload_ui.id
  resource_id = aws_api_gateway_resource.control-table.id
  http_method = "OPTIONS"
  authorization = "NONE"
}
resource "aws_api_gateway_method_response" "control-table_Options" {
  rest_api_id = aws_api_gateway_rest_api.upload_ui.id
  resource_id = aws_api_gateway_resource.control-table.id
  http_method = "OPTIONS"
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Origin" = true
  }
  response_models = {
    "application/json" = "Empty"
  }
  depends_on = [aws_api_gateway_method.control-table_Options]
}
resource "aws_api_gateway_integration" "control-table_Options" {
  rest_api_id = aws_api_gateway_rest_api.upload_ui.id
  resource_id = aws_api_gateway_resource.control-table.id
  http_method = aws_api_gateway_method.control-table_Options.http_method
  type        = "AWS_PROXY"
  integration_http_method = "POST"
  uri = aws_lambda_function.upload-cors.invoke_arn
  depends_on = [aws_api_gateway_method.control-table_Options, aws_api_gateway_method_response.control-table_Options]
}
resource "aws_api_gateway_integration_response" "control-table_Options" {
  rest_api_id = aws_api_gateway_rest_api.upload_ui.id
  resource_id = aws_api_gateway_resource.control-table.id
  http_method = aws_api_gateway_method.control-table_Options.http_method
  status_code = aws_api_gateway_method_response.control-table_Options.status_code
  depends_on = [aws_api_gateway_integration.control-table_Options]
}
resource "aws_api_gateway_deployment" "upload_v1" {
  rest_api_id = aws_api_gateway_rest_api.upload_ui.id
  
  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_rest_api.upload_ui.body,
      aws_api_gateway_method.getSignedUrl_Post.id,
      aws_api_gateway_method.getSignedUrl_Options.id,
      aws_api_gateway_method_response.getSignedUrl_Post.id,
      aws_api_gateway_method_response.getSignedUrl_Options.id,
      aws_api_gateway_integration.getSignedUrl_Post.id,
      aws_api_gateway_integration.getSignedUrl_Options.id,
      aws_api_gateway_integration_response.getSignedUrl_Post.id,
      aws_api_gateway_integration_response.getSignedUrl_Options.id,
      aws_api_gateway_resource.getSignedUrl.id,
      aws_api_gateway_method.control-table_Get.id,
      aws_api_gateway_method.control-table_Options.id,
      aws_api_gateway_method_response.control-table_Get.id,
      aws_api_gateway_method_response.control-table_Options.id,
      aws_api_gateway_integration.control-table_Get.id,
      aws_api_gateway_integration.control-table_Options.id,
      aws_api_gateway_integration_response.control-table_Get.id,
      aws_api_gateway_integration_response.control-table_Options.id,
      aws_api_gateway_resource.control-table.id
    ]))
  }
  lifecycle {
    create_before_destroy = true
  }
  depends_on = [
    aws_api_gateway_resource.getSignedUrl,
    aws_api_gateway_integration_response.getSignedUrl_Post,
    aws_api_gateway_integration_response.getSignedUrl_Options,
    aws_api_gateway_resource.control-table,
    aws_api_gateway_integration_response.control-table_Get,
    aws_api_gateway_integration_response.control-table_Options]
}
resource "aws_api_gateway_stage" "stage" {
  deployment_id = aws_api_gateway_deployment.upload_v1.id
  rest_api_id   = aws_api_gateway_rest_api.upload_ui.id
  stage_name    = "${var.aws_env}"
}
resource "aws_cloudfront_distribution" "upload_ui" {
  depends_on = [aws_s3_bucket.upload_ui,aws_acm_certificate.upload_ui,aws_cloudfront_origin_access_identity.origin_access_identity]
  origin {
    domain_name = "${aws_s3_bucket.upload_ui.bucket_regional_domain_name}"
    origin_id   = "${local.std_name}-${var.s3_bucket_name_upload_ui}.${var.aws_env}.${local.public_domain}"
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
    }
  }
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  aliases = ["${local.std_name}-${var.s3_bucket_name_upload_ui}.${var.aws_env}.${local.public_domain}"]
  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US", "CA"]
    }
  }
  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${local.std_name}-${var.s3_bucket_name_upload_ui}.${var.aws_env}.${local.public_domain}"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }
  viewer_certificate {
    cloudfront_default_certificate = false
    acm_certificate_arn = aws_acm_certificate.upload_ui.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
}
resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "access-identity-${local.std_name}-${var.s3_bucket_name_upload_ui}.${var.aws_env}.${local.public_domain}.s3.amazonaws.com"
}
