terraform {
  backend "s3" {
    bucket  = "health-test-tfstate-539575856470"
    key     = "lambda-outdated-runtime-sample/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
