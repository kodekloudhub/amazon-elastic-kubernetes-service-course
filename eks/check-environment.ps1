Write-Host -ForegroundColor Magenta "Checking environment readiness to deploy a cluster..."
Write-Host

if (-not (Get-Command aws -ErrorAction SilentlyContinue)) {
    throw "aws cli is not installed. Please install it."
}

if (-not (Get-Command terraform -ErrorAction SilentlyContinue)) {
    throw "terraform is not installed. Please install it."
}

if (-not (Get-Command kubectl -ErrorAction SilentlyContinue)) {
    throw "kubectl is not installed. Please install it."
}

$aws_default_region = aws configure get region
$current_region = if ($Env:AWS_REGION) {
    $Env:AWS_REGION
} elseif ($aws_default_region) {
    $aws_default_region
} else {
    $Env:AWS_DEFAULT_REGION
}

if ($current_region -ne "us-east-1") {
    if ($current_region) {
        throw "The current region is $current_region. This must be deployed in us-east-1."
    }

    throw "Unable to determine the current region. Use `"aws configure`" to set the default region to us-east-1"
}

Write-Host -ForegroundColor Green "- Running in correct region: us-east-1"
Write-Host "- Checking for required subnets..."

$zones = aws ec2 describe-availability-zones --query 'AvailabilityZones[].ZoneName' --output json | ConvertFrom-Json


$missing_subnets =  @( "a", "b", "c" ) |
ForEach-Object {
    $suffix = $_

    $zone = $zones | Where-Object { $_.EndsWith($suffix) }
    if (-not $zone) {
        throw "Error: Availability zone with suffix '$suffix' is missing. Please reset the lab and try again."
    }

    $subnets = aws ec2 describe-subnets --filters "Name=availability-zone,Values=$zone" --query 'Subnets[?State==`available`]' --output json | ConvertFrom-Json

    if (($subnets | Measure-Object | Select-Object -ExpandProperty Count) -eq 0) {
        $zone
    }
}

if (($missing_subnets | Measure-Object | Select-Object -ExpandProperty Count) -gt 0) {
    throw "Error: Missing subnets in the following availability zones: $([String]::Join(", ", $missing_subnets)). Please reset the lab and try again."
}

# No need to check for eksClusterRole. This is only defined in EKS course labs
Write-Host -ForegroundColor Green "Good to go!"





