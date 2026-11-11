# Module whose runtime input is named lambda_runtime (used by case 14).

variable "name" { type = string }
variable "lambda_runtime" { type = string }
variable "handler" { type = string }
variable "role" { type = string }
variable "filename" { type = string }
variable "hash" { type = string }
variable "tags" { type = map(string) }

resource "aws_lambda_function" "this" {
  function_name    = var.name
  role             = var.role
  handler          = var.handler
  runtime          = var.lambda_runtime
  filename         = var.filename
  source_code_hash = var.hash
  tags             = var.tags
}
