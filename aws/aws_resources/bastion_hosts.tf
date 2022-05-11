#Code specifics to provision bastion host in the network
#Reserve EIP for the bastion host
resource "aws_eip" "bastion_host_eip" {
  count = var.create_bastion_host ? 1 : 0
  vpc = true
  tags = merge(local.tags,{ "name" = "${local.std_name}-bastion-eip"})
}
#Instance Profile for the bastion host
resource "aws_iam_instance_profile" "bastion_host_instance_profile" {
  count = var.create_bastion_host ? 1 : 0
  name = "${local.std_name}-bastion-instance-profile"
  role = aws_iam_role.bastion_host_iam_role[0].name
  tags = merge(local.tags, { "name" = "${local.std_name}-bastion-instance-profile"})
}
#IAM role for the bastion host to assume
resource "aws_iam_role" "bastion_host_iam_role" {
  count = var.create_bastion_host ? 1 : 0
  name = "${local.std_name}-bastion-host"
  path ="/"
  tags = merge(local.tags, { "name" ="${local.std_name}-bastion-host"})
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "sts:AssumeRole",
                "sts:TagSession"
            ],
            "Principal": { "Service": "ec2.amazonaws.com"},
            "Effect": "Allow",
        }
    ]
  })
  inline_policy {
    name = "${local.std_name}-bastion-policy"
    policy = jsonencode({
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Action": [
            "ec2:DescribeAddresses",
            "ec2:AllocateAddress",
            "ec2:DescribeInstances",
            "ec2:AssociateAddress"
          ],
          "Resource": "*"
        }
      ]
    })
  }
}
#Security group for the bastion host
module "bastion_sg" {
  count = var.create_bastion_host ? 1 : 0
  source                   = "terraform-aws-modules/security-group/aws"
  name                     = "${local.std_name}-bastion-sg"
  description              = "Security group associated with bastion host"
  vpc_id                   = var.create_vpc ? module.vpc[0].vpc_id : data.aws_vpc.vpc[0].id
  ingress_with_cidr_blocks = distinct(concat(var.bastion_sg_ingress, local.def_bastion_sg_ingress))
  egress_with_cidr_blocks  = distinct(concat(var.bastion_sg_egress, local.def_bastion_sg_egress))
  tags = merge(
    local.tags,
    {
      "cluster_type" = "both"
  }, )
}
#SSH key pair for the bastion host access
module "bastion_host_key_pair_external" {
  count = var.create_bastion_host ? 1 : 0
  source     = "terraform-aws-modules/key-pair/aws"
  key_name   = "${local.std_name}-bastion-external"
  public_key = var.bastion_ssh_key
  tags = merge(
    local.tags,
    {
      "name"         = "${local.std_name}-bastion-hosts-external"
      "cluster_type" = "both"
  }, )
}
#Autoscaling group used for the bastion host
module "bastion_host_asg" {
  count = var.create_bastion_host ? 1 : 0
  source     = "terraform-aws-modules/autoscaling/aws"
  version    = "~> 4.0"
  name       = "${local.std_name}-bastion-asg"
  create_lt  = true
  create_asg = true

  #auto scaling group specifics
  use_lt                    = true
  min_size                  = 1
  max_size                  = 1
  desired_capacity          = 1
  wait_for_capacity_timeout = 0
  default_cooldown          = 600
  health_check_type         = "EC2"
  #target_group_arns         = module.bastion_nlb[0].target_group_arns
  health_check_grace_period = 300
  vpc_zone_identifier       = var.create_vpc ? module.vpc[0].public_subnets : data.aws_subnet_ids.vpc_public_subnets.ids
  #service_linked_role_arn   = aws_iam_service_linked_role.autoscaling_svc_role.arn
  #launch template specifics
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  iam_instance_profile_arn = aws_iam_instance_profile.bastion_host_instance_profile[0].arn
  ebs_optimized                        = false
  enable_monitoring                    = false
  key_name                             = module.bastion_host_key_pair_external[0].key_pair_key_name
  security_groups                      = [module.bastion_sg[0].security_group_id]
  instance_initiated_shutdown_behavior = "stop"
  disable_api_termination              = false
  placement_tenancy                    = "default"
  user_data_base64                     = base64encode(local.bastion_userdata)
  block_device_mappings = [
    {
      device_name = "/dev/xvda"
      no_device   = 0
      ebs = {
        delete_on_termination = true
        encrypted             = true
        volume_size           = var.root_block_device_volume_size
        volume_type           = var.root_block_device_volume_type
      }
  }]
  metadata_options = {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 5
  }
  tags_as_map = merge(
    local.tags,
    {
      "cluster_type" = "both"
  }, )
}
