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

# ---- Test-case inputs (see README.md) ----

variable "node18_runtime" {
  description = "Case 2: Node.js runtime set by a variable default."
  type        = string
  default     = "nodejs18.x"
}

variable "py_runtime" {
  description = "Case 5: Python runtime; value is only in runtimes.auto.tfvars."
  type        = string
}

variable "dotnet_runtime" {
  description = "Case 9: .NET runtime set by a variable default."
  type        = string
  default     = "dotnet8"
}

variable "eks_version" {
  description = "EKS case B: Kubernetes version set by a variable default."
  type        = string
  default     = "1.33"
}

variable "eks_cluster_role_arn" {
  description = "IAM role the EKS control plane uses."
  type        = string
  default     = "arn:aws:iam::539575856470:role/health-test-eks-cluster-role"
}
