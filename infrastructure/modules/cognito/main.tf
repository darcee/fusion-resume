# AWS Cognito User Pool for FusionResume authentication
resource "aws_cognito_user_pool" "main" {
  name = "${var.project_name}-users-${var.environment}"

  # Email configuration
  email_configuration {
    email_sending_account = "COGNITO_DEFAULT"
  }

  # Username attributes
  username_attributes = ["email"]

  # Password policy
  password_policy {
    minimum_length                   = var.password_policy.minimum_length
    require_lowercase               = var.password_policy.require_lowercase
    require_uppercase               = var.password_policy.require_uppercase
    require_numbers                 = var.password_policy.require_numbers
    require_symbols                 = var.password_policy.require_symbols
    temporary_password_validity_days = var.password_policy.temporary_password_validity_days
  }

  # User attributes schema
  schema {
    attribute_data_type      = "String"
    name                    = "email"
    required                = true
    mutable                 = true
    developer_only_attribute = false

    string_attribute_constraints {
      min_length = 1
      max_length = 256
    }
  }

  schema {
    attribute_data_type      = "String"
    name                    = "name"
    required                = true
    mutable                 = true
    developer_only_attribute = false

    string_attribute_constraints {
      min_length = 1
      max_length = 256
    }
  }

  schema {
    attribute_data_type      = "String"
    name                    = "given_name"
    required                = false
    mutable                 = true
    developer_only_attribute = false

    string_attribute_constraints {
      min_length = 1
      max_length = 256
    }
  }

  schema {
    attribute_data_type      = "String"
    name                    = "family_name"
    required                = false
    mutable                 = true
    developer_only_attribute = false

    string_attribute_constraints {
      min_length = 1
      max_length = 256
    }
  }

  # Auto verification
  auto_verified_attributes = ["email"]

  # Email verification
  email_verification_subject = "${var.project_name} - Verify your email"
  email_verification_message = "Your verification code is {####}"

  # Account recovery
  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }

  # User pool add-ons
  user_pool_add_ons {
    advanced_security_mode = var.advanced_security_mode
  }

  # MFA configuration
  mfa_configuration = var.mfa_configuration

  # Device configuration
  device_configuration {
    challenge_required_on_new_device      = var.device_configuration.challenge_required_on_new_device
    device_only_remembered_on_user_prompt = var.device_configuration.device_only_remembered_on_user_prompt
  }

  # Deletion protection
  deletion_protection = var.deletion_protection

  tags = {
    Name        = "${var.project_name}-user-pool-${var.environment}"
    Environment = var.environment
    Project     = var.project_name
  }
}

# User Pool Client for web application
resource "aws_cognito_user_pool_client" "web_client" {
  name         = "${var.project_name}-web-client-${var.environment}"
  user_pool_id = aws_cognito_user_pool.main.id

  # Client settings
  generate_secret = false  # Public client for SPAs

  # OAuth configuration
  allowed_oauth_flows = var.oauth_flows
  allowed_oauth_flows_user_pool_client = true

  allowed_oauth_scopes = var.oauth_scopes

  # Callback URLs
  callback_urls = var.callback_urls
  logout_urls   = var.logout_urls

  # Supported identity providers
  supported_identity_providers = concat(
    ["COGNITO"],
      var.enable_google_oauth ? ["Google"] : [],
      var.enable_github_oauth ? ["GitHub"] : []
  )

  # Token validity
  access_token_validity                = var.token_validity.access_token
  id_token_validity                   = var.token_validity.id_token
  refresh_token_validity              = var.token_validity.refresh_token

  token_validity_units {
    access_token  = "minutes"
    id_token      = "minutes"
    refresh_token = "days"
  }

  # Auth flows
  explicit_auth_flows = [
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_PASSWORD_AUTH"
  ]

  # Security
  prevent_user_existence_errors = "ENABLED"

  # Read and write attributes
  read_attributes = [
    "email",
    "email_verified",
    "name",
    "given_name",
    "family_name"
  ]

  write_attributes = [
    "email",
    "name",
    "given_name",
    "family_name"
  ]

  depends_on = [
    aws_cognito_identity_provider.google,
    aws_cognito_identity_provider.github
  ]
}

# Google Identity Provider
resource "aws_cognito_identity_provider" "google" {
  count = var.enable_google_oauth ? 1 : 0

  user_pool_id  = aws_cognito_user_pool.main.id
  provider_name = "Google"
  provider_type = "Google"

  provider_details = {
    authorize_scopes = "email openid profile"
    client_id        = var.google_client_id
    client_secret    = var.google_client_secret
  }

  attribute_mapping = {
    email      = "email"
    username   = "sub"
    name       = "name"
    given_name = "given_name"
    family_name = "family_name"
  }

  lifecycle {
    ignore_changes = [
      provider_details["client_secret"]
    ]
  }
}

# GitHub Identity Provider (using OIDC)
resource "aws_cognito_identity_provider" "github" {
  count = var.enable_github_oauth ? 1 : 0

  user_pool_id  = aws_cognito_user_pool.main.id
  provider_name = "GitHub"
  provider_type = "OIDC"

  provider_details = {
    authorize_scopes              = "user:email"
    client_id                    = var.github_client_id
    client_secret                = var.github_client_secret
    oidc_issuer                  = "https://github.com"
    authorize_url                = "https://github.com/login/oauth/authorize"
    token_url                    = "https://github.com/login/oauth/access_token"
    attributes_url               = "https://api.github.com/user"
    jwks_uri                     = "https://github.com/.well-known/jwks"
  }

  attribute_mapping = {
    email    = "email"
    username = "login"
    name     = "name"
  }

  lifecycle {
    ignore_changes = [
      provider_details["client_secret"]
    ]
  }
}

# User Pool Domain with custom domain support
resource "aws_cognito_user_pool_domain" "main" {
  count = var.use_custom_domain ? 0 : 1

  domain       = "${var.project_name}-auth-${var.environment}"
  user_pool_id = aws_cognito_user_pool.main.id
}

# Custom domain configuration
resource "aws_cognito_user_pool_domain" "custom" {
  count = var.use_custom_domain ? 1 : 0

  domain          = var.custom_domain
  certificate_arn = var.certificate_arn
  user_pool_id    = aws_cognito_user_pool.main.id
}

# Identity Pool for AWS resource access
resource "aws_cognito_identity_pool" "main" {
  identity_pool_name               = "${var.project_name}-identity-${var.environment}"
  allow_unauthenticated_identities = false

  cognito_identity_providers {
    client_id               = aws_cognito_user_pool_client.web_client.id
    provider_name           = aws_cognito_user_pool.main.endpoint
    server_side_token_check = false
  }

  tags = {
    Name        = "${var.project_name}-identity-pool-${var.environment}"
    Environment = var.environment
    Project     = var.project_name
  }
}

# IAM Role for authenticated users
resource "aws_iam_role" "authenticated" {
  name = "${var.project_name}-cognito-authenticated-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "cognito-identity.amazonaws.com"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "cognito-identity.amazonaws.com:aud" = aws_cognito_identity_pool.main.id
          }
          "ForAnyValue:StringLike" = {
            "cognito-identity.amazonaws.com:amr" = "authenticated"
          }
        }
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-cognito-authenticated-${var.environment}"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Policy for DynamoDB access (user-scoped)
resource "aws_iam_role_policy" "authenticated_dynamodb" {
  name = "${var.project_name}-authenticated-dynamodb-${var.environment}"
  role = aws_iam_role.authenticated.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Query",
          "dynamodb:BatchGetItem"
        ]
        Resource = [
          "arn:aws:dynamodb:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:table/${var.project_name}-jobs-${var.environment}",
          "arn:aws:dynamodb:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:table/${var.project_name}-jobs-${var.environment}/index/*"
        ]
        Condition = {
          "ForAllValues:StringEquals" = {
            "dynamodb:LeadingKeys" = ["USER#$${cognito-identity.amazonaws.com:sub}"]
          }
        }
      }
    ]
  })
}

# Policy for S3 access (user-scoped)
resource "aws_iam_role_policy" "authenticated_s3" {
  name = "${var.project_name}-authenticated-s3-${var.environment}"
  role = aws_iam_role.authenticated.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = [
          "arn:aws:s3:::${var.project_name}-documents-${var.environment}-*/users/$${cognito-identity.amazonaws.com:sub}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${var.project_name}-documents-${var.environment}-*"
        ]
        Condition = {
          StringLike = {
            "s3:prefix" = ["users/$${cognito-identity.amazonaws.com:sub}/*"]
          }
        }
      }
    ]
  })
}

# Data sources for policy construction
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# IAM Role for SpringBoot application
resource "aws_iam_role" "springboot_app" {
  name = "${var.project_name}-springboot-app-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = [
            "ec2.amazonaws.com",    # For EC2 instances
            "ecs-tasks.amazonaws.com"  # For ECS containers
          ]
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-springboot-app-${var.environment}"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Policy for SpringBoot app to access DynamoDB
resource "aws_iam_role_policy" "springboot_dynamodb" {
  name = "${var.project_name}-springboot-dynamodb-${var.environment}"
  role = aws_iam_role.springboot_app.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Query",
          "dynamodb:Scan",
          "dynamodb:BatchGetItem",
          "dynamodb:BatchWriteItem"
        ]
        Resource = [
          "arn:aws:dynamodb:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:table/${var.project_name}-jobs-${var.environment}",
          "arn:aws:dynamodb:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:table/${var.project_name}-jobs-${var.environment}/index/*"
        ]
      }
    ]
  })
}

# Policy for SpringBoot app to access S3
resource "aws_iam_role_policy" "springboot_s3" {
  name = "${var.project_name}-springboot-s3-${var.environment}"
  role = aws_iam_role.springboot_app.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${var.project_name}-documents-${var.environment}-*",
          "arn:aws:s3:::${var.project_name}-documents-${var.environment}-*/*"
        ]
      }
    ]
  })
}

# Instance profile for EC2
resource "aws_iam_instance_profile" "springboot_app" {
  name = "${var.project_name}-springboot-app-${var.environment}"
  role = aws_iam_role.springboot_app.name

  tags = {
    Name        = "${var.project_name}-springboot-app-${var.environment}"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Attach role to identity pool
resource "aws_cognito_identity_pool_roles_attachment" "main" {
  identity_pool_id = aws_cognito_identity_pool.main.id

  roles = {
    "authenticated" = aws_iam_role.authenticated.arn
  }
}