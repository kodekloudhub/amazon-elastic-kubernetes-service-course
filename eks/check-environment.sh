# This script needs to be sourced

RED="\e[0;31m"
GREEN="\e[0;32m"
NC="\e[0m"

echo "Checking environment readiness to deploy a cluster"
echo

# Check enough subnets
num_subnets=$(aws ec2 describe-subnets | jq '.Subnets | length')

if [ $num_subnets -lt 3 ] ; then
    echo -e "${RED}Insufficent subnets to deploy a cluster.${NC}"
    echo "Please reset the lab and try again."
    echo "If the issue persists, raise a question on the forums."
    echo
else
    # Check for eksClusterRole being present
    if aws iam get-role --role-name eksClusterRole > /dev/null 2>&1 ; then
        # Role is present, suppress generation by terraform
        export TF_VAR_use_predefined_role=true
    fi

    echo -e "${GREEN}Good to go!${NC}"
fi