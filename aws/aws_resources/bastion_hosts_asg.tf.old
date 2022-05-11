#bastion host setup in the application cluster vpc
#security group for the bastion hosts in application cluster vpc
module "app_bastion_sg" {
  depends_on = [module.aais_app_vpc]
  source                   = "terraform-aws-modules/security-group/aws"
  name                     = "${local.std_name}-app-bastion-sg"
  description              = "Security group associated with app cluster bastion host"
  vpc_id                   = module.aais_app_vpc.vpc_id
  ingress_with_cidr_blocks = var.app_bastion_sg_ingress
  egress_with_cidr_blocks  = var.app_bastion_sg_egress
  tags = merge(
    local.tags,
    {
      "Cluster_type" = "application"
  }, )
}
#ssh keypair for the bastion host in application cluster vpc
module "app_bastion_host_key_pair_external" {
  depends_on = [module.aais_app_vpc]
  source     = "terraform-aws-modules/key-pair/aws"
  key_name   = "${local.std_name}-app-bastion-external"
  public_key = var.app_bastion_ssh_key
  tags = merge(
    local.tags,
    {
      "Name"         = "${local.std_name}-app-bastion-hosts-external"
      "Cluster_type" = "application"
  }, )
}
#network load balancer for the bastion hosts in application cluster vpc
module "app_bastion_nlb" {
  depends_on = [data.aws_subnet_ids.app_vpc_public_subnets, module.aais_app_vpc]
  source     = "terraform-aws-modules/alb/aws"
  version    = "~> 6.0"
  name       = "${local.std_name}-app-bastion-nlb"
  create_lb                        = true
  load_balancer_type               = "network"
  enable_cross_zone_load_balancing = true
  internal                         = var.bastion_host_nlb_external ? false : true
  ip_address_type                  = "ipv4"
  vpc_id                           = module.aais_app_vpc.vpc_id
  subnets                          = module.aais_app_vpc.public_subnets
  http_tcp_listeners = [
    {
      port        = 22
      protocol    = "TCP"
      action_type = "forward"
    }
  ]
  target_groups = [
    {
      name_prefix        = "apbst-"
      backend_protocol   = "TCP"
      backend_port       = 22
      target_type        = "instance"
      preserve_client_ip = true
      tags               = merge(local.tags, { tcp_udp = true }, )
      health_check = {
        enabled             = true
        interval            = 30
        port                = "22"
        protocol            = "TCP"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        #timeout             = 6
      }
    }
  ]
  tags = merge(
    local.tags,
    {
      "Cluster_type" = "application"
  }, )
  lb_tags = merge(
    local.tags,
    {
      "Cluster_type" = "application"
  }, )
  idle_timeout = 180
  target_group_tags = merge(
    local.tags,
    {
      "Name"         = "tg-bst"
      "Cluster_type" = "application"
  }, )
}
#auto scaling group for the bastion hosts in application cluster vpc
module "app_bastion_host_asg" {
  depends_on = [module.aais_app_vpc, module.app_bastion_sg]
  source     = "terraform-aws-modules/autoscaling/aws"
  version    = "~> 4.0"
  name       = "${local.std_name}-app-bastion-asg"
  create_lt  = true
  create_asg = true

  #auto scaling group specifics
  use_lt                    = true
  min_size                  = 1
  max_size                  = 2
  desired_capacity          = 1 #var.aws_env == "prod" ? 2 : 1
  wait_for_capacity_timeout = 0
  default_cooldown          = 600
  health_check_type         = "EC2"
  target_group_arns         = module.app_bastion_nlb.target_group_arns
  health_check_grace_period = 300
  vpc_zone_identifier       = module.aais_app_vpc.public_subnets
  #service_linked_role_arn   = aws_iam_service_linked_role.autoscaling_svc_role.arn
  #launch template specifics
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  #iam_instance_profile_arn = aws_iam_instance_profile.bastion_host_profile.arn
  ebs_optimized                        = false
  enable_monitoring                    = true
  key_name                             = module.app_bastion_host_key_pair_external.key_pair_key_name
  security_groups                      = [module.app_bastion_sg.security_group_id]
  instance_initiated_shutdown_behavior = "stop"
  disable_api_termination              = false
  placement_tenancy                    = "default"
  user_data_base64                     = local.bastion_host_userdata
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
      "Cluster_type" = "application"
  }, )
}
##bastion host setup in the blockchain cluster vpc
#security group for the bastion hosts in blockchain cluster vpc
module "blk_bastion_sg" {
  depends_on = [module.aais_blk_vpc]
  source                   = "terraform-aws-modules/security-group/aws"
  name                     = "${local.std_name}-blk-bastion-sg"
  description              = "Security group associated with blk cluster bastion host"
  vpc_id                   = module.aais_blk_vpc.vpc_id
  ingress_with_cidr_blocks = var.blk_bastion_sg_ingress
  egress_with_cidr_blocks  = var.blk_bastion_sg_egress
  tags = merge(
    local.tags,
    {
      "Cluster_type" = "blockchain"
  }, )
}
#ssh keypair for the bastion hosts in blockchain cluster vpc
module "blk_bastion_host_key_pair_external" {
  depends_on = [module.aais_blk_vpc]
  source     = "terraform-aws-modules/key-pair/aws"
  key_name   = "${local.std_name}-blk-bastion-external"
  public_key = var.blk_bastion_ssh_key
  tags = merge(
    local.tags,
    {
      "Name"         = "${local.std_name}-blk-bastion-external"
      "Cluster_type" = "blockchain"
  }, )
}
#network load balancer for the bastion hosts in blockchain cluster vpc
module "blk_bastion_nlb" {
  depends_on                       = [data.aws_subnet_ids.blk_vpc_public_subnets, module.aais_blk_vpc]
  source                           = "terraform-aws-modules/alb/aws"
  version                          = "~> 6.0"
  name                             = "${local.std_name}-blk-bastion-nlb"
  create_lb                        = true
  load_balancer_type               = "network"
  enable_cross_zone_load_balancing = true
  internal                         = var.bastion_host_nlb_external ? false : true
  ip_address_type                  = "ipv4"
  vpc_id                           = module.aais_blk_vpc.vpc_id
  subnets                          = module.aais_blk_vpc.public_subnets
  http_tcp_listeners = [
    {
      port        = 22
      protocol    = "TCP"
      action_type = "forward"
    }
  ]
  target_groups = [
    {
      name_prefix        = "bkbst-"
      backend_protocol   = "TCP"
      backend_port       = 22
      target_type        = "instance"
      preserve_client_ip = true
      tags               = merge(local.tags, { tcp_udp = true }, )
      health_check = {
        enabled             = true
        interval            = 30
        port                = "22"
        protocol            = "TCP"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        #timeout             = 6
      }
    }
  ]
  tags = merge(
    local.tags,
    {
      "Cluster_type" = "blockchain"
  }, )
  lb_tags = merge(
    local.tags,
    {
      "Cluster_type" = "blockchain"
  }, )
  idle_timeout = 180
  target_group_tags = merge(
    local.tags,
    {
      "Name"         = "tg-bst"
      "Cluster_type" = "blockchain"
  }, )
}
#autoscaling group for the bastion hosts in blockchain cluster vpc
module "blk_bastion_host_asg" {
  depends_on = [module.aais_blk_vpc, module.blk_bastion_sg]
  source     = "terraform-aws-modules/autoscaling/aws"
  version    = "~> 4.0"
  name       = "${local.std_name}-blk-bastion-asg"
  create_lt  = true
  create_asg = true

  #auto scaling group specifics
  use_lt                    = true
  min_size                  = 1
  max_size                  = 2
  desired_capacity          = 1 #var.aws_env == "prod" ? 2 : 1
  wait_for_capacity_timeout = 0
  default_cooldown          = 600
  health_check_type         = "EC2"
  target_group_arns         = module.blk_bastion_nlb.target_group_arns
  health_check_grace_period = 300
  vpc_zone_identifier       = module.aais_blk_vpc.public_subnets
  #service_linked_role_arn   = aws_iam_service_linked_role.autoscaling_svc_role.arn
  #launch template specifics
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  #iam_instance_profile_arn = aws_iam_instance_profile.bastion_host_profile.arn
  ebs_optimized                        = false
  enable_monitoring                    = true
  key_name                             = module.blk_bastion_host_key_pair_external.key_pair_key_name
  security_groups                      = [module.blk_bastion_sg.security_group_id]
  instance_initiated_shutdown_behavior = "stop"
  disable_api_termination              = false
  placement_tenancy                    = "default"
  user_data_base64                     = local.bastion_host_userdata
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
      "Cluster_type" = "blockchain"
  }, )
}
