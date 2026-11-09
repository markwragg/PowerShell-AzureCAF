<#
.SYNOPSIS
    This script demonstrates how to use the AzureCAF module to generate resource names and then
    pass them as parameters into a Bicep template (main.bicep) deployment, so the names of the
    resources declared in the template remain CAF-compliant without hard-coding them.

.NOTES
    Deploys main.bicep, which provisions a storage account and a key vault using the names
    generated below.
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    # Organisation name
    [Parameter(Mandatory = $true)]
    [string]$organisation,

    # Environment name (e.g., dev, test, prod)
    [Parameter(Mandatory = $true)]
    [string]$environment,

    # Azure region (e.g., eastus, westus)
    [Parameter(Mandatory = $true)]
    [string]$region,

    # Seed for the random suffix - keep this fixed for a given deployment so the same resource
    # names are generated every time the script is rerun with the same other parameters
    [int]$randomSuffixSeed = 123
)

Import-Module AzureCAF

# Generate names for the resource group and the resources declared in main.bicep
$rgName = Get-CafResourceName -Alias rg -Suffix $organisation, $environment -Region $region
$stName = Get-CafResourceName -Alias st -Suffix $organisation, $environment -Region $region -RandomSuffixLength 4 -RandomSuffixSeed $randomSuffixSeed
$kvName = Get-CafResourceName -Alias kv -Suffix $organisation, $environment -Region $region -RandomSuffixLength 4 -RandomSuffixSeed $randomSuffixSeed

# Output the generated names for verification
"rgName: $rgName"
"stName: $stName"
"kvName: $kvName"

if ($PSCmdlet.ShouldProcess("Resource Group: $rgName, Bicep deployment: $stName, $kvName")) {

    $rg = Get-AzResourceGroup -Name $rgName -ErrorAction SilentlyContinue
    if (-not $rg) {
        $rg = New-AzResourceGroup -Name $rgName -Location $region
        if (-not $rg) {
            throw "Failed to create resource group '$rgName' in region '$region'."
        }
    }

    # Pass the generated names as parameters into the Bicep template
    $deployment = New-AzResourceGroupDeployment -ResourceGroupName $rgName -TemplateFile "$PSScriptRoot/main.bicep" -storageAccountName $stName -keyVaultName $kvName -location $region

    if (-not $deployment -or $deployment.ProvisioningState -ne 'Succeeded') {
        throw "Bicep deployment to resource group '$rgName' did not succeed."
    }
}
