resource "aws_iam_policy" "loadbalancer_policy" {
  name        = var.additional_policy_name
  path        = "/"
  description = "Policy for granting rights to create loadbalancer services and EC2 volumes"

  policy = jsonencode(yamldecode(file("./policy.yaml")))
}

