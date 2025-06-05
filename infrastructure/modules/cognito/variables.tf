variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

# Password Policy Configuration
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

# Security Configuration
variable "advanced_security_mode" {
  description = "Advanced security mode (OFF, AUDIT, ENFORCED)"
  type        = string
  default     = "AUDIT"

  validation {
    condition     = contains(["OFF", "AUDIT", "ENFORCED"], var.advanced_security_mode)
    error_message = "Advanced security mode must be OFF, AUDIT, or ENFORCED."
  }
}

variable "mfa_configuration" {
  description = "MFA configuration (OFF, ON, OPTIONAL)"
  type        = string
  default     = "OPTIONAL"

  validation {
    condition     = contains(["OFF", "ON", "OPTIONAL"], var.mfa_configuration)
    error_message = "MFA configuration must be OFF, ON, or OPTIONAL."
  }
}

variable "device_configuration" {
  description = "Device configuration settings"
  type = object({
    challenge_required_on_new_device      = bool
    device_only_remembered_on_user_prompt = bool
  })
  default = {
    challenge_required_on_new_device      = false
    device_only_remembered_on_user_prompt = true
  }
}

variable "deletion_protection" {
  description = "Enable deletion protection for user pool"
  type        = string
  default     = "INACTIVE"

  validation {
    condition     = contains(["ACTIVE", "INACTIVE"], var.deletion_protection)
    error_message = "Deletion protection must be ACTIVE or INACTIVE."
  }
}

# OAuth Configuration
variable "oauth_flows" {
  description = "Allowed OAuth flows"
  type        = list(string)
  default     = ["code", "implicit"]

  validation {
    condition = alltrue([
      for flow in var.oauth_flows : contains(["code", "implicit", "client_credentials"], flow)
    ])
    error_message = "OAuth flows must be one of: code, implicit, client_credentials."
  }
}

variable "oauth_scopes" {
  description = "Allowed OAuth scopes"
  type        = list(string)
  default = [
    "email",
    "openid",
    "profile",
    "aws.cognito.signin.user.admin"
  ]
}

variable "callback_urls" {
  description = "List of allowed callback URLs"
  type        = list(string)
}

variable "logout_urls" {
  description = "List of allowed logout URLs"
  type        = list(string)
}

# Token Validity Configuration
variable "token_validity" {
  description = "Token validity configuration in minutes/days"
  type = object({
    access_token  = number  # minutes (5-1440)
    id_token     = number  # minutes (5-1440)
    refresh_token = number  # days (1-3650)
  })
  default = {
    access_token  = 60   # 1 hour
    id_token     = 60   # 1 hour
    refresh_token = 30   # 30 days
  }

  validation {
    condition = var.token_validity.access_token >= 5 && var.token_validity.access_token <= 1440
    error_message = "Access token validity must be between 5 and 1440 minutes (5 minutes to 24 hours)."
  }

  validation {
    condition = var.token_validity.id_token >= 5 && var.token_validity.id_token <= 1440
    error_message = "ID token validity must be between 5 and 1440 minutes (5 minutes to 24 hours)."
  }

  validation {
    condition = var.token_validity.refresh_token >= 1 && var.token_validity.refresh_token <= 3650
    error_message = "Refresh token validity must be between 1 and 3650 days."
  }
}

# Google OAuth Configuration
variable "enable_google_oauth" {
  description = "Enable Google OAuth integration"
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

# GitHub OAuth Configuration
variable "enable_github_oauth" {
  description = "Enable GitHub OAuth integration"
  type        = bool
  default     = false
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

# Custom Domain Configuration
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