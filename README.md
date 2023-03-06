<!-- ABOUT THE PROJECT -->
# About The Project
This project contains resources, documentation, infrastructure as code, and guidelines for best practices deploying a customized Sitecore 10 application into AKS and Azure SQL Database. Documenation for this process is shared across existing accelerators and documentation provided by Sitecore on best practices for deploying containerized version of Sitecore 10.

## Contents

| folder    | description |
| --------- | ----------- |
| bootstrap | bootstrap the terraform by creating a storage account for tfstate |
| src       | the source code including any yaml for kubernetes |
| terraform | the terraform for creating infrastructure |


## Core Prerequisites

### Review Sitecore Documentation

Download the "Installation Guide for Production Environment with Kubernetes" document from [dev.sitecore.net](https://dev.sitecore.net/Downloads/Sitecore_Experience_Platform/103/Sitecore_Experience_Platform_103.aspx)

### Establish Submodule

Download submodules in order to get the files referenced in the submodules. This is to load [Sitecore's container deployment project](https://github.com/Sitecore/container-deployment) into this repository for reference. 

```
# run this after you run git clone
git submodule update --init --recursive
```

### Install CLIs

* Install [Helm](https://helm.sh/docs/intro/install)
* Install [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl-windows/#install-nonstandard-package-tools)
* Install [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
* Install [terraform](https://developer.hashicorp.com/terraform/downloads?ajs_aid=e7cb18f6-0e91-46ef-b3af-d22a83181326&product_intent=terraform)
* Install [sqlcmd](https://learn.microsoft.com/en-us/sql/tools/sqlcmd/sqlcmd-utility?view=sql-server-ver16)

```
choco install helm kubectl azure-cli terraform -y
```

### Provide Sitecore License

Place Sitecore license file named _sitecore-license.txt_ in repository root directory. This license must be a valid, compressed license. If not compressed, use /scripts/CompressLicense.ps1.

## Installation

### Bootstrap terraform by creating support infrastructure

Login to the azure cli

```
az login
```

Run the bootstrap terraform script. Assess and adjust any parameter values supplied to the external bootstrap module (region, name, etc.).

**NOTE: The terraform bootstrap action is a one-time execution.**

```
# run from the repository root
cd bootstrap
terraform init
terraform plan
terraform apply -auto-approve
```

This action will create a "tfstate" resource group with an Azure Storage Account to store the Terraform state for the application resource group. [Terraform Bootstrap module and documentation](https://github.com/ms-us-rcg-app-innovation/terraform-bootstrap). Acquire the Storage Account name and Access Key for infrasctructure commands.

### Create Azure Infrastructure

Run terraform init and specify the backend configuration. For configuration details, see the [Terraform documentation](https://developer.hashicorp.com/terraform/language/settings/backends/azurerm).

> bash

```bash
# run from terraform directory
NAME=sitecore
location="South Central US"
ARM_RESOURCE_GROUP="${NAME}-tfstate"
storage_account_name=      # tfstate resource group storage account
container_name="tfstate"
key="terraform.tfstate"
ARM_ACCESS_KEY=            # tfstate resource group storage account access key

terraform init \
-backend-config "container_name=${container_name}" \
-backend-config "key=${key}" \
-backend-config "storage_account_name=${storage_account_name}"

terraform plan -var="name=${NAME}" -var="location=${location}"
terraform apply -var="name=${NAME}" -var="location=${location}" -auto-approve
```

> powershell

```powershell
# run from terraform directory
$location="South Central US"
$name="sitecore"
$env:ARM_RESOURCE_GROUP="${name}-tfstate"
$env:ARM_STORAGE_ACCOUNT_NAME=""    # tfstate resource group storage account
$env:ARM_CONTAINER_NAME="tfstate"
$env:ARM_KEY="terraform.tfstate"
$env:ARM_ACCESS_KEY=""      # tfstate resource group storage account access key

terraform init `
-backend-config "container_name=$env:ARM_CONTAINER_NAME" `
-backend-config "key=$env:ARM_KEY" `
-backend-config "storage_account_name=$env:ARM_STORAGE_ACCOUNT_NAME"

terraform plan -var="name=${name}" -var="location=${location}"
terraform apply -var="name=${name}" -var="location=${location}" -auto-approve
```

### Connect to AKS and deploy sitecore yaml

```bash
# assumes the $name variable is set from the shell above
az login
az account set --subscription "" # put your subscription here
az aks get-credentials --resource-group ${name} --name ${name} # replace with your resource group name and cluster name
```

### Load Values for Helm

Acquire the system generated identity from the AKS cluster. Take the result of the command below and update the Helm values file kubernetes/sitecore_10_3/xm1/values.yaml. 

```powershell
az aks show -g ${name} -n ${name} --query addonProfiles.azureKeyvaultSecretsProvider.identity.clientId -o tsv
```

Also query to get the Key Vault name for the values file.

```powershell
az keyvault list -g ${name} --query [].name
```

Set the identity GUID to the keyVault.identity value and set the Key Vault name to keyVault.name.

### Install Sitecore via Helm

Navigate to the Sitecore 10.3 XM1 Kubernetes manifest directory

```powershell
cd kubernetes/sitecore_10_3/xm1
```

To prepare the application, execute SQL init Job to create and seed databases.

```powershell
helm template -f values.yaml -f values.secrets.yaml -s templates/secrets-class.yaml . | kubectl apply -f -
helm template -f values.yaml -f values.secrets.yaml -s templates/mssql-init.yaml . | kubectl apply -f -
```

Wait for the Job to complete before continuing.

Execute SQL script to confirm and establish the SQL logins and users. Use the Azure Portal to get the SQL Server info and user/password from the Key Vault.

```powershell
cd src/scripts
Set-ExecutionPolicy Unrestricted
.\EstablishSQLUsers.ps1 -Server <sql server fqdn> -User <admin user> -Password <admin password>
```

Remove the prep workloads.

```powershell
kubectl delete job mssql-init
kubectl delete secretproviderclass keyvault-secretproviderclass
```

Apply the manifest files for the Sitecore application.

```powershell
helm install -f values.yaml -f values.secrets.yaml sitecore .
```

Note the cluster's public IP address and add the following records to your local hosts file.

```bash
cd.globalhost
cm.globalhost
id.globalhost
```

## Cleanup

As part of this process, the client machine's IP address is allowed access to the Azure SQL Server. For privacy and security reasons, it is recommended to remove that firewall rule using the Azure Portal.

## Addons

## Security

## Testing

## Retail Materials

## Architecture

### AKS Reference Architecture

[see](https://learn.microsoft.com/en-us/azure/architecture/reference-architectures/containers/aks/baseline-aks)

![AKS Reference Architecture](https://learn.microsoft.com/en-us/azure/architecture/reference-architectures/containers/aks/images/baseline-architecture.svg)


## Solution Components

### Trademarks

Trademarks This project may contain trademarks or logos for projects, products, or services. Authorized use of Microsoft trademarks or logos is subject to and must follow Microsoft’s Trademark & Brand Guidelines. Use of Microsoft trademarks or logos in modified versions of this project must not cause confusion or imply Microsoft sponsorship. Any use of third-party trademarks or logos are subject to those third-party’s policies.
