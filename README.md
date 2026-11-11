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

### Harder cases

| # | Resource | Runtime / version | How it is set | Fix TD | Expected TD result |
|---|---|---|---|---|---|
| 11 | health-td-foreach-worker-node16, health-td-foreach-worker-py38 | nodejs16.x, python3.8 | `for_each` map, `each.value.runtime` | nodejs, python | Missed (known P0: unlisted reference forms) |
| 12 | health-td-java8-coalesce | java8.al2 | `coalesce(var.x, "java8.al2")` | AWS/java-version-upgrade | Missed (known P0) |
| 13 | health-td-node-interpolated | nodejs20.x | `"nodejs${var.node_major}.x"` | AWS/lambda-nodejs-runtime-upgrade | Missed |
| 14 | health-td-dotnet6-prefixed-key | dotnet6 | module input named `lambda_runtime` | AWS/dotnet-lambda-upgrade | Missed (known P1: prefixed key) |
| 15 | health-td-provided-al2 | provided.al2 | literal | none (custom runtime) | Missed (known P1 K10: provided.al2 never matched) |
| 16 | health-td-comment-decoy | python3.12 (old version only in a comment) | end-of-line comment | none | Should give NO finding (known P1: mid-line comments become findings) |
| 17 | health-td-cfn-findinmap-py39 | python3.9 | CFN `!FindInMap` | AWS/python-version-upgrade | Missed (known P0) |
| 18 | health-td-cfn-if-node18 | nodejs18.x | CFN `!If` | AWS/lambda-nodejs-runtime-upgrade | Missed (known P0) |
| 19 | health-td-cfn-refparam-node20 | nodejs20.x | CFN `!Ref` Parameter default | AWS/lambda-nodejs-runtime-upgrade | Found only if the agent resolves the parameter |
| 20 | health-td-secret-rotation-py310 | python3.10 | literal in `secret-rotation.tf` | AWS/python-version-upgrade | Missed (known P1: file names with "secret" skipped) |
| 21 | health-td-json-ruby32 | ruby3.2 | Terraform JSON (`legacy.tf.json`) | AWS/ruby-upgrade | Should be found (literal line) |
| C | health-td-eks-foreach-a | 1.31 | `for_each` map, `each.value.version` | AWS/eks-kubernetes-version-upgrade | Missed (known P0) |
| D | health-td-eks-conditional | 1.32 | `local.is_prod ? "1.32" : "1.35"` | AWS/eks-kubernetes-version-upgrade | Missed or wrong version |
| E | health-td-eks-tfvars-json | 1.33 | `eks.auto.tfvars.json` only | AWS/eks-kubernetes-version-upgrade | Missed (known P0: tfvars.json) |
| F | health-td-eks-cfn | 1.33 | CFN `!Ref` Parameter default | AWS/eks-kubernetes-version-upgrade | Missed (known P0: EKS `!Ref`) |
| G | health-td-eks-standard | 1.34, STANDARD policy | `local.eks_versions["standard"]` | AWS/eks-kubernetes-version-upgrade | Missed, or wrongly says "extended support" (known P1) |
