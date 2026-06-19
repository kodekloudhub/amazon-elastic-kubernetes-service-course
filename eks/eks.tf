####################################################################
# EKS Cluster with Managed Node Groups
#
# This replaces the previous self-managed node implementation
# with AWS Managed Node Groups for better maintainability and
# automatic node lifecycle management.
####################################################################

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = "1.31"

  # Use existing VPC and subnets
  vpc_id     = data.aws_vpc.default_vpc.id
  subnet_ids = data.aws_subnets.public.ids

  # Allow public access (same as before)
  cluster_endpoint_public_access = true

  # Enable cluster creator admin permissions
  enable_cluster_creator_admin_permissions = true

  # Managed Node Group (replaces self-managed nodes)
  eks_managed_node_groups = {
    primary = {
      name = "${var.cluster_name}-node-group"

      # Amazon Linux 2023 (latest EKS-optimized AMI)
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = ["t3.medium"]
      disk_size      = 30

      # Node scaling configuration
      min_size     = var.node_group_min_size
      max_size     = var.node_group_max_size
      desired_size = var.node_group_desired_capacity

      # Use same subnets as before
      subnet_ids = data.aws_subnets.public.ids

      # IAM policies for worker nodes
      iam_role_additional_policies = {
        AmazonEKSWorkerNodePolicy          = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
        AmazonEKS_CNI_Policy               = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
        AmazonEC2ContainerRegistryReadOnly = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
        AmazonSSMManagedInstanceCore       = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
        LoadBalancerPolicy                 = aws_iam_policy.loadbalancer_policy.arn
      }

      # Tags for cluster autoscaler
      tags = {
        "k8s.io/cluster-autoscaler/enabled"             = "true"
        "k8s.io/cluster-autoscaler/${var.cluster_name}" = "owned"
      }
    }
  }

  # EKS Add-ons
  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }
}
