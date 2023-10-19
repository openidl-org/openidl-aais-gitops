#variable "example" {
#  default = {
#    key1 = "value1"
#    key2 = "value2"
#  }
#
#  type = map(string)
#}
##aws_cognito_user_pool.user_pool
#
#resource "aws_secretsmanager_secret_version" "example" {
#  secret_id     = aws_secretsmanager_secret.example.id
#  secret_string = jsonencode(var.example)
#}