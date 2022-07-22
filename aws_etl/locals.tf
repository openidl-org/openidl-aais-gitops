locals {
  tags = { name =  "aais-dev"}
  std_name = "aais-dev"
  terraform_user_name = split("/", var.aws_user_arn)
  terraform_role_name = split("/", var.aws_role_arn)
  config-intake = templatefile("resources/config-intake.tftpl",
    {
      successBucket = "${aws_s3_bucket.etl["idm-loader"].arn}",
      failureBucket = "${aws_s3_bucket.etl["failure"].arn}",
      dynamoDB = "${aws_dynamodb_table.etl.name}",
      successTopicARN = "${aws_sns_topic.etl["success"].arn}",
      failureTopicARN = "${aws_sns_topic.etl["failure"].arn}",
      state = "${var.org_name}"
    })
  config-success = templatefile("resources/config-success.tftpl",
    {
      dynamoDB = "${aws_dynamodb_table.etl.name}",
      successTopicARN = "${aws_sns_topic.etl["success"].arn}",
      failureTopicARN = "${aws_sns_topic.etl["failure"].arn}",
      apiUsername = "${local.std_name}-etl-user",
      apiPassword = "Passw0rd123",
      carrierId = "1234",
      utilitiesAPIUrl = "https://utilties-service.dev.thetech.digital",
      idmAPIUrl = "https://insurance-data-manager-service.dev.thetech.digital"
    })
}

