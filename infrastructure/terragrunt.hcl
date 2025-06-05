# Root Terragrunt configuration for FusionResume
remote_state {
  backend = "s3"
  config = {
    bucket         = "fusionresume-tf-state-${get_env("AWS_ACCOUNT_ID", "123456789012")}"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "us-west-2"
    encrypt        = true
    dynamodb_table = "fusion-resume-terraform-locks"
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

# Generate provider configuration
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
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
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "FusionResume"
      Environment = var.environment
      ManagedBy   = "Terragrunt"
      Owner       = var.owner
    }
  }
}
EOF
}

# Common variables for all environments
inputs = {
  project_name = "fusion-resume"
  owner        = "fusionresume-team"
}