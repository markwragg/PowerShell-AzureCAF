<#
.SYNOPSIS
    This script demonstrates how to use the AzureCAF module to create a resource group, key vault,
    and storage account with consistent naming conventions, and configure diagnostic settings for
    the key vault.

.NOTES
    Uses the Alias to identify each resource type, to keep the commands brief.
    - rg = Resource Group
    - kv = Key Vault
    - st = Storage Account

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

$NamingConventionParams = @{
    Path   = "./$organisation-$environment.json"
    Suffix = $organisation, $environment
    Region = $region
}

# Org-standard suffix/region, saved once and reused for every resource in this deployment
$NamingConvention = New-CafNamingConvention @NamingConventionParams -Force

if (-not $NamingConvention) {
    throw "Failed to create naming convention. Please check the JSON file and parameters."
}

$ConventionPath = $NamingConvention.FullName

# Generate Resource Group Name, Key Vault Name, and Storage Account Name using the naming convention
$rgName = Get-CafResourceName -Alias rg -Convention $ConventionPath
$kvName = Get-CafResourceName -Alias kv -Convention $ConventionPath

# Adds 'log' suffix and a random 4-character suffix to the storage account name
# Uses Rss: RandomSuffixSeed to ensure the same random suffix is generated identically each time for consistency
$stName = Get-CafResourceName -Alias st -Convention $ConventionPath -Suffix 'log' -Rsl 4 -Rss 123

# Output the generated names for verification
"rgName: $rgName"
"kvName: $kvName"
"stName: $stName"

# Create the resources
if ($PSCmdlet.ShouldProcess("Resource Group: $rgName, Key Vault: $kvName, Storage Account: $stName")) {

    try {
        $rg = New-AzResourceGroup -Name $rgName -Location $region
        if (-not $rg) {
            throw "Failed to create resource group '$rgName' in region '$region'."
        }

        $kv = New-AzKeyVault -Name $kvName -ResourceGroupName $rgName -Location $region
        if (-not $kv) {
            throw "Failed to create Key Vault '$kvName' in resource group '$rgName'."
        }

        $st = New-AzStorageAccount -Name $stName -ResourceGroupName $rgName -Location $region -SkuName Standard_LRS
        if (-not $st) {
            throw "Failed to create Storage Account '$stName' in resource group '$rgName'."
        }

        # Configure diagnostic settings for the Key Vault
        Set-AzDiagnosticSetting -ResourceId $kv.ResourceId -StorageAccountId $st.Id -Enabled $true -Category AuditEvent
    }
    catch {
        throw "An error occurred while creating resources: $_"
    }
}
