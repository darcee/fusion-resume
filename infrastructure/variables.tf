variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

# Cognito OAuth Configuration
variable "enable_google_oauth" {
  description = "Enable Google OAuth integration"
  type        = bool
  default     = false
}

variable "enable_github_oauth" {
  description = "Enable GitHub OAuth integration"
  type        = bool
  default     = false
}

variable "google_client_id" {
  description = "Google OAuth client ID"
  type        = string
  default     = ""
  sensitive   = true
}

variable "google_client_secret" {
  description = "Google OAuth client secret"
  type        = string
  default     = ""
  sensitive   = true
}

variable "github_client_id" {
  description = "GitHub OAuth client ID"
  type        = string
  default     = ""
  sensitive   = true
}

variable "github_client_secret" {
  description = "GitHub OAuth client secret"
  type        = string
  default     = ""
  sensitive   = true
}

variable "callback_urls" {
  description = "List of allowed callback URLs"
  type        = list(string)
}

variable "logout_urls" {
  description = "List of allowed logout URLs"
  type        = list(string)
}

variable "advanced_security_mode" {
  description = "Advanced security mode (OFF, AUDIT, ENFORCED)"
  type        = string
  default     = "AUDIT"
}

variable "mfa_configuration" {
  description = "MFA configuration (OFF, ON, OPTIONAL)"
  type        = string
  default     = "OPTIONAL"
}

variable "deletion_protection" {
  description = "Enable deletion protection for user pool"
  type        = string
  default     = "INACTIVE"
}

variable "password_policy" {
  description = "Password policy configuration"
  type = object({
    minimum_length                   = number
    require_lowercase               = bool
    require_uppercase               = bool
    require_numbers                 = bool
    require_symbols                 = bool
    temporary_password_validity_days = number
  })
  default = {
    minimum_length                   = 8
    require_lowercase               = true
    require_uppercase               = true
    require_numbers                 = true
    require_symbols                 = false
    temporary_password_validity_days = 7
  }
}

variable "token_validity" {
  description = "Token validity configuration"
  type = object({
    access_token  = number
    id_token     = number
    refresh_token = number
  })
  default = {
    access_token  = 60
    id_token     = 60
    refresh_token = 30
  }
}

# Custom domain variables
variable "use_custom_domain" {
  description = "Use custom domain for Cognito hosted UI"
  type        = bool
  default     = false
}

variable "custom_domain" {
  description = "Custom domain for Cognito (e.g., auth.fusionresume.com)"
  type        = string
  default     = ""
}

variable "certificate_arn" {
  description = "ACM certificate ARN for custom domain (must be in us-east-1)"
  type        = string
  default     = ""
}