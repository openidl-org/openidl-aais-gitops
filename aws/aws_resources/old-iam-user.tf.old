#IAM user and relevant credentials required for BAF automation
resource "aws_iam_user" "baf_user" {
  name = "${local.std_name}-baf-automation"
  force_destroy = true
  tags = merge(local.tags, { name = "${local.std_name}-baf-automation", cluster_type = "both" })
}
resource "aws_iam_access_key" "baf_user_access_key" {
  user = aws_iam_user.baf_user.name
  status = "Active"
  lifecycle {
    ignore_changes = [status]
  }
}
resource "aws_iam_user_policy_attachment" "baf_user_policy_attach" {
  user       = aws_iam_user.baf_user.name
  policy_arn = aws_iam_policy.eks_admin_policy.arn
}
