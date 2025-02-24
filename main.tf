terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}


resource "aws_s3_bucket" "url_shortener" {
  bucket = "firstklass-url-shortener-bucket-v1"
}

resource "aws_s3_bucket_public_access_block" "url_shortener" {
    bucket = aws_s3_bucket.url_shortener.id

    block_public_acls = true
    block_public_policy = true
    ignore_public_acls = true
    restrict_public_buckets = true
}

resource "aws_dynamodb_table" "urls" {
  name = "shortened-urls"
  billing_mode = "PAY_PER_REQUEST"

  hash_key = "short_code"

  attribute {
    name = "short_code"
    type = "S"
  }
 
}

resource "aws_iam_role" "lambda_role" {
  name = "url_shortener_lambda_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_lambda_function" "url_shortener" {
    function_name = "urlShortener"
    role = aws_iam_role.lambda_role.arn
    runtime = "python3.9"
    handler = "lambda_function.lambda_handler"

    filename = "lambda.zip"

    source_code_hash = filebase64sha256("lambda.zip")

    environment {
      variables = {
        TABLE_NAME = aws_dynamodb_table.urls.name
      }
    }
}



resource "aws_apigatewayv2_api" "url_shortener_api" {
  name = "url-shortener-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id = aws_apigatewayv2_api.url_shortener_api.id
  integration_type = "AWS_PROXY"
  integration_uri = aws_lambda_function.url_shortener.invoke_arn
}

resource "aws_apigatewayv2_route" "shorten_route" {
  api_id = aws_apigatewayv2_api.url_shortener_api.id
  route_key = "POST /shorten"
  target = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id = aws_apigatewayv2_api.url_shortener_api.id
  name = "$default"
  auto_deploy = true
}

resource "aws_lambda_permission" "apigw_lambda" {
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.url_shortener.function_name
  principal = "apigateway.amazonaws.com"
}

output "api_gateway_url" {
  value = aws_apigatewayv2_api.url_shortener_api.api_endpoint
  description = "Base URL for the API Gateway"
}