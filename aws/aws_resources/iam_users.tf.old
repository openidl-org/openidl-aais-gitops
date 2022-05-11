#IAM user and relevant credentials required for BAF automation
resource "aws_iam_user" "baf_user" {
  name = "${local.std_name}-baf-automation"
  force_destroy = true
  tags = merge(local.tags, { Name = "${local.std_name}-baf-automation", Cluster_type = "both" })
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
#IAM user and relevant credentials to use with github actions for EKS resource provisioning
resource "aws_iam_user" "git_actions_user" {
  name = "${local.std_name}-gitactions-eksadm"
  force_destroy = true
  tags = merge(local.tags, { Name = "${local.std_name}-gitactions-eksadm", Cluster_type = "both" })
}
resource "aws_iam_access_key" "git_actions_access_key" {
  user = aws_iam_user.git_actions_user.name
  status = "Active"
  lifecycle {
    ignore_changes = [status]
  }
}
#IAM policy to assume git actions role for git actions user
resource "aws_iam_user_policy" "git_actions_policy" {
  name = "${local.std_name}-gitactions-eksadm"
  user = aws_iam_user.git_actions_user.name
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "sts:AssumeRole",
                "sts:TagSession"
            ],
            "Resource": "arn:aws:iam::${var.aws_account_number}:role/${aws_iam_role.git_actions_admin_role.name}",
            "Effect": "Allow",
            "Condition": {
                "StringEquals": {
                    "sts:ExternalId": "git-actions"
                }
            }
        }
    ]
  })
}
#iam policy for git actions role
resource "aws_iam_policy" "git_actions_admin_policy" {
  name   = "${local.std_name}-AmazonEKSSMAdminPolicy"
  policy = file("resources/policies/git-actions-admin-policy.json")
  tags = merge(local.tags,
    { "Name" = "${local.std_name}-AmazonEKSSMAdminPolicy",
  "Cluster_type" = "both" })
}
#iam role - to perform git actions on EKS resources
resource "aws_iam_role" "git_actions_admin_role" {
  name = "${local.std_name}-gitactions-eksadm"
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "sts:AssumeRole",
                "sts:TagSession"
            ],
            "Principal": { "AWS": "arn:aws:iam::${var.aws_account_number}:user/${aws_iam_user.git_actions_user.name}"},
            "Effect": "Allow",
            "Condition": {
                "StringEquals": {
                    "sts:ExternalId": "git-actions"
                }
            }
        }
    ]
  })
  managed_policy_arns = [aws_iam_policy.git_actions_admin_policy.arn]
  tags = merge(local.tags, {Name = "${local.std_name}-gitactions-eksadm", Cluster_type = "both"})
  description = "The iam role that is used to manage EKS cluster resources using git actions"
  max_session_duration = 7200
}
