# Cognito Outputs
output "cognito_user_pool_id" {
  description = "The ID of the Cognito User Pool"
  value       = module.cognito.user_pool_id
}

output "cognito_client_id" {
  description = "The ID of the Cognito User Pool Client"
  value       = module.cognito.client_id
}

output "cognito_domain" {
  description = "The domain prefix for the Cognito hosted UI"
  value       = module.cognito.domain
}

output "cognito_oauth_urls" {
  description = "OAuth endpoint URLs"
  value       = module.cognito.oauth_urls
}

output "cognito_hosted_ui_urls" {
  description = "Cognito Hosted UI URLs"
  value       = module.cognito.hosted_ui_urls
}

# Configuration for React frontend
output "react_auth_config" {
  description = "Complete authentication configuration for React app"
  value       = module.cognito.react_config
  sensitive   = false
}

# Configuration for SpringBoot backend
output "springboot_auth_config" {
  description = "Authentication configuration for SpringBoot app"
  value       = module.cognito.springboot_config
  sensitive   = false
}