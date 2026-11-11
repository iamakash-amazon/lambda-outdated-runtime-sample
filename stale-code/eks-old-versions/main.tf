# Stale-code EKS cases (H-J). NOT deployed: Terraform only loads the repo root,
# and this folder is not called as a module. AWS no longer allows creating
# these versions; real clusters that were on them were auto-upgraded.
# This mimics a customer whose code still says the old version.
# Expected: the TD reports each one. Known issue K4: 1.30 and older give
# PARTIAL with 0 findings because they are missing from the date table.

# EKS case H: 1.30 (end of extended support 2026-07-23)
resource "aws_eks_cluster" "v130" {
  name     = "health-td-stale-eks-130"
  role_arn = "arn:aws:iam::539575856470:role/health-test-eks-cluster-role"
  version  = "1.30"

  vpc_config {
    subnet_ids = ["subnet-02381f24a432d3dbf", "subnet-088d2e13906443002"]
  }
}

# EKS case I: 1.28 (end of extended support 2025-11-26)
resource "aws_eks_cluster" "v128" {
  name     = "health-td-stale-eks-128"
  role_arn = "arn:aws:iam::539575856470:role/health-test-eks-cluster-role"
  version  = "1.28"

  vpc_config {
    subnet_ids = ["subnet-02381f24a432d3dbf", "subnet-088d2e13906443002"]
  }
}

# EKS case J: 1.23 via the public EKS module's cluster_version key
module "eks_v123" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "~> 19.0"
  cluster_name    = "health-td-stale-eks-123"
  cluster_version = "1.23"
  vpc_id          = "vpc-0f93d4753edf22790"
  subnet_ids      = ["subnet-02381f24a432d3dbf", "subnet-088d2e13906443002"]
}
