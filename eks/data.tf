###############################################################
#
# This file contains configuration for all data source queries
#
###############################################################

data "aws_vpc" "default_vpc" {
  default = true
}

# Get the subnets to use for the cluster and autoscaling group
data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default_vpc.id]
  }
  filter {
    name = "availability-zone"
    values = [
      "${var.aws_region}c",
      "${var.aws_region}d"
    ]
  }
}

data "aws_ssm_parameter" "node_ami" {
  name = "/aws/service/eks/optimized-ami/1.29/amazon-linux-2/recommended/image_id"
}
