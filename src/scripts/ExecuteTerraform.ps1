param(
    [Parameter(Mandatory = $true)]
    [string]$TFStateStorageAccount,
    [Parameter(Mandatory = $true)]
    [string]$AccessKey,
    [Parameter()]
    [string]$Location,
    [Parameter()]
    [string]$Name
)

if([string]::IsNullOrWhiteSpace($Location))
{
    $Location = "South Central US"
}

if([string]::IsNullOrWhiteSpace($Name))
{
    $Name = "sitecore"
}

$env:ARM_RESOURCE_GROUP="${Name}-tfstate"
$env:ARM_STORAGE_ACCOUNT_NAME=$TFStateStorageAccount
$env:ARM_CONTAINER_NAME="tfstate"
$env:ARM_KEY="terraform.tfstate"
$env:ARM_ACCESS_KEY=$AccessKey

Push-Location ..\..\terraform\

terraform init `
-backend-config "container_name=$env:ARM_CONTAINER_NAME" `
-backend-config "key=$env:ARM_KEY" `
-backend-config "storage_account_name=$env:ARM_STORAGE_ACCOUNT_NAME"

terraform plan -var="name=${Name}" -var="location=${Location}"
terraform apply -var="name=${Name}" -var="location=${Location}" -auto-approve

Pop-Location