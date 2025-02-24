variable "aws_region" {
  description = "AWS Region"
  type        = string
}

variable "s3_bucket_name" {
  description = "S3 Bucket Name"
  type        = string
}

variable "dynamodb_table_name" {
  description = "DynamoDB Table Name"
  type        = string
}

variable "lambda_function_name" {
  description = "Lambda Function Name"
  type        = string
}