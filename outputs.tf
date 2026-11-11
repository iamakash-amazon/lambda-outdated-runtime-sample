output "function_name" {
  description = "Name of the sample Lambda function."
  value       = aws_lambda_function.sample.function_name
}

output "function_arn" {
  description = "ARN of the sample Lambda function."
  value       = aws_lambda_function.sample.arn
}
