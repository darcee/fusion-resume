
variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "fusion-resume"
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}