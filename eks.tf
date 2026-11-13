# 2 test EKS clusters for AWS/eks-kubernetes-version-upgrade.
# No worker nodes. API endpoint is private (not reachable from the internet).

locals {
  eks_subnets = ["subnet-02381f24a432d3dbf", "subnet-088d2e13906443002"]
}

# EKS case A: version is a plain literal
resource "aws_eks_cluster" "literal" {
  name     = "health-td-eks-literal"
  role_arn = var.eks_cluster_role_arn
  version  = "1.33"

  vpc_config {
    subnet_ids              = local.eks_subnets
    endpoint_private_access = true
    endpoint_public_access  = false
  }

  upgrade_policy {
    support_type = "EXTENDED"
  }

  tags = local.tags
}

# EKS case B: version comes from a variable default (variables.tf)
resource "aws_eks_cluster" "variable" {
  name     = "health-td-eks-variable"
  role_arn = var.eks_cluster_role_arn
  version  = var.eks_version

  vpc_config {
    subnet_ids              = local.eks_subnets
    endpoint_private_access = true
    endpoint_public_access  = false
  }

  upgrade_policy {
    support_type = "EXTENDED"
  }

  tags = local.tags
}
