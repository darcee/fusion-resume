# S3 bucket for storing resumes, cover letters, and job documents
resource "aws_s3_bucket" "documents" {
  bucket = "${var.project_name}-documents-${var.environment}-${random_id.bucket_suffix.hex}"

  tags = {
    Name = "${786247535145 }-documents-${var.environment}"
  }
}

# Random suffix for globally unique bucket names
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# Bucket versioning
resource "aws_s3_bucket_versioning" "documents" {
  bucket = aws_s3_bucket.documents.id
  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Disabled"
  }
}

# Server-side encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "documents" {
  bucket = aws_s3_bucket.documents.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.kms_key_id != null ? "aws:kms" : "AES256"
      kms_master_key_id = var.kms_key_id
    }
    bucket_key_enabled = var.kms_key_id != null
  }
}

# Block public access
resource "aws_s3_bucket_public_access_block" "documents" {
  bucket = aws_s3_bucket.documents.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Lifecycle configuration
resource "aws_s3_bucket_lifecycle_configuration" "documents" {
  bucket = aws_s3_bucket.documents.id

  rule {
    id     = "document_lifecycle"
    status = "Enabled"

    # Transition to IA after 30 days
    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    # Transition to Glacier after 90 days
    transition {
      days          = 90
      storage_class = "GLACIER"
    }

    # Delete old versions after 365 days
    noncurrent_version_expiration {
      noncurrent_days = 365
    }

    # Delete incomplete multipart uploads after 7 days
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

# CORS configuration for web uploads
resource "aws_s3_bucket_cors_configuration" "documents" {
  bucket = aws_s3_bucket.documents.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "PUT", "POST"]
    allowed_origins = var.allowed_origins
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}

# Notification configuration for document processing
resource "aws_s3_bucket_notification" "documents" {
  bucket = aws_s3_bucket.documents.id

  # Lambda function can be triggered when documents are uploaded
  # This will be useful for document processing, virus scanning, etc.
  # lambda_function {
  #   lambda_function_arn = var.document_processor_lambda_arn
  #   events              = ["s3:ObjectCreated:*"]
  #   filter_prefix       = "uploads/"
  # }
}

# S3 bucket for Terraform state (if not already exists)
resource "aws_s3_bucket" "terraform_state" {
  count  = var.create_terraform_state_bucket ? 1 : 0
  bucket = "${var.project_name}-terraform-state-${random_id.state_bucket_suffix[0].hex}"

  tags = {
    Name = "${var.project_name}-terraform-state"
  }
}

resource "random_id" "state_bucket_suffix" {
  count       = var.create_terraform_state_bucket ? 1 : 0
  byte_length = 4
}

resource "aws_s3_bucket_versioning" "terraform_state" {
  count  = var.create_terraform_state_bucket ? 1 : 0
  bucket = aws_s3_bucket.terraform_state[0].id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  count  = var.create_terraform_state_bucket ? 1 : 0
  bucket = aws_s3_bucket.terraform_state[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "terraform_state" {
  count  = var.create_terraform_state_bucket ? 1 : 0
  bucket = aws_s3_bucket.terraform_state[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}