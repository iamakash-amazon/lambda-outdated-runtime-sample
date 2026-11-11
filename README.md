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

## Test cases for the AWS Health lifecycle TD

Deployed to test account 539575856470 (us-east-1) by `.github/workflows/deploy.yml` on every push to `main`.
"Expected" is what the TD (rev 2) should do today, based on `aws-health-td-known-issues.md`.

| # | Resource | Runtime / version | How it is set | Fix TD | Expected TD result |
|---|---|---|---|---|---|
| 0 | outdated-lambda-runtime-sample | python3.8 | literal (main.tf) | AWS/python-version-upgrade | Found |
| 1 | health-td-node16-literal | nodejs16.x | literal | AWS/lambda-nodejs-runtime-upgrade | Found |
| 2 | health-td-node18-variable | nodejs18.x | `var.node18_runtime` default | AWS/lambda-nodejs-runtime-upgrade | Found only if the agent resolves the variable (known issue K12) |
| 3 | health-td-node20-lookup | nodejs20.x | `lookup(local.node_runtimes, ...)` | AWS/lambda-nodejs-runtime-upgrade | Missed (known P0: unlisted reference forms) |
| 4 | health-td-py39-env-folder | python3.9 | literal in `env/prod/main.tf` | AWS/python-version-upgrade | Missed (known P0 K5: `env/` folder skipped) |
| 5 | health-td-py310-tfvars | python3.10 | `runtimes.auto.tfvars` only | AWS/python-version-upgrade | Found only if the agent resolves the variable |
| 6 | health-td-ruby32-literal | ruby3.2 | literal | AWS/ruby-upgrade | Found |
| 7 | health-td-ruby33-module | ruby3.3 | literal passed to `modules/lambda_fn` | AWS/ruby-upgrade | Found |
| 8 | health-td-dotnet6-literal | dotnet6 | literal | AWS/dotnet-lambda-upgrade | Found |
| 9 | health-td-dotnet8-variable | dotnet8 | `var.dotnet_runtime` default | AWS/dotnet-lambda-upgrade | Found only if the agent resolves the variable |
| 10 | health-td-java11-literal | java11 | literal | AWS/java-version-upgrade | Found (known: always recommends java25) |
| A | health-td-eks-literal | 1.32 | literal `version = "1.32"` | AWS/eks-kubernetes-version-upgrade | Should be found |
| B | health-td-eks-variable | 1.33 | `var.eks_version` default | AWS/eks-kubernetes-version-upgrade | Missed (known P0: EKS version by reference) |

All of these should also get AWS Health lifecycle events, so "missed" cases show up as Health events the TD cannot link to code.
