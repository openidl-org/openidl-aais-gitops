resource "aws_iam_role" "custom_message_lambda" {
  count = var.create_cognito_userpool ? 1 : 0
  name = "${local.std_name}-openidl-custom-message"
  managed_policy_arns = [aws_iam_policy.custom_message_lambda_role_policy[count.index].arn]
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
  tags = merge(local.tags, { "name" = "${local.std_name}-openidl-custom-message-lambda"})
}
resource "aws_iam_policy" "custom_message_lambda_role_policy" {
  count = var.create_cognito_userpool ? 1 : 0
  name = "${local.std_name}-custom-message-lambda-role-policy"
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
            "Sid": "AllowCognito",
            "Effect": "Allow",
            "Action": [
              "cognito-idp:ListUserPoolClients"
			      ],
            "Resource": [
                "arn:aws:cognito-idp:${var.aws_region}:${var.aws_account_number}:userpool/*"
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
    name = "${local.std_name}-custom-message-lambda-role-policy"
  })
}
resource "zipper_file" "custom_message_zip" {
  count = var.create_cognito_userpool ? 1 : 0
  source      = "./resources/openidl-cognito-custom-message/"
  output_path = "./resources/openidl-cognito-custom-message.zip"
}
resource "aws_lambda_permission" "custom-message" {
  count = var.create_cognito_userpool ? 1 : 0
  statement_id  = "AllowExecutionFromCognito"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.custom-message[count.index].arn
  principal     = "cognito-idp.amazonaws.com"
  source_arn    = "${aws_cognito_user_pool.user_pool[count.index].arn}"
  depends_on = [ aws_lambda_function.custom-message ]
}
resource "aws_lambda_function" "custom-message" {
  count = var.create_cognito_userpool ? 1 : 0
  function_name = "${local.std_name}-openidl-custom-message"
  role              = aws_iam_role.custom_message_lambda[count.index].arn
  architectures     = ["x86_64"]
  description       = "Openidl Cognito Custom Message"
  environment {
    variables = {
      APP_CLIENT_NAME	= "${local.client_app_name}"
      COGNITO_DOMAIN = "${local.cognito_domain}"
      REDIRECT_URI = "${local.client_default_redirect_url}"
    }
  }
  package_type = "Zip"
  source_code_hash = "${zipper_file.custom_message_zip[count.index].output_sha}"
  runtime = "nodejs16.x"
  handler = "index.handler"
  filename = "./resources/openidl-cognito-custom-message.zip"
  timeout = "15"
  publish = "true"
  tags = merge(local.tags,{ "name" = "${local.std_name}-openidl-custom-message"})
  depends_on = [zipper_file.custom_message_zip]
}
#Setting up congnito user pool
resource "aws_cognito_user_pool" "user_pool" {
  count = var.create_cognito_userpool ? 1 : 0
  name = "${local.std_name}-${var.userpool_name}"
  dynamic "account_recovery_setting" {
    for_each = length(var.userpool_recovery_mechanisms) == 0 ? [] : [1]
    content {
      dynamic "recovery_mechanism" {
        for_each = var.userpool_recovery_mechanisms
        content {
          name     = lookup(recovery_mechanism.value, "name")
          priority = lookup(recovery_mechanism.value, "priority")
        }
      }
    }
  }
  admin_create_user_config {
    allow_admin_create_user_only = var.userpool_allow_admin_create_user_only
    invite_message_template {
      email_message = "Your username is {username}, and password is {####}."
      email_subject = "Your password"
      sms_message   = "Your username is {username} and password is {####}."
    }
  }
  lambda_config {
    custom_message = aws_lambda_function.custom-message[count.index].arn
  }
  #alias_attributes = var.userpool_alais_attributes
  username_attributes      = var.userpool_username_attributes
  auto_verified_attributes = var.userpool_auto_verified_attributes
  #device_configuration {
  #  challenge_required_on_new_device      = var.userpool_challenge_required_on_new_device
  #  device_only_remembered_on_user_prompt = var.userpool_device_only_remembered_on_user_prompt
  #}
  email_configuration {
    reply_to_email_address = var.email_sending_account == "DEVELOPER" ? var.ses_email_identity : null
    source_arn             = var.email_sending_account == "DEVELOPER" ? var.userpool_email_source_arn : null
    email_sending_account  = var.email_sending_account
    from_email_address     = var.email_sending_account == "DEVELOPER" ? var.ses_email_identity : null
  }
  email_verification_subject = var.userpool_email_verification_subject != "" ? var.userpool_email_verification_subject : "Your password"
  email_verification_message = var.userpool_email_verification_message != "" ? var.userpool_email_verification_message : "Your username is {username}, and password is {####}."
  mfa_configuration          = var.userpool_mfa_configuration
  software_token_mfa_configuration {
    enabled = var.userpool_software_token_mfa_enabled
  }
  password_policy {
    minimum_length                   = var.password_policy_minimum_length
    require_lowercase                = var.password_policy_require_lowercase
    require_numbers                  = var.password_policy_require_numbers
    require_symbols                  = var.password_policy_require_symbols
    require_uppercase                = var.password_policy_require_uppercase
    temporary_password_validity_days = var.password_policy_temporary_password_validity_days
  }
  sms_authentication_message = "Your username is {username} and password is {####}."
  sms_verification_message   = "This is the verification message {####}."

  user_pool_add_ons {
    advanced_security_mode = var.userpool_advanced_security_mode
  }
  username_configuration {
    case_sensitive = var.userpool_enable_username_case_sensitivity
  }
  verification_message_template {
    default_email_option = "CONFIRM_WITH_CODE"
  }
  dynamic "schema" {
    for_each = local.custom_attributes
    content {
      attribute_data_type      = "String"
      name                     = schema.value
      developer_only_attribute = false
      mutable                  = true
      string_attribute_constraints {
        min_length = 1
        max_length = 256
      }
    }
  }
  tags = merge(
    local.tags,
    {
      "name"         = "${local.std_name}-${var.userpool_name}"
      "cluster_type" = "application"
  }, )
}
#Setting up cognito application client in the userpool
resource "aws_cognito_user_pool_client" "cognito_app_client" {
  count = var.create_cognito_userpool ? 1 : 0
  name                                 = "${local.client_app_name}"
  user_pool_id                         = aws_cognito_user_pool.user_pool[0].id
  allowed_oauth_flows                  = var.client_allowed_oauth_flows
  allowed_oauth_flows_user_pool_client = var.client_allowed_oauth_flows_user_pool_client
  allowed_oauth_scopes                 = var.client_allowed_oauth_scopes
  callback_urls                        = local.client_callback_urls
  default_redirect_uri                 = local.client_default_redirect_url
  explicit_auth_flows                  = var.client_explicit_auth_flows
  generate_secret                      = var.client_generate_secret
  logout_urls                          = local.client_logout_urls
  read_attributes                      = var.client_read_attributes
  refresh_token_validity               = var.client_refresh_token_validity
  supported_identity_providers         = var.client_supported_idp
  prevent_user_existence_errors        = var.client_prevent_user_existence_errors
  id_token_validity                    = var.client_id_token_validity
  write_attributes                     = var.client_write_attributes
  access_token_validity                = var.client_access_token_validity
  token_validity_units {
    access_token  = lookup(var.client_token_validity_units, "access_token", null)
    id_token      = lookup(var.client_token_validity_units, "id_token", null)
    refresh_token = lookup(var.client_token_validity_units, "refresh_token", null)
  }
}
#AWS cognito domain (custom/out-of-box) specification
resource "aws_cognito_user_pool_domain" "domain" {
  count = var.create_cognito_userpool ? 1 : 0
  domain = local.cognito_domain
  # certificate_arn = var.acm_cert_arn #activate when custom domain is required
  user_pool_id = aws_cognito_user_pool.user_pool[0].id
}
