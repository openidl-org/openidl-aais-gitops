output "s3_intake_bucket" {
  value = data.aws_s3_bucket.intake.arn
}
output "s3_static_website_bucket" {
  value = aws_s3_bucket.upload_ui.arn
}
output "cognito_user_pool" {
  value = data.aws_cognito_user_pools.user_pool.ids[0]
}
output "cognito_user_pool_client" {
  value = data.aws_cognito_user_pool_client.user_pool_client.id
}
output "s3_website_endpoint" {
  value = aws_s3_bucket.upload_ui.website_endpoint
}
output "api_gateway_endpoint" {
  value = aws_api_gateway_deployment.upload_v1.invoke_url
}
