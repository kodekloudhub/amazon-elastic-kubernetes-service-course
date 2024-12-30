# This script needs to be sourced

RED="\e[0;31m"
GREEN="\e[0;32m"
NC="\e[0m"

echo "Checking environment readiness to deploy a cluster..."
echo

# Fetch the list of availability zones
available_zones=$(aws ec2 describe-availability-zones --query 'AvailabilityZones[].ZoneName' --output json)

# Define the required suffixes
required_suffixes=("a" "b" "c")

# Initialize a flag to track missing subnets
missing_subnets=()

# Check for a subnet in each required zone
for suffix in "${required_suffixes[@]}"; do
    # Find zones ending with the required suffix
    zone=$(echo "$available_zones" | jq -r ".[] | select(endswith(\"$suffix\"))")

    if [ -z "$zone" ]; then
        echo "${RED}Error: Availability zone with suffix '$suffix' is missing.${NC}"
        echo "Please reset the lab and try again."
        echo "If the issue persists, raise a question on the forums."
        return
    fi

    # Check for subnets in the zone
    subnet_present=$(aws ec2 describe-subnets --filters "Name=availability-zone,Values=$zone" --query 'Subnets[?State==`available`]' --output json | jq -e 'length > 0')

    if [ "$subnet_present" != "true" ]; then
        missing_subnets+=("$zone")
    fi
done


# If any required subnets are missing, exit with an error
if [ ${#missing_subnets[@]} -ne 0 ]; then
    echo "${RED}Error: Missing subnets in the following availability zones: ${missing_subnets[*]}${NC}"
    echo "Please reset the lab and try again."
    echo "If the issue persists, raise a question on the forums."
    echo
    return
fi

# We have the zones.
# Check for eksClusterRole being present and flag terraform accordingly.
if aws iam get-role --role-name eksClusterRole > /dev/null 2>&1 ; then
    # Role is present, suppress generation by terraform
    export TF_VAR_use_predefined_role=true
fi

echo -e "${GREEN}Good to go!${NC}"
