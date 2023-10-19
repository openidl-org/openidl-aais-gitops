#IAM user specifics related to BAF automation pipeline
resource "aws_iam_user" "baf_user" {
  name = "${local.std_name}-baf-user"
  force_destroy = true
  tags = merge(local.tags, { name = "${local.std_name}-baf-user", cluster_type = "blockchain" })
}
resource "aws_iam_access_key" "baf_user_access_key" {
  user = aws_iam_user.baf_user.name
  status = "Active"
  lifecycle {
    ignore_changes = [status]
  }
}
#IAM user policy for baf user
resource "aws_iam_user_policy" "baf_user_policy" {
  name = "${local.std_name}-baf-user-policy"
  user = aws_iam_user.baf_user.name
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "sts:AssumeRole",
                "sts:TagSession"
            ],
            "Resource": "arn:aws:iam::${var.aws_account_number}:role/${aws_iam_role.baf_user_role.name}",
            "Effect": "Allow",
            "Condition": {
                "StringEquals": {
                    "sts:ExternalId": "baf-user"
                }
            }
        }
    ]
  })
}
#IAM user role for baf user to allow assume role
resource "aws_iam_role" "baf_user_role" {
  name = "${local.std_name}-baf-automation"
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "sts:AssumeRole",
                "sts:TagSession"
            ],
            "Principal": { "AWS": "arn:aws:iam::${var.aws_account_number}:user/${aws_iam_user.baf_user.name}"},
            "Effect": "Allow",
            "Condition": {
                "StringEquals": {
                    "sts:ExternalId": "baf-user"
                }
            }
        }
    ]
  })
  managed_policy_arns = [aws_iam_policy.baf_user_role_policy.arn]
  tags = merge(local.tags, {name = "${local.std_name}-baf-automation", cluster_type = "blockchain"})
  description = "The iam role that is used for baf automation"
  max_session_duration = 3600
}
#IAM role policy used by baf role
resource "aws_iam_policy" "baf_user_role_policy" {
  name   = "${local.std_name}-BAFPolicy"
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
    { "name" = "${local.std_name}-BAFPolicy",
      "cluster_type" = "blockchain" })
}
#IAM user and relevant credentials to use with github actions for EKS resource provisioning
#IAM user used by pipeline (gitactions/others)
resource "aws_iam_user" "git_actions_user" {
  name = "${local.std_name}-gitactions-admin"
  force_destroy = true
  tags = merge(local.tags, { name = "${local.std_name}-gitactions-admin", cluster_type = "both" })
}
resource "aws_iam_access_key" "git_actions_access_key" {
  user = aws_iam_user.git_actions_user.name
  status = "Active"
  lifecycle {
    ignore_changes = [status]
  }
}
#IAM user policy to assume role by git actions user
resource "aws_iam_user_policy" "git_actions_policy" {
  name = "${local.std_name}-gitactions-admin-policy"
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
#IAM policy for git actions role
resource "aws_iam_policy" "git_actions_admin_policy" {
  name   = "${local.std_name}-GITACTIONSAdminPolicy"
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
            "Action":[
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
                "eks:ListIdentityProviderConfigs",
                "secretsmanager:ListSecrets",
                "cognito-idp:ListUserPools",
                "apigateway:GET"
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
                "iam:GetUser",
                "cognito-idp:ListUserPoolClients",
            ],
            "Resource": [
                "arn:aws:iam::*:user/$${aws:username}",
                "arn:aws:cognito-idp:*:${var.aws_account_number}:userpool/*"
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
        },
        {
            "Sid": "AllowCognito",
            "Effect": "Allow",
            "Action": [
                "cognito-idp:ListUserPoolClients",
                "cognito-idp:ListUserPools"
            ],
            "Resource": [
                "arn:aws:cognito-idp:*:${var.aws_account_number}:userpool/*"
            ]
        },
        {
            "Sid": "AllowPutObjects",
            "Effect": "Allow",
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::${local.std_name}-${var.s3_bucket_name_upload_ui}.${var.aws_env}.${local.public_domain}/*"
        },
        {
            "Action": [
                "secretsmanager:*"
            ],
            "Effect": "Allow",
            "Resource": [
              "arn:aws:secretsmanager:${var.aws_region}:${var.aws_account_number}:secret:*"
            ]
        },
        {
            "Sid": "AllowKMSAccess",
            "Effect": "Allow",
            "Action": [
                "kms:DescribeKey",
                "kms:Decrypt",
                "kms:Encrypt"
            ],
            "Resource": "*"
        }
    ]
})
  tags = merge(local.tags,
    { "name" = "${local.std_name}-GITACTIONSAdminPolicy",
      "cluster_type" = "both" })
}
#IAM role - to perform git actions on EKS resources
resource "aws_iam_role" "git_actions_admin_role" {
  name = "${local.std_name}-gitactions-admin"
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
  tags = merge(local.tags, {name = "${local.std_name}-gitactions-admin", cluster_type = "both"})
  description = "The iam role that is used to manage EKS cluster resources using git actions"
  max_session_duration = 7200
}
#IAM user role based access specific to openIDL application purpose
resource "aws_iam_user" "openidl_apps_user" {
  name = "${local.std_name}-openidl-apps-user"
  force_destroy = true
  tags = merge(local.tags, { Name = "${local.std_name}-openidl-apps-user", Cluster_type = "application" })
}
resource "aws_iam_access_key" "openidl_apps_access_key" {
  user = aws_iam_user.openidl_apps_user.name
  status = "Active"
  lifecycle {
    ignore_changes = [status]
  }
}
#IAM policy of the openidl app user that allows to assume a specific role
resource "aws_iam_user_policy" "openidl_apps_user_policy" {
  name = "${local.std_name}-openidl-apps-user-policy"
  user = aws_iam_user.openidl_apps_user.name
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "sts:AssumeRole",
                "sts:TagSession"
            ],
            "Resource": "arn:aws:iam::${var.aws_account_number}:role/${aws_iam_role.openidl_apps_iam_role.name}",
            "Effect": "Allow",
            "Condition": {
                "StringEquals": {
                    "sts:ExternalId": "apps-user"
                }
            }
        }
    ]
  })
}
#IAM role - apps user can assume to access specific OpenIDL related AWS resources
resource "aws_iam_role" "openidl_apps_iam_role" {
  name = "${local.std_name}-openidl-apps"
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "sts:AssumeRole",
                "sts:TagSession"
            ],
            "Principal": { "AWS": "arn:aws:iam::${var.aws_account_number}:user/${aws_iam_user.openidl_apps_user.name}"},
            "Effect": "Allow",
            "Condition": {
                "StringEquals": {
                    "sts:ExternalId": "apps-user"
                }
            }
        }
    ]
  })
  managed_policy_arns = [aws_iam_policy.openidl_apps_user_role_policy.arn]
  tags = merge(local.tags, {name = "${local.std_name}-openidl-apps", cluster_type = "application"})
  description = "The iam role that is used with OpenIDL apps to access AWS resources"
  max_session_duration = 3600
}
#IAM policy for openidl apps role
resource "aws_iam_policy" "openidl_apps_user_role_policy" {
  name = "${local.std_name}-OPENIDLAppPolicy"
  policy = var.org_name == "aais" ? jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "ListBucket",
            "Effect": "Allow",
            "Action": "s3:ListAllMyBuckets",
            "Resource": "*"
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
        {
            "Sid": "GetAllowPublicBucket",
            "Effect": "Allow",
            "Action": "s3:GetObject",
            "Resource": [
                "arn:aws:s3:::${local.std_name}-${var.s3_bucket_name_logos}",
                "arn:aws:s3:::${local.std_name}-${var.s3_bucket_name_logos}/*"
            ]
        },
        {
          "Sid": "AllowCognito",
          "Effect": "Allow",
          "Action": "cognito-idp:*",
          "Resource": var.create_cognito_userpool ? "${aws_cognito_user_pool.user_pool[0].arn}" : "arn:aws:cognito-idp:${var.aws_region}:${var.aws_account_number}:userpool/null"
        },
        {
          "Sid": "AllowSecretsManager",
          "Effect": "Allow",
          "Action": [
            "secretsmanager:GetSecretValue",
            "secretsmanager:DescribeSecret",
          ],
          "Resource": ["arn:aws:secretsmanager:${var.aws_region}:${var.aws_account_number}:secret:${local.org_name}-${var.aws_env}-kvs-vault-??????"]
        }
    ]
  }) : jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "ListBucket",
            "Effect": "Allow",
            "Action": "s3:ListAllMyBuckets",
            "Resource": "*"
        },
        {
            "Sid": "GetPutAllowHDS",
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:PutObject",
                "s3:AbortMultipartUpload",
                "s3:RestoreObject",
                "s3:DeleteObject",
                "s3:ListMultipartUploadParts"
            ],
            "Resource": [
                "arn:aws:s3:::${local.std_name}-${var.s3_bucket_name_hds_analytics}",
                "arn:aws:s3:::${local.std_name}-${var.s3_bucket_name_hds_analytics}/*",
            ]
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
        {
            "Sid": "GetAllowPublicBucket",
            "Effect": "Allow",
            "Action": "s3:GetObject",
            "Resource": [
                "arn:aws:s3:::${local.std_name}-${var.s3_bucket_name_logos}",
                "arn:aws:s3:::${local.std_name}-${var.s3_bucket_name_logos}/*"
            ]
        },
        {
          "Sid": "AllowCognito",
          "Effect": "Allow",
          "Action": "cognito-idp:*",
          "Resource": var.create_cognito_userpool ? "${aws_cognito_user_pool.user_pool[0].arn}" : "arn:aws:cognito-idp:${var.aws_region}:${var.aws_account_number}:userpool/null"
        },
        {
          "Sid": "AllowSecretsManager",
          "Effect": "Allow",
          "Action": [
            "secretsmanager:GetSecretValue",
            "secretsmanager:DescribeSecret",
          ],
          "Resource": ["arn:aws:secretsmanager:${var.aws_region}:${var.aws_account_number}:secret:${local.org_name}-${var.aws_env}-kvs-vault-??????"]
        }
    ]
  })
  tags = merge(local.tags,
    { "name" = "${local.std_name}-OPENIDLAppPolicy",
      "cluster_type" = "application" })
}

