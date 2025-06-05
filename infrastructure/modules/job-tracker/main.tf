resource "aws_dynamodb_table" "test_table" {
  name           = "${var.project_name}-test-table-${var.environment}"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Name        = "${var.project_name}-test-table-${var.environment}"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Output the table name so we can see it was created
output "test_table_name" {
  description = "Name of the test DynamoDB table"
  value       = aws_dynamodb_table.test_table.name
}