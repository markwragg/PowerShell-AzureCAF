<#
.SYNOPSIS
    This script demonstrates how to use the AzureCAF module to create a resource group, suffixed
    with the specified organisation, environment and region short code.
#>
param(
    # Organisation name
    [string]$organisation = 'contoso',

    # Environment name (e.g., dev, test, prod)
    [string]$environment = 'dev',

    # Azure region (e.g., eastus, westus)
    [string]$region = 'eastus'
)

Import-Module AzureCAF

# Generate Resource Group name
$rgName = Get-CafResourceName -ResourceType 'Microsoft.Resources/resourceGroups' -Suffix $organisation,$environment -Region $region

$rgName
# rg-contoso-dev-eus