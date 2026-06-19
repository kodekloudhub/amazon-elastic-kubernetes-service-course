####################################################################
# Main Configuration
####################################################################

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

provider "aws" {
  region = var.aws_region
}

####################################################################
# Outputs
####################################################################

output "cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.eks.cluster_endpoint
}

output "cluster_version" {
  description = "EKS cluster Kubernetes version"
  value       = module.eks.cluster_version
}

output "node_group_id" {
  description = "EKS managed node group ID"
  value       = module.eks.eks_managed_node_groups["primary"].node_group_id
}

output "node_iam_role_arn" {
  description = "IAM role ARN for worker nodes"
  value       = module.eks.eks_managed_node_groups["primary"].iam_role_arn
}

output "configure_kubectl" {
  description = "Command to configure kubectl"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}"
}
