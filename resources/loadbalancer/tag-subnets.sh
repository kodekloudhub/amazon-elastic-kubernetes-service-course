#!/usr/bin/env bash

set -euo pipefail

echo "Tagging subnets for Kubernetes ELB integration..."

VPC_ID=$(aws ec2 describe-vpcs \
  --filters Name=is-default,Values=true \
  --query 'Vpcs[0].VpcId' \
  --output text)

if [[ "$VPC_ID" == "None" || -z "$VPC_ID" ]]; then
  echo "No default VPC found."
  exit 1
fi

echo "Default VPC: $VPC_ID"

aws ec2 describe-subnets \
  --filters Name=vpc-id,Values="$VPC_ID" \
  --query 'Subnets[].SubnetId' \
  --output text |
tr '\t' '\n' |
while read -r subnet; do
  echo "Tagging subnet $subnet..."

  aws ec2 create-tags \
    --resources "$subnet" \
    --tags \
      Key=kubernetes.io/role/internal-elb,Value=1 \
      Key=kubernetes.io/role/elb,Value=1
done

echo "Done."