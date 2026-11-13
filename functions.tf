# 10 test Lambdas for the AWS Health lifecycle TD.
# Each one sets its runtime a different way. See README.md for what the TD should find.

locals {
  tags = { purpose = "aws-health-e2e" }

  # Used by case 3 (lookup)
  node_runtimes = { api = "nodejs24.x" }
}

data "archive_file" "node" {
  type        = "zip"
  source_file = "${path.module}/src/node/index.js"
  output_path = "${path.module}/.zips/node.zip"
}

data "archive_file" "ruby" {
  type        = "zip"
  source_file = "${path.module}/src/ruby/handler.rb"
  output_path = "${path.module}/.zips/ruby.zip"
}

# Java and .NET only need a valid zip to exist; they are never invoked.
data "archive_file" "placeholder" {
  type        = "zip"
  source_file = "${path.module}/src/placeholder/README.txt"
  output_path = "${path.module}/.zips/placeholder.zip"
}

# ---------- Node.js -> AWS/lambda-nodejs-runtime-upgrade ----------

# Case 1: plain literal
resource "aws_lambda_function" "node16_literal" {
  function_name    = "health-td-node16-literal"
  role             = var.lambda_role_arn
  handler          = "index.handler"
  runtime          = "nodejs24.x"
  filename         = data.archive_file.node.output_path
  source_code_hash = data.archive_file.node.output_base64sha256
  tags             = local.tags
}

# Case 2: variable with a default (variables.tf)
resource "aws_lambda_function" "node18_variable" {
  function_name    = "health-td-node18-variable"
  role             = var.lambda_role_arn
  handler          = "index.handler"
  runtime          = var.node18_runtime
  filename         = data.archive_file.node.output_path
  source_code_hash = data.archive_file.node.output_base64sha256
  tags             = local.tags
}

# Case 3: lookup() on a locals map
resource "aws_lambda_function" "node20_lookup" {
  function_name    = "health-td-node20-lookup"
  role             = var.lambda_role_arn
  handler          = "index.handler"
  runtime          = lookup(local.node_runtimes, "api", "nodejs24.x")
  filename         = data.archive_file.node.output_path
  source_code_hash = data.archive_file.node.output_base64sha256
  tags             = local.tags
}

# ---------- Python -> AWS/python-version-upgrade ----------

# Case 4: literal inside a folder named env/ (env/prod/main.tf)
module "env_prod" {
  source   = "./env/prod"
  role     = var.lambda_role_arn
  filename = data.archive_file.function.output_path
  hash     = data.archive_file.function.output_base64sha256
  tags     = local.tags
}

# Case 5: value only in a .tfvars file (runtimes.auto.tfvars)
resource "aws_lambda_function" "py310_tfvars" {
  function_name    = "health-td-py310-tfvars"
  role             = var.lambda_role_arn
  handler          = "handler.handler"
  runtime          = var.py_runtime
  filename         = data.archive_file.function.output_path
  source_code_hash = data.archive_file.function.output_base64sha256
  tags             = local.tags
}

# ---------- Ruby -> AWS/ruby-upgrade ----------

# Case 6: plain literal
resource "aws_lambda_function" "ruby32_literal" {
  function_name    = "health-td-ruby32-literal"
  role             = var.lambda_role_arn
  handler          = "handler.handler"
  runtime          = "ruby3.2"
  filename         = data.archive_file.ruby.output_path
  source_code_hash = data.archive_file.ruby.output_base64sha256
  tags             = local.tags
}

# Case 7: literal passed into a local module
module "ruby33_module" {
  source   = "./modules/lambda_fn"
  name     = "health-td-ruby33-module"
  runtime  = "ruby3.3"
  handler  = "handler.handler"
  role     = var.lambda_role_arn
  filename = data.archive_file.ruby.output_path
  hash     = data.archive_file.ruby.output_base64sha256
  tags     = local.tags
}

# ---------- .NET -> AWS/dotnet-lambda-upgrade ----------

# Case 8: plain literal
resource "aws_lambda_function" "dotnet6_literal" {
  function_name    = "health-td-dotnet6-literal"
  role             = var.lambda_role_arn
  handler          = "App::App.Function::Handler"
  runtime          = "dotnet6"
  filename         = data.archive_file.placeholder.output_path
  source_code_hash = data.archive_file.placeholder.output_base64sha256
  tags             = local.tags
}

# Case 9: variable with a default (variables.tf)
resource "aws_lambda_function" "dotnet8_variable" {
  function_name    = "health-td-dotnet8-variable"
  role             = var.lambda_role_arn
  handler          = "App::App.Function::Handler"
  runtime          = var.dotnet_runtime
  filename         = data.archive_file.placeholder.output_path
  source_code_hash = data.archive_file.placeholder.output_base64sha256
  tags             = local.tags
}

# ---------- Java -> AWS/java-version-upgrade ----------

# Case 10: plain literal
resource "aws_lambda_function" "java11_literal" {
  function_name    = "health-td-java11-literal"
  role             = var.lambda_role_arn
  handler          = "example.Handler::handleRequest"
  runtime          = "java11"
  filename         = data.archive_file.placeholder.output_path
  source_code_hash = data.archive_file.placeholder.output_base64sha256
  tags             = local.tags
}
