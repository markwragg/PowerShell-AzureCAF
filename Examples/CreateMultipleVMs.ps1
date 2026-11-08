<#
.SYNOPSIS
    This script demonstrates how to use the AzureCAF module to create a resource group, suffixed
    with the specified organisation, environment and region short code.
#>
[cmdletBinding(supportsShouldProcess)]
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

    # Number of VMs to create
    [int]
    $vmCount = 5,

    [string]
    $Image = 'Win2025Datacenter',

    [string]
    $Size = 'Standard_DS1_v2'
)

Import-Module AzureCAF

# Generate Resource Group name
$rgName = Get-CafResourceName -Alias rg -Suffix $organisation, $environment -Region $region
$vmNames = Get-CafResourceName -Alias vm -Suffix $organisation, $environment -Region $region -Count $vmCount

# Output the generated names for verification
"vmNames: $($VMNames -join ', ')"
"rgName: $rgName"

if ($PSCmdlet.ShouldProcess($($VMNames -join ', '),"Get credentials")) {
    $Credential = Get-Credential -Message "Enter credentials for the VMs"
}

# Create the resources
foreach ($vmName in $vmNames) {
    if ($PSCmdlet.ShouldProcess($vmName,"Create VM in Resource Group: $rgName")) {
        New-AzVM -ResourceGroupName $rgName -Name $vmName -Location $region -Image $Image -Size $Size -Credential $Credential
    }
}