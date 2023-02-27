# Using terraform to deploy the base infrastructure

## Initialize Backend

```bash
$ARM_RESOURCE_GROUP=
$ARM_STORAGE_ACCOUNT_NAME=
$ARM_CONTAINER_NAME=tfstate
$ARM_KEY=terraform.tfstate
$ARM_ACCESS_KEY=

terraform init \
-backend-config "container_name=$env:ARM_CONTAINER_NAME" \
-backend-config "key=$env:ARM_KEY" \
-backend-config "storage_account_name=$env:ARM_STORAGE_ACCOUNT_NAME"
```

```powershell
$env:ARM_RESOURCE_GROUP=""
$env:ARM_STORAGE_ACCOUNT_NAME=""
$env:ARM_CONTAINER_NAME="tfstate"
$env:ARM_KEY="terraform.tfstate"
$env:ARM_ACCESS_KEY=""

terraform init `
-backend-config "container_name=$env:ARM_CONTAINER_NAME" `
-backend-config "key=$env:ARM_KEY" `
-backend-config "storage_account_name=$env:ARM_STORAGE_ACCOUNT_NAME"
```

## Check for errors

```
terraform plan -var="name=sitecore" -var="location=South Central US"
```

## Deploy

```
terraform apply -var="name=sitecore" -var="location=South Central US" -auto-approve
```

## user ids for access policies

Because different users can run CI and local, the user can create a `terraform.tfvars` file locally to hold the list of user ids for the access policy. The syntax is as follows:

```tfvars
user_ids = [ 
    "00000000-0000-0000-0000-000000000000",
    "11111111-1111-1111-1111-111111111111"
]
```

The user can also specify an environment variable such as the following:

```bash
export TF_VAR_user_ids='["00000000-0000-0000-0000-000000000000","11111111-1111-1111-1111-111111111111"]'
```