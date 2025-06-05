# Dev environment configuration for FusionResume
# Now includes Cognito authentication

# Comment out remote state for now - we'll add it back after fixing S3 backend
# include "root" {
#   path = find_in_parent_folders()
# }

# Generate provider locally
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-west-2"

  default_tags {
    tags = {
      Project     = "FusionResume"
      Environment = "dev"
      ManagedBy   = "Terragrunt"
    }
  }
}
EOF
}

# Use multiple modules
terraform {
  source = "../.."
}

# Environment-specific inputs
inputs = {
  project_name = "fusion-resume"
  environment  = "dev"
  aws_region   = "us-west-2"

  # Cognito OAuth Configuration
  enable_google_oauth = true
  enable_github_oauth = false  # Set to true when you set up GitHub OAuth

  # OAuth URLs for development with custom domain
  callback_urls = [
    "http://localhost:3000/auth/callback",
    "https://fusionresume.com/auth/callback",
    "https://app.fusionresume.com/auth/callback"
  ]

  logout_urls = [
    "http://localhost:3000/",
    "https://fusionresume.com/",
    "https://app.fusionresume.com/"
  ]

  # Custom domain configuration - disabled for now
  use_custom_domain = false
  # custom_domain     = "auth-dev.fusionresume.com"  # Enable later

  # Security settings for dev
  advanced_security_mode = "AUDIT"
  mfa_configuration     = "OFF"  # Disabled for dev environment
  deletion_protection   = "INACTIVE"

  # Token validity (for dev environment)
  token_validity = {
    access_token  = 60   # 60 minutes (1 hour)
    id_token     = 60   # 60 minutes (1 hour)
    refresh_token = 7    # 7 days
  }

  # Password policy for dev
  password_policy = {
    minimum_length                   = 8
    require_lowercase               = true
    require_uppercase               = false  # Relaxed for dev
    require_numbers                 = true
    require_symbols                 = false  # Relaxed for dev
    temporary_password_validity_days = 7
  }
}