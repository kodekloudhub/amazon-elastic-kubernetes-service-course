# This script needs to be sourced

RED="\e[0;31m"
GREEN="\e[0;32m"
NC="\e[0m"

echo "Checking environment readiness to deploy a cluster"
echo

# Check we have required subnets
# Fetch the list of availability zones
available_zones=$(aws ec2 describe-availability-zones --query 'AvailabilityZones[].ZoneName' --output json)

# Define the required suffixes
required_suffixes=("a" "b" "c")

# Initialize a flag to track missing zones
missing_zones=()

# Check for each required zone
for suffix in "${required_suffixes[@]}"; do
    if ! echo "$available_zones" | jq -e ".[] | select(endswith(\"$suffix\"))" &> /dev/null; then
        missing_zones+=("$suffix")
    fi
done

# If any required zones are missing, report error
if [ ${#missing_zones[@]} -ne 0 ]; then
    echo -e "${RED}Error: Missing availability zones with the following suffixes: ${missing_zones[*]}${NC}"
    echo "Please reset the lab and try again."
    echo "If the issue persists, raise a question on the forums."
    echo
else
    # We have the zones.
    # Check for eksClusterRole being present and flag terraform accordingly.
    if aws iam get-role --role-name eksClusterRole > /dev/null 2>&1 ; then
        # Role is present, suppress generation by terraform
        export TF_VAR_use_predefined_role=true
    fi

    echo -e "${GREEN}Good to go!${NC}"
fi