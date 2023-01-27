/*Default configuration specifications are listed here. If anything required specific to node_type and
environment, it requires updates here*/
#-------------------------------------------------------------------------------------------------------------------
#Bastion host default configuration
instance_type                 = "t2.micro"
root_block_device_volume_type = "gp2"
root_block_device_volume_size = "40"
#-------------------------------------------------------------------------------------------------------------------
#Cognito default configurations
client_allowed_oauth_flows                       = ["code", "implicit"] # [code,implicit,client_credentials] are options
client_allowed_oauth_flows_user_pool_client      = true
client_allowed_oauth_scopes                      = ["email", "phone", "profile", "openid", "aws.cognito.signin.user.admin"]
client_explicit_auth_flows                       = ["ALLOW_ADMIN_USER_PASSWORD_AUTH", "ALLOW_USER_PASSWORD_AUTH", "ALLOW_REFRESH_TOKEN_AUTH", "ALLOW_USER_SRP_AUTH"]
client_generate_secret                           = false
client_read_attributes                           = ["address", "birthdate", "email", "email_verified", "family_name", "gender", "given_name", "locale", "middle_name", "name", "nickname", "phone_number", "phone_number_verified", "picture", "preferred_username", "profile", "zoneinfo", "updated_at", "website", "custom:role", "custom:stateName", "custom:stateCode", "custom:organizationId"]
client_write_attributes                          = ["address", "birthdate", "email", "family_name", "gender", "given_name", "locale", "middle_name", "name", "nickname", "phone_number", "picture", "preferred_username", "profile", "zoneinfo", "updated_at", "website", "custom:role", "custom:stateName", "custom:stateCode", "custom:organizationId"]
client_supported_idp                             = ["COGNITO"]
client_prevent_user_existence_errors             = "ENABLED"
client_id_token_validity                         = 1 #hour
client_access_token_validity                     = 1 #hour
client_refresh_token_validity                    = 1 #day
userpool_recovery_mechanisms                     = [{ name : "verified_email", priority : "1" }] #Options verified_phone_number|admin_only|verified_email
userpool_username_attributes                     = ["email"]
userpool_auto_verified_attributes                = ["email"]
userpool_mfa_configuration                       = "OPTIONAL"
userpool_software_token_mfa_enabled              = false
password_policy_minimum_length                   = 10
password_policy_require_lowercase                = true
password_policy_require_numbers                  = true
password_policy_require_symbols                  = true
password_policy_require_uppercase                = true
password_policy_temporary_password_validity_days = 10
userpool_advanced_security_mode                  = "AUDIT"
userpool_enable_username_case_sensitivity        = false
userpool_email_verification_subject              = "Your password"
userpool_email_verification_message              = "Your username is {username} and password is {####}."
#-------------------------------------------------------------------------------------------------------------------
#EKS cluster default specifications
app_eks_worker_instance_type         = "t3.xlarge"
blk_eks_worker_instance_type         = "t3.large"
kubeconfig_output_path               = "./kubeconfig_file/"
manage_aws_auth                      = false
cluster_endpoint_private_access      = true
cluster_endpoint_public_access       = true
cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"]
cluster_create_timeout               = "45m"
wait_for_cluster_timeout             = "300"
eks_cluster_logs                     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
#-------------------------------------------------------------------------------------------------------------------
#EKS worker nodes default specifications
wg_asg_min_size             = "1"
wg_asg_max_size             = "2"
wg_asg_desired_capacity     = "1"
wg_ebs_optimized            = true
wg_instance_refresh_enabled = false
eks_wg_public_ip            = false
eks_wg_root_vol_encrypted   = true
eks_wg_root_volume_size     = "40"
eks_wg_root_volume_type     = "gp2"
eks_wg_health_check_type    = "EC2"
blk_cluster_version         = "1.22"
app_cluster_version         = "1.22"
app_cluster_map_roles       = []
app_cluster_map_users       = []
blk_cluster_map_roles       = []
blk_cluster_map_users       = []
#-------------------------------------------------------------------------------------------------------------------
