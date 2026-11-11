variable "aws_region" {
  description = "AWS region for the sample Lambda function."
  type        = string
  default     = "us-east-1"
}

variable "function_name" {
  description = "Name for the sample Lambda function."
  type        = string
  default     = "outdated-lambda-runtime-sample"
}

variable "lambda_role_arn" {
  description = "ARN of an existing IAM execution role for Lambda."
  type        = string
}
