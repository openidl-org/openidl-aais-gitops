#IAM role for application cluster and blockchain cluster (eks)
resource "aws_iam_role" "eks_cluster_role" {
  for_each           = toset(["app-eks", "blk-eks"])
  name               = "${local.std_name}-${each.value}"
  assume_role_policy = file("resources/policies/cluster-role-trust-policy.json")
  tags = merge(
    local.tags,
    {
      "name"         = "${local.std_name}-${each.value}"
      "cluster_type" = "${each.value}"
  }, )
}
resource "aws_iam_role_policy_attachment" "eks_cluster_AmazonEKSClusterPolicy" {
  for_each   = toset(["app-eks", "blk-eks"])
  policy_arn = "${local.policy_arn_prefix}/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role["${each.value}"].id
}
resource "aws_iam_role_policy_attachment" "eks_cluster_AmazonEKSVPCResourceController" {
  for_each   = toset(["app-eks", "blk-eks"])
  policy_arn = "${local.policy_arn_prefix}/AmazonEKSVPCResourceController"
  #role       = aws_iam_role.app-eks-cluster.name
  role = aws_iam_role.eks_cluster_role["${each.value}"].id
}
resource "aws_iam_role_policy_attachment" "eks_cluster_AmazonEKSServicePolicy" {
  for_each   = toset(["app-eks", "blk-eks"])
  policy_arn = "${local.policy_arn_prefix}/AmazonEKSServicePolicy"
  role       = aws_iam_role.eks_cluster_role["${each.value}"].id
}
resource "aws_iam_role_policy_attachment" "eks_cluster_AmazonEKSCNIPolicy" {
  for_each   = toset(["app-eks", "blk-eks"])
  policy_arn = "${local.policy_arn_prefix}/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_cluster_role["${each.value}"].id
}
resource "aws_iam_role_policy_attachment" "eks_cluster_AmazonEKSWorkerNodePolicy" {
  for_each   = toset(["app-eks", "blk-eks"])
  policy_arn = "${local.policy_arn_prefix}/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_cluster_role["${each.value}"].id
}
resource "aws_iam_role_policy_attachment" "eks_cluster_AmazonEC2ContainerRegistryReadOnly" {
  for_each   = toset(["app-eks", "blk-eks"])
  policy_arn = "${local.policy_arn_prefix}/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_cluster_role["${each.value}"].id
}
#IAM role for worker nodes of both application cluster and blockchain cluster (eks)
resource "aws_iam_role" "eks_nodegroup_role" {
  for_each           = toset(["app-node-group", "blk-node-group"])
  name               = "${local.std_name}-${each.value}"
  assume_role_policy = file("resources/policies/workergroup-role-trust-policy.json")
  tags = merge(
    local.tags,
    {
      "name"               = "${local.std_name}-${each.value}"
      "cluster_node_group" = "${each.value}"
  }, )
}
resource "aws_iam_role_policy_attachment" "eks_nodegroup_AmazonEKSWorkerNodePolicy" {
  for_each   = toset(["app-node-group", "blk-node-group"])
  policy_arn = "${local.policy_arn_prefix}/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_nodegroup_role["${each.value}"].id
}
resource "aws_iam_role_policy_attachment" "eks_nodegroup_AmazonEC2ContainerRegistryReadOnly" {
  for_each   = toset(["app-node-group", "blk-node-group"])
  policy_arn = "${local.policy_arn_prefix}/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_nodegroup_role["${each.value}"].id
}
resource "aws_iam_role_policy_attachment" "eks_nodegroup_AmazonEKSCNIPolicy" {
  for_each   = toset(["app-node-group", "blk-node-group"])
  policy_arn = "${local.policy_arn_prefix}/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_nodegroup_role["${each.value}"].id
}
#IAM policy for the worker nodes to manage csi driver for persistent volumes
resource "aws_iam_policy" "eks_worker_node_ebs_policy" {
  name   = "${local.std_name}-AmazonEBSCSIDriverPolicy"
  policy = file("resources/policies/workergroup-role-ebs-ci-driver-policy.json")
  tags = merge(local.tags,
    { "name" = "${local.std_name}-AmazonEBSCSIDriverPolicy",
  "cluster_type" = "both" })
}
resource "aws_iam_role_policy_attachment" "eks_nodegroup_AmazonEKSEBSCSIDriverPolicy" {
  for_each   = toset(["app-node-group", "blk-node-group"])
  policy_arn = aws_iam_policy.eks_worker_node_ebs_policy.arn
  role       = aws_iam_role.eks_nodegroup_role["${each.value}"].id
}
#IAM policy for the worker nodes to get access to Describe KMS key
resource "aws_iam_policy" "eks_worker_node_kms_policy" {
  name   = "${local.std_name}-AmazonKMSKeyPolicy"
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowDescribeKMSKey",
            "Effect": "Allow",
            "Action": ["kms:DescribeKey"],
            "Resource": "*"
        }
    ]})
  tags = merge(local.tags,
    { "name" = "${local.std_name}-AmazonKMSKeyPolicy",
  "cluster_type" = "both" })
}
resource "aws_iam_role_policy_attachment" "eks_nodegroup_AmazonKMSKeyPolicy" {
  for_each   = toset(["app-node-group", "blk-node-group"])
  policy_arn = aws_iam_policy.eks_worker_node_kms_policy.arn
  role       = aws_iam_role.eks_nodegroup_role["${each.value}"].id
}
#IAM policy for EKS admin role
resource "aws_iam_policy" "eks_admin_policy" {
  name   = "${local.std_name}-EKSAdminPolicy"
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowEKS",
            "Effect": "Allow",
            "Action": [
                "eks:*"
            ],
            "Resource": [
              "arn:aws:eks:${var.aws_region}:${var.aws_account_number}:cluster/${local.app_cluster_name}",
              "arn:aws:eks:${var.aws_region}:${var.aws_account_number}:cluster/${local.blk_cluster_name}",
              "arn:aws:eks:${var.aws_region}:${var.aws_account_number}:*/${local.app_cluster_name}/*",
              "arn:aws:eks:${var.aws_region}:${var.aws_account_number}:*/${local.blk_cluster_name}/*",
              ]
        },
        {
            "Sid": "AllowPassRole",
            "Effect": "Allow",
            "Action": "iam:PassRole",
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "iam:PassedToService": "eks.amazonaws.com"
                }
            }
        },
        {
            "Sid": "AllowEKSRead",
            "Effect": "Allow",
            "Action": [
                "iam:ListPolicies",
                "iam:GetPolicyVersion",
                "eks:ListNodegroups",
                "eks:DescribeFargateProfile",
                "iam:GetPolicy",
                "eks:ListTagsForResource",
                "iam:ListGroupPolicies",
                "eks:ListAddons",
                "eks:DescribeAddon",
                "eks:ListFargateProfiles",
                "eks:DescribeNodegroup",
                "iam:ListPolicyVersions",
                "eks:DescribeIdentityProviderConfig",
                "eks:ListUpdates",
                "eks:DescribeUpdate",
                "eks:AccessKubernetesApi",
                "iam:ListUsers",
                "iam:ListAttachedGroupPolicies",
                "eks:DescribeCluster",
                "iam:GetGroupPolicy",
                "eks:ListClusters",
                "eks:DescribeAddonVersions",
                "eks:ListIdentityProviderConfigs"
            ],
            "Resource": "*"
        },
        {
            "Sid": "ViewOwnUserInfo",
            "Effect": "Allow",
            "Action": [
                "iam:GetUserPolicy",
                "iam:ListGroupsForUser",
                "iam:ListAttachedUserPolicies",
                "iam:ListUserPolicies",
                "iam:GetUser"
            ],
            "Resource": [
                "arn:aws:iam::*:user/$${aws:username}"
            ]
        },
        {
            "Sid": "NavigateInConsole",
            "Effect": "Allow",
            "Action": [
                "iam:GetGroupPolicy",
                "iam:GetPolicyVersion",
                "iam:GetPolicy",
                "iam:ListAttachedGroupPolicies",
                "iam:ListGroupPolicies",
                "iam:ListPolicyVersions",
                "iam:ListPolicies",
                "iam:ListUsers"
            ],
            "Resource": "*"
        },
        {
            "Sid": "ListRoles",
            "Effect": "Allow",
            "Action": [
                "iam:ListRoles"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Sid": "AllowSSM",
            "Effect": "Allow",
            "Action": [
                "ssm:GetParameter"
            ],
            "Resource": [
                "arn:aws:ssm:*:${var.aws_account_number}:parameter/*"
            ]
        }

    ]
})
  tags = merge(local.tags,
    { "name" = "${local.std_name}-EKSAdminPolicy",
  "cluster_type" = "both" })
}
#IAM role - to perform EKS administrative tasks
resource "aws_iam_role" "eks_admin_role" {
  name = "${local.std_name}-eksadmin"
  assume_role_policy = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${var.aws_account_number}:root"
      },
      "Action": "sts:AssumeRole",
      "Condition": {}
    }]
  })
  managed_policy_arns = [aws_iam_policy.eks_admin_policy.arn]
  tags = merge(local.tags, {name = "${local.std_name}-eks-admin", cluster_type = "both"})
  description = "The iam role that is used to manage EKS cluster administrative tasks"
  max_session_duration = 3600
}
#IAM group that allows users to assume eks-admin-role
resource "aws_iam_group" "eks_admin_group" {
  name = "${local.std_name}-eks-admin"
}
#IAM group eks-admin and its related policy attachment
resource "aws_iam_group_policy_attachment" "eks_admin_group_policy_attachment" {
  group = aws_iam_group.eks_admin_group.name
  policy_arn = aws_iam_policy.eks_admin_group_assume_policy.arn
}
#IAM policy for eks-admin-role
resource "aws_iam_policy" "eks_admin_group_assume_policy" {
  name = "${local.std_name}-EKSAdmPolicy"
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "VisualEditor1",
        "Effect": "Allow",
        "Action": "sts:AssumeRole",
        "Resource": aws_iam_role.eks_admin_role.arn
      }]
  })
  tags = merge(local.tags, {
    name = "${local.std_name}-EKSAdmPolicy",
    cluster_type = "both"
  })
}
