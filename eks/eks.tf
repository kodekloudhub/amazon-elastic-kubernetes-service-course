####################################################################
#
# Creates the EKS Cluster control plane
#
####################################################################

data "aws_iam_policy_document" "assume_role_eks" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "demo_eks" {
  name               = var.cluster_role_name
  assume_role_policy = data.aws_iam_policy_document.assume_role_eks.json
}

resource "aws_iam_role_policy_attachment" "demo_eks_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.demo_eks.name
}

# Optionally, enable Security Groups for Pods
resource "aws_iam_role_policy_attachment" "demo_eks_AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.demo_eks.name
}

resource "aws_eks_cluster" "demo_eks" {
  name     = var.cluster_name
  role_arn = aws_iam_role.demo_eks.arn

  vpc_config {
    subnet_ids = [
      data.aws_subnets.public.ids[0],
      data.aws_subnets.public.ids[1]
    ]
  }

  depends_on = [
    aws_iam_role_policy_attachment.demo_eks_AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.demo_eks_AmazonEKSVPCResourceController,
  ]
}

data "aws_eks_cluster" "deme_eks" {
  name = aws_eks_cluster.demo_eks.name
}
