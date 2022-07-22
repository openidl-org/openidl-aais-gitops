#DynamoDB table
#output "dynamodb_connection" {
#  value = aws_dynamodb_table.etl_dynamodb.connection
#}
output "dynamodb_arn" {
  value = aws_dynamodb_table.etl.arn
}
output "s3-bucket-idm-loader" {
  value = aws_s3_bucket.etl["idm-loader"].arn
}
output "s3-bucket-intake" {
  value = aws_s3_bucket.etl["intake"].arn
}
output "s3-bucket-failures" {
  value = aws_s3_bucket.etl["failure"].arn
}
