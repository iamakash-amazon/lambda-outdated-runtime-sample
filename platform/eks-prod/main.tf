# EKS case K: production-style cluster through terraform-aws-modules/eks (code only, not deployed).
# Root Terraform does not load this folder.
#
# Upgrade traps (what moving 1.31 -> 1.33+ must change):
#  - One minor version at a time: 1.31 -> 1.32 -> 1.33 (control plane first, then node groups, then add-ons).
#  - Amazon EKS publishes no AL2 AMIs for 1.33 and later: node groups on ami_type AL2_x86_64 must move to
#    AL2023_x86_64_STANDARD, and AL2 bootstrap.sh arguments (bootstrap_extra_args) must become nodeadm config.
#  - cluster_addons pin versions built for 1.31: each must move to a version for the new minor.
#  - Module v19 -> v20 to get AL2023 and access entries: manage_aws_auth_configmap / aws_auth_roles were removed
#    in v20 (aws-auth ConfigMap -> access entries, authentication_mode).
#  - The AWS provider must move from ~> 4.x to >= 5.x for module v20.
#  - helm.tf: the cluster-autoscaler image tag must match the cluster minor version.
#  - manifests/: flowcontrol.apiserver.k8s.io/v1beta3 was removed in Kubernetes 1.32.

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.21"

  cluster_name    = "payments-prod"
  cluster_version = "1.32"

  vpc_id     = "vpc-0f93d4753edf22790"
  subnet_ids = ["subnet-02381f24a432d3dbf", "subnet-088d2e13906443002"]

  cluster_endpoint_public_access = false

  cluster_addons = {
    coredns = {
      addon_version = "v1.11.4-eksbuild.92"
    }
    kube-proxy = {
      addon_version = "v1.32.13-eksbuild.65"
    }
    vpc-cni = {
      addon_version = "v1.23.2-eksbuild.8"
    }
    aws-ebs-csi-driver = {
      addon_version = "v1.35.0-eksbuild.1"
    }
  }

  manage_aws_auth_configmap = true
  aws_auth_roles = [
    {
      rolearn  = "arn:aws:iam::539575856470:role/payments-platform-admin"
      username = "platform-admin"
      groups   = ["system:masters"]
    },
  ]

  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"
  }

  eks_managed_node_groups = {
    general = {
      instance_types = ["m6i.large"]
      min_size       = 2
      max_size       = 6
      desired_size   = 3

      enable_bootstrap_user_data = true
      bootstrap_extra_args       = "--kubelet-extra-args '--max-pods=110 --node-labels=pool=general'"
    }

    batch = {
      ami_type       = "AL2_x86_64_GPU"
      instance_types = ["g5.xlarge"]
      min_size       = 0
      max_size       = 4
      desired_size   = 0

      taints = [{ key = "nvidia.com/gpu", value = "true", effect = "NO_SCHEDULE" }]
    }
  }

  tags = { purpose = "aws-health-e2e", case = "K" }
}
