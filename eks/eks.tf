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

resource "aws_iam_policy" "loadbalancer_policy" {
  name        = "loadbalancer_policy"
  path        = "/"
  description = "My test policy"

  policy = <<EOT
	{
		"Version": "2012-10-17",
		"Statement": [
			{
				"Effect": "Allow",
				"Action": [
					"iam:CreateServiceLinkedRole",
					"ec2:DescribeAccountAttributes",
					"ec2:DescribeAddresses",
					"ec2:DescribeAvailabilityZones",
					"ec2:DescribeInternetGateways",
					"ec2:DescribeVpcs",
					"ec2:DescribeVpcPeeringConnections",
					"ec2:DescribeSubnets",
					"ec2:DescribeSecurityGroups",
					"ec2:DescribeInstances",
					"ec2:DescribeNetworkInterfaces",
					"ec2:DescribeTags",
					"ec2:GetCoipPoolUsage",
					"ec2:DescribeCoipPools",
					"elasticloadbalancing:DescribeLoadBalancers",
					"elasticloadbalancing:DescribeLoadBalancerAttributes",
					"elasticloadbalancing:DescribeListeners",
					"elasticloadbalancing:DescribeRules",
					"elasticloadbalancing:DescribeTargetGroups",
					"elasticloadbalancing:DescribeTargetGroupAttributes",
					"elasticloadbalancing:DescribeTargetHealth",
					"elasticloadbalancing:DescribeTags",
					"cognito-idp:DescribeUserPoolClient",
					"acm:ListCertificates",
					"acm:DescribeCertificate",
					"iam:ListServerCertificates",
					"iam:GetServerCertificate",
					"waf-regional:GetWebACL",
					"waf-regional:GetWebACLForResource",
					"waf-regional:AssociateWebACL",
					"waf-regional:DisassociateWebACL",
					"wafv2:GetWebACL",
					"wafv2:GetWebACLForResource",
					"wafv2:AssociateWebACL",
					"wafv2:DisassociateWebACL",
					"shield:GetSubscriptionState",
					"shield:DescribeProtection",
					"shield:CreateProtection",
					"shield:DeleteProtection",
					"waf:GetWebACL"
				],
				"Resource": "*"
			},
			{
				"Effect": "Allow",
				"Action": [
					"ec2:AuthorizeSecurityGroupIngress",
					"ec2:RevokeSecurityGroupIngress"
				],
				"Resource": "arn:aws:ec2:*:*:security-group/*"
			},
			{
				"Effect": "Allow",
				"Action": [
					"ec2:CreateSecurityGroup"
				],
				"Resource": "*"
			},
			{
				"Effect": "Allow",
				"Action": [
					"ec2:CreateTags"
				],
				"Resource": [
					"arn:aws:ec2:*:*:security-group/*",
					"arn:aws:ec2:*:*:subnet/*",
					"arn:aws:ec2:*:*:network-interface/*",
					"arn:aws:ec2:*:*:instance/*",
					"arn:aws:ec2:*:*:volume/*",
					"arn:aws:ec2:*:*:key-pair/*"
				]
			},
			{
				"Effect": "Allow",
				"Action": [
					"elasticloadbalancing:CreateLoadBalancer",
					"elasticloadbalancing:CreateTargetGroup",
					"elasticloadbalancing:CreateListener",
					"elasticloadbalancing:CreateRule"
				],
				"Resource": "*"
			},
			{
				"Effect": "Allow",
				"Action": [
					"elasticloadbalancing:DeleteLoadBalancer",
					"elasticloadbalancing:DeleteTargetGroup",
					"elasticloadbalancing:DeleteListener",
					"elasticloadbalancing:DeleteRule"
				],
				"Resource": "*"
			},
			{
				"Effect": "Allow",
				"Action": [
					"elasticloadbalancing:RegisterTargets",
					"elasticloadbalancing:DeregisterTargets",
					"elasticloadbalancing:SetIpAddressType",
					"elasticloadbalancing:SetSecurityGroups",
					"elasticloadbalancing:SetSubnets",
					"elasticloadbalancing:ModifyLoadBalancerAttributes",
					"elasticloadbalancing:ModifyTargetGroup",
					"elasticloadbalancing:ModifyTargetGroupAttributes",
					"elasticloadbalancing:ModifyListener",
					"elasticloadbalancing:AddTags",
					"elasticloadbalancing:RemoveTags"
				],
				"Resource": "*"
			}
		]
	}
  EOT
}

resource "aws_iam_role" "demo_eks" {
  name               = var.cluster_role_name
  assume_role_policy = data.aws_iam_policy_document.assume_role_eks.json
}

resource "aws_iam_role_policy_attachment" "demo_eks_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.demo_eks.name
}

resource "aws_iam_role_policy_attachment" "demo_eks_loadbalancer_policy" {
  policy_arn = aws_iam_policy.loadbalancer_policy.arn
  role       = aws_iam_role.demo_eks.name
}

# Optionally, enable Security Groups for Pods
# Reference: https://docs.aws.amazon.com/eks/latest/userguide/security-groups-for-pods.html
resource "aws_iam_role_policy_attachment" "demo_eks_AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.demo_eks.name
}

# resource "aws_eks_cluster" "demo_eks" {
#   name     = var.cluster_name
#   role_arn = aws_iam_role.demo_eks.arn

#   vpc_config {
#     subnet_ids = [
#       data.aws_subnets.public.ids[0],
#       data.aws_subnets.public.ids[1],
#       data.aws_subnets.public.ids[2]
#     ]
#   }

#   access_config {
#     authentication_mode = "CONFIG_MAP"
#     bootstrap_cluster_creator_admin_permissions = true
#   }

#   # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
#   # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
#   depends_on = [
#     aws_iam_role_policy_attachment.demo_eks_AmazonEKSClusterPolicy,
#     aws_iam_role_policy_attachment.demo_eks_AmazonEKSVPCResourceController,
#   ]
# }

# data "aws_eks_cluster" "demo_eks" {
#   name = aws_eks_cluster.demo_eks.name
# }
