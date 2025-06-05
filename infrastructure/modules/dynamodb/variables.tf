variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
}

variable "billing_mode" {
  description = "Billing mode for DynamoDB table (PROVISIONED or PAY_PER_REQUEST)"
  type        = string
  default     = "PAY_PER_REQUEST"
}

variable "read_capacity" {
  description = "Read capacity units for DynamoDB table (only used with PROVISIONED billing)"
  type        = number
  default     = 5
}

variable "write_capacity" {
  description = "Write capacity units for DynamoDB table (only used with PROVISIONED billing)"
  type        = number
  default     = 5
}

variable "gsi_read_capacity" {
  description = "Read capacity units for GSI (only used with PROVISIONED billing)"
  type        = number
  default     = 5
}

variable "gsi_write_capacity" {
  description = "Write capacity units for GSI (only used with PROVISIONED billing)"
  type        = number
  default     = 5
}

variable "enable_point_in_time_recovery" {
  description = "Enable point-in-time recovery for DynamoDB table"
  type        = bool
  default     = true
}

variable "enable_ttl" {
  description = "Enable TTL for automatic cleanup"
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "KMS key ID for DynamoDB encryption (default uses AWS managed key)"
  type        = string
  default     = null
}