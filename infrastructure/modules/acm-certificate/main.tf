# ACM Certificate for Cognito custom domain
# Must be in us-east-1 for CloudFront

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
      configuration_aliases = [aws.us_east_1]
    }
  }
}

# Certificate for auth subdomain
resource "aws_acm_certificate" "auth_cert" {
  provider = aws.us_east_1

  domain_name       = var.auth_domain
  validation_method = "DNS"

  subject_alternative_names = [
    "*.${var.root_domain}",  # Wildcard for all subdomains
    var.root_domain          # Root domain
  ]

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name        = "${var.project_name}-auth-cert-${var.environment}"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Certificate validation
resource "aws_acm_certificate_validation" "auth_cert" {
  provider = aws.us_east_1

  certificate_arn         = aws_acm_certificate.auth_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

# Route53 validation records
resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.auth_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = var.route53_zone_id
}