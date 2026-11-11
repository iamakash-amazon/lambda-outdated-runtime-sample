# Small reusable Lambda module (used by case 7).

variable "name" { type = string }
variable "runtime" { type = string }
variable "handler" { type = string }
variable "role" { type = string }
variable "filename" { type = string }
variable "hash" { type = string }
variable "tags" { type = map(string) }

resource "aws_lambda_function" "this" {
  function_name    = var.name
  role             = var.role
  handler          = var.handler
  runtime          = var.runtime
  filename         = var.filename
  source_code_hash = var.hash
  tags             = var.tags
}
