# User Pool Outputs
output "user_pool_id" {
  description = "The ID of the Cognito User Pool"
  value       = aws_cognito_user_pool.main.id
}

output "user_pool_arn" {
  description = "The ARN of the Cognito User Pool"
  value       = aws_cognito_user_pool.main.arn
}

output "user_pool_endpoint" {
  description = "The endpoint of the Cognito User Pool"
  value       = aws_cognito_user_pool.main.endpoint
}

# Client Outputs
output "client_id" {
  description = "The ID of the Cognito User Pool Client"
  value       = aws_cognito_user_pool_client.web_client.id
}

output "client_name" {
  description = "The name of the Cognito User Pool Client"
  value       = aws_cognito_user_pool_client.web_client.name
}

# Domain Outputs
output "domain" {
  description = "The domain for the Cognito hosted UI"
  value       = var.use_custom_domain ? var.custom_domain : aws_cognito_user_pool_domain.main[0].domain
}

output "cloudfront_distribution_arn" {
  description = "The CloudFront distribution ARN for the domain"
  value       = var.use_custom_domain ? aws_cognito_user_pool_domain.custom[0].cloudfront_distribution_arn : aws_cognito_user_pool_domain.main[0].cloudfront_distribution_arn
}

# Custom domain DNS target
output "cloudfront_distribution" {
  description = "CloudFront distribution for DNS setup"
  value       = var.use_custom_domain ? aws_cognito_user_pool_domain.custom[0].cloudfront_distribution : null
}

# Identity Pool Outputs
output "identity_pool_id" {
  description = "The ID of the Cognito Identity Pool"
  value       = aws_cognito_identity_pool.main.id
}

output "identity_pool_arn" {
  description = "The ARN of the Cognito Identity Pool"
  value       = aws_cognito_identity_pool.main.arn
}

# IAM Role Outputs
output "authenticated_role_arn" {
  description = "The ARN of the IAM role for authenticated users"
  value       = aws_iam_role.authenticated.arn
}

output "springboot_app_role_arn" {
  description = "The ARN of the IAM role for SpringBoot application"
  value       = aws_iam_role.springboot_app.arn
}

output "springboot_instance_profile_name" {
  description = "The name of the instance profile for SpringBoot application"
  value       = aws_iam_instance_profile.springboot_app.name
}

# OAuth URLs
output "oauth_urls" {
  description = "OAuth endpoint URLs"
  value = {
    authorize = var.use_custom_domain ? "https://${var.custom_domain}/oauth2/authorize" : "https://${aws_cognito_user_pool_domain.main[0].domain}.auth.${data.aws_region.current.name}.amazoncognito.com/oauth2/authorize"
    token     = var.use_custom_domain ? "https://${var.custom_domain}/oauth2/token" : "https://${aws_cognito_user_pool_domain.main[0].domain}.auth.${data.aws_region.current.name}.amazoncognito.com/oauth2/token"
    userinfo  = var.use_custom_domain ? "https://${var.custom_domain}/oauth2/userInfo" : "https://${aws_cognito_user_pool_domain.main[0].domain}.auth.${data.aws_region.current.name}.amazoncognito.com/oauth2/userInfo"
    logout    = var.use_custom_domain ? "https://${var.custom_domain}/logout" : "https://${aws_cognito_user_pool_domain.main[0].domain}.auth.${data.aws_region.current.name}.amazoncognito.com/logout"
  }
}

# Hosted UI URLs
output "hosted_ui_urls" {
  description = "Cognito Hosted UI URLs"
  value = {
    login  = var.use_custom_domain ? "https://${var.custom_domain}/login?client_id=${aws_cognito_user_pool_client.web_client.id}&response_type=code&scope=email+openid+profile&redirect_uri=${var.callback_urls[0]}" : "https://${aws_cognito_user_pool_domain.main[0].domain}.auth.${data.aws_region.current.name}.amazoncognito.com/login?client_id=${aws_cognito_user_pool_client.web_client.id}&response_type=code&scope=email+openid+profile&redirect_uri=${var.callback_urls[0]}"
    signup = var.use_custom_domain ? "https://${var.custom_domain}/signup?client_id=${aws_cognito_user_pool_client.web_client.id}&response_type=code&scope=email+openid+profile&redirect_uri=${var.callback_urls[0]}" : "https://${aws_cognito_user_pool_domain.main[0].domain}.auth.${data.aws_region.current.name}.amazoncognito.com/signup?client_id=${aws_cognito_user_pool_client.web_client.id}&response_type=code&scope=email+openid+profile&redirect_uri=${var.callback_urls[0]}"
  }
}

# Configuration for React App
output "react_config" {
  description = "Configuration object for React applications"
  value = {
    userPoolId     = aws_cognito_user_pool.main.id
    clientId       = aws_cognito_user_pool_client.web_client.id
    domain         = var.use_custom_domain ? var.custom_domain : aws_cognito_user_pool_domain.main[0].domain
    region         = data.aws_region.current.name
    identityPoolId = aws_cognito_identity_pool.main.id

    # OAuth configuration
    oauth = {
      flows        = var.oauth_flows
      scopes       = var.oauth_scopes
      callbackUrls = var.callback_urls
      logoutUrls   = var.logout_urls
    }

    # Social providers
    socialProviders = {
      google = var.enable_google_oauth
      github = var.enable_github_oauth
    }
  }
  sensitive = false
}

# Configuration for SpringBoot App
output "springboot_config" {
  description = "Configuration for SpringBoot JWT validation"
  value = {
    userPoolId = aws_cognito_user_pool.main.id
    clientId   = aws_cognito_user_pool_client.web_client.id
    region     = data.aws_region.current.name
    jwkSetUri  = "https://cognito-idp.${data.aws_region.current.name}.amazonaws.com/${aws_cognito_user_pool.main.id}/.well-known/jwks.json"
    issuer     = "https://cognito-idp.${data.aws_region.current.name}.amazonaws.com/${aws_cognito_user_pool.main.id}"
  }
  sensitive = false
}