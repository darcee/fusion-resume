output "job_opportunities_table_name" {
  description = "Name of the job opportunities DynamoDB table"
  value       = aws_dynamodb_table.job_opportunities.name
}

output "job_opportunities_table_arn" {
  description = "ARN of the job opportunities DynamoDB table"
  value       = aws_dynamodb_table.job_opportunities.arn
}

output "job_applications_table_name" {
  description = "Name of the job applications DynamoDB table"
  value       = aws_dynamodb_table.job_applications.name
}

output "job_applications_table_arn" {
  description = "ARN of the job applications DynamoDB table"
  value       = aws_dynamodb_table.job_applications.arn
}

output "job_opportunities_gsi1_name" {
  description = "Name of the GSI1 index for job opportunities table"
  value       = "GSI1"
}

output "job_opportunities_gsi2_name" {
  description = "Name of the GSI2 index for job opportunities table"
  value       = "GSI2"
}