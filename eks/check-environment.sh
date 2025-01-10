# This script needs to be sourced

RED="\e[0;31m"
GREEN="\e[0;32m"
MAGENTA="\e[0;35m"
NC="\e[0m"

echo "Checking environment readiness to deploy a cluster..."
echo

if [[ -d "/Applications" ]] && [[ -d "/Library" ]] ; then
    echo -e "- ${MAGENTA}Detected MacOS terminal${NC}"
elif  [ "$AWS_EXECUTION_ENV" = "CloudShell" ] ; then
    echo -e "- ${MAGENTA}Detected AWS CloudShell terminal${NC}"
elif [ "$(netstat -ptn 2>&1 | grep '^tcp.*ttyd' | awk '{ split($4, a, ":"); split($7, b, "/"); printf "%s:%s\n", a[2], b[2] }')" = "8080:ttyd" ] ; then
    echo -e "- ${MAGENTA}Detected KodeKloud lab terminal${NC}"
else
    {
    source /etc/os-release
    echo -e "- ${MAGENTA}Detected Linux terminal: ${NAME}${NC}"
    }
fi

if ! command -v aws > /dev/null ; then
    echo -e "${RED}aws cli is not installed. Please install it.${NC}"
    return
fi

if ! command -v terraform > /dev/null ; then
    echo -e "${RED}terraform is not installed. Please install it.${NC}"
    return
fi

if ! command -v jq > /dev/null ; then
    echo -e "${RED}jq is not installed. Please install it.${NC}"
    return
fi

# Verify correct region
current_region=$AWS_REGION

if [[ -z "$current_region" ]]; then
    current_region=$(aws configure get region)
fi

# Fallback to environment variables if the region is not set
if [[ -z "$current_region" ]]; then
    current_region=$AWS_DEFAULT_REGION
fi

if [[ "$current_region" != "us-east-1" ]]; then
    if [[ -n "$current_region" ]]; then
        echo -e "${RED}The current region is ${current_region}. This must be deployed in us-east-1.${NC}"
        return
    fi

    echo "${RED}Unable to determine the current region. Use "aws configure" to set the default region to us-east-1.${NC}"
    return
fi

echo -e "- ${GREEN}Running in correct region: us-east-1${NC}"

echo "- Checking for default VPC"

VPC_ID=$(aws ec2 describe-vpcs --filters "Name=isDefault,Values=true" --query "Vpcs[0].VpcId" --output text)

if [ "$VPC_ID" == "None" ]; then
  echo "${RED}Error: No default VPC found.${NC}"
  return
fi

echo -e "${GREEN}- Using default VPC: ${VPC_ID}${NC}"

echo "- Checking for required subnets..."

# Fetch the list of availability zones
available_zones=$(aws ec2 describe-availability-zones --query 'AvailabilityZones[].ZoneName' --output json)

# Define the required suffixes
required_suffixes=("a" "b" "c")

# Initialize a list to track missing subnets or misconfigured attributes
missing_subnets=()
map_public_ip_errors=()

# Check for a subnet in each required zone
for suffix in "${required_suffixes[@]}"; do
    # Find zones ending with the required suffix
    zone=$(echo "$available_zones" | jq -r ".[] | select(endswith(\"$suffix\"))")

    if [ -z "$zone" ]; then
        echo -e "${RED}Error: Availability zone with suffix '$suffix' is missing.${NC}"
        echo "Please reset the lab and try again."
        return
    fi

    # Check for subnets in the zone within the specified VPC
    subnet_info=$(aws ec2 describe-subnets --filters "Name=availability-zone,Values=$zone" "Name=vpc-id,Values=$VPC_ID" \
        --query 'Subnets[?State==`available`]' --output json)

    subnet_count=$(echo "$subnet_info" | jq 'length')

    if [ "$subnet_count" -eq 0 ]; then
        missing_subnets+=("$zone")
    else
        # Verify MapPublicIpOnLaunch for all found subnets
        map_public_ip=$(echo "$subnet_info" | jq -r '.[].MapPublicIpOnLaunch' | grep -v "true")

        if [ -n "$map_public_ip" ]; then
            map_public_ip_errors+=("$zone")
        fi
    fi
done

# Handle missing subnets
if [ ${#missing_subnets[@]} -ne 0 ]; then
    echo -e "${RED}Error: Missing subnets in the following availability zones: ${missing_subnets[*]}${NC}"
    echo "Please reset the lab and try again."
    return
fi

# Handle subnets with incorrect MapPublicIpOnLaunch attribute
if [ ${#map_public_ip_errors[@]} -ne 0 ]; then
    echo -e "${RED}Error: The following availability zones have subnets with MapPublicIpOnLaunch set to false: ${map_public_ip_errors[*]}${NC}"
    echo "Please reset the lab and try again."
    return
fi

# We have the zones.
# Check for eksClusterRole being present and flag terraform accordingly.
if aws iam get-role --role-name eksClusterRole > /dev/null 2>&1 ; then
    # Role is present, suppress generation by terraform
    export TF_VAR_use_predefined_role=true
fi

echo -e "${GREEN}Good to go!${NC}"
