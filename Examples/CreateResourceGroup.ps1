<#
.SYNOPSIS
    This script demonstrates how to use the AzureCAF module to create a resource group, suffixed
    with the specified organisation, environment and region short code.
#>
[CmdletBinding(supportsShouldProcess)]
param(
    # Organisation name
    [Parameter(Mandatory = $true)]
    [string]$organisation,

    # Environment name (e.g., dev, test, prod)
    [Parameter(Mandatory = $true)]
    [string]$environment,

    # Azure region (e.g., eastus, westus)
    [Parameter(Mandatory = $true)]
    [string]$region
)

Import-Module AzureCAF

# Generate Resource Group name
$rgName = Get-CafResourceName -Alias rg -Suffix $organisation,$environment -Region $region

# Output the generated names for verification
"rgName: $rgName"

# Create the resource
if ($PSCmdlet.ShouldProcess("Resource Group: $rgName")) {
    New-AzResourceGroup -Name $rgName -Location $region
}