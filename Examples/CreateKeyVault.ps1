<#
.SYNOPSIS
    This script demonstrates how to use the AzureCAF module to create a resource group, key vault,
    and storage account with consistent naming conventions, and configure diagnostic settings for
    the key vault.
#>
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

$NamingConvention = @{
    Path = "./$organisation-$environment.json"
    Prefix = $organisation,$environment
    Region = $region
}

# Org-standard prefix/region, saved once and reused for every resource in this deployment

$NamingConvention = New-CafNamingConvention @NamingConvention

if (-not $NamingConvention) {
    throw "Failed to create naming convention. Please check the JSON file and parameters."
}

$ConventionPath = $NamingConvention.FullName

# Generate Resource Group Name, Key Vault Name, and Storage Account Name using the naming convention

$rgName = Get-CafResourceName -ResourceType 'Microsoft.Resources/resourceGroups' -ConventionPath $NamingConvention.Path
$kvName = Get-CafResourceName -ResourceType 'Microsoft.KeyVault/vaults' -ConventionPath $ConventionPath

$kvStorage = @{
    Suffix = 'log'
    RandomSuffixLength = 4
    RandomSuffixSeed = 1    # Ensures consistent random suffix for storage account name
}

$stName = Get-CafResourceName @ConventionPath @kvStorage -ResourceType 'Microsoft.Storage/storageAccounts'

# Output the generated names for verification

"rgName: $rgName"
"kvName: $kvName"
"stName: $stName"

# Create the resources
$rg = New-AzResourceGroup -Name $rgName -Location $region

if (-not $rg) {
    throw "Failed to create resource group '$rgName' in region '$region'."
}

$kv = New-AzKeyVault -Name $kvName -ResourceGroupName $rgName -Location $region
$st = New-AzStorageAccount -Name $stName -ResourceGroupName $rgName -Location $region -SkuName Standard_LRS

# Point the Key Vault's diagnostic logs at the storage account
Set-AzDiagnosticSetting -ResourceId $kv.ResourceId -StorageAccountId $st.Id -Enabled $true -Category AuditEvent
