# Root module that combines all FusionResume infrastructure components

# Cognito Authentication Module
module "cognito" {
  source = "./modules/cognito"

  project_name = var.project_name
  environment  = var.environment

  # OAuth configuration
  enable_google_oauth = var.enable_google_oauth
  enable_github_oauth = var.enable_github_oauth
  google_client_id    = var.google_client_id
  google_client_secret = var.google_client_secret
  github_client_id    = var.github_client_id
  github_client_secret = var.github_client_secret

  # URLs
  callback_urls = var.callback_urls
  logout_urls   = var.logout_urls

  # Security settings
  advanced_security_mode = var.advanced_security_mode
  mfa_configuration     = var.mfa_configuration
  deletion_protection   = var.deletion_protection
  password_policy       = var.password_policy
  token_validity        = var.token_validity

  # Custom domain settings
  use_custom_domain = var.use_custom_domain
  custom_domain     = var.custom_domain
  certificate_arn   = var.certificate_arn
}

# Job Tracker Module (DynamoDB + S3) - Coming next
# module "job_tracker" {
#   source = "./modules/job-tracker"
#
#   project_name = var.project_name
#   environment  = var.environment
#
#   # User pool info for IAM policies
#   user_pool_id = module.cognito.user_pool_id
#   identity_pool_id = module.cognito.identity_pool_id
# }