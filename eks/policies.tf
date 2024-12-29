resource "aws_iam_policy" "loadbalancer_policy" {
  name        = var.additional_policy_name
  path        = "/"
  description = "Policy for granting rights to create loadbalancer services"

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
