<#
.SYNOPSIS
    This script demonstrates how to use the AzureCAF module to create a storage account whose
    random uniqueness suffix is generated consistently, so rerunning the script always produces
    the same storage account name - and the script does nothing if that storage account already
    exists.

.NOTES
    Uses -RandomSuffixSeed (alias -Rss) so the random suffix is derived deterministically from the
    seed rather than being different on every run. Pass a seed value that's stable for this
    deployment (e.g. a hash of the organisation/environment/region, or just a fixed number you
    choose and keep), so repeated runs - and repeated deployments by other people/pipelines using
    the same inputs - always resolve to the same storage account name.
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

    # Resource Group to create the storage account in
    [Parameter(Mandatory = $true)]
    [string]$resourceGroupName,

    # Seed for the random suffix - keep this fixed for a given deployment so the same storage
    # account name is generated every time the script is rerun with the same other parameters
    [int]$randomSuffixSeed = 123
)

Import-Module AzureCAF

# Generate the storage account name. RandomSuffixLength (-Rsl) adds 4 random characters to help
# ensure global uniqueness, and RandomSuffixSeed (-Rss) makes those characters the same every time
# this script runs with the same seed and other parameters.
$stName = Get-CafResourceName -Alias st -Suffix $organisation, $environment -Region $region -RandomSuffixLength 4 -RandomSuffixSeed $randomSuffixSeed

"stName: $stName"

# Only create the storage account if it doesn't already exist - rerunning the script again is
# then a no-op rather than an error or a duplicate resource.
$existing = Get-AzStorageAccount -ResourceGroupName $resourceGroupName -Name $stName -ErrorAction SilentlyContinue

if ($existing) {
    "Storage account '$stName' already exists in resource group '$resourceGroupName' - nothing to do."
}
elseif ($PSCmdlet.ShouldProcess("Storage Account: $stName", "Create")) {
    $st = New-AzStorageAccount -ResourceGroupName $resourceGroupName -Name $stName -Location $region -SkuName Standard_LRS
    if (-not $st) {
        throw "Failed to create Storage Account '$stName' in resource group '$resourceGroupName'."
    }
}
