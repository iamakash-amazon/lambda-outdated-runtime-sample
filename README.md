# Outdated AWS Lambda runtime sample

This repository contains a minimal Python Lambda handler and Terraform configuration that intentionally selects the outdated `python3.8` runtime for scanner/compliance demonstrations. Python 3.8 is past its AWS Lambda deprecation date. AWS may restrict creating or updating functions with deprecated runtimes. Do not use this sample for production.

## Requirements

- Terraform 1.5 or later
- AWS credentials with permissions to create Lambda functions
- An existing Lambda execution role

Set `lambda_role_arn` in `terraform.tfvars` (do not commit credentials):

```hcl
lambda_role_arn = "arn:aws:iam::123456789012:role/lambda-execution-role"
```

The configuration packages `handler.py` and deliberately sets `runtime = "python3.8"` in `main.tf` so infrastructure scanners can detect the outdated runtime.
