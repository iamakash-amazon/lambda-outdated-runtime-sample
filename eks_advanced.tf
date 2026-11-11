# Harder EKS test cases (C-G). No worker nodes; private API endpoint only.

locals {
  is_prod = true

  # EKS case C: for_each over a map; version is each.value.version
  eks_fleet = {
    "foreach-a" = { version = "1.31" }
  }

  # EKS case G: version from a locals map lookup
  eks_versions = {
    standard = "1.34"
  }
}

resource "aws_eks_cluster" "fleet" {
  for_each = local.eks_fleet
  name     = "health-td-eks-${each.key}"
  role_arn = var.eks_cluster_role_arn
  version  = each.value.version

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

# EKS case D: version picked by a conditional
resource "aws_eks_cluster" "conditional" {
  name     = "health-td-eks-conditional"
  role_arn = var.eks_cluster_role_arn
  version  = local.is_prod ? "1.32" : "1.35"

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

# EKS case E: version only in eks.auto.tfvars.json
resource "aws_eks_cluster" "tfvars_json" {
  name     = "health-td-eks-tfvars-json"
  role_arn = var.eks_cluster_role_arn
  version  = var.eks_json_version

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

# EKS case G: STANDARD upgrade policy (known: TD wrongly says "extended support")
resource "aws_eks_cluster" "standard_policy" {
  name     = "health-td-eks-standard"
  role_arn = var.eks_cluster_role_arn
  version  = local.eks_versions["standard"]

  vpc_config {
    subnet_ids              = local.eks_subnets
    endpoint_private_access = true
    endpoint_public_access  = false
  }

  upgrade_policy {
    support_type = "STANDARD"
  }

  tags = local.tags
}

# EKS case F: CloudFormation template, version is !Ref to a Parameter default
resource "aws_cloudformation_stack" "cfn_eks" {
  name          = "health-td-cfn-eks"
  template_body = file("${path.module}/cloudformation/eks.yaml")
  parameters = {
    ClusterRoleArn = var.eks_cluster_role_arn
    SubnetIds      = join(",", local.eks_subnets)
  }
  timeout_in_minutes = 40
  tags               = local.tags
}
