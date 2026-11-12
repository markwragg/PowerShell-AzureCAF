function Get-CafResourceType {
    <#
    .SYNOPSIS
        Looks up the Cloud Adoption Framework naming rules for one or more Azure resource types.
    .DESCRIPTION
        Searches the module's bundled resourceDefinition.json and returns a resource type's recommended
        CAF abbreviation, naming scope, length limits and casing rules - the same rules Get-CafResourceName
        builds a name against. A local, offline lookup against static data - not a replacement for
        Get-AzResourceProvider, which reports live resource provider availability from Azure.
    .PARAMETER ResourceType
        The ARM resource type to search for, e.g. 'Microsoft.Compute/virtualMachines'. Matches as a
        substring; pass an explicit wildcard pattern (e.g. 'Microsoft.Compute/*') for tighter control.
        If omitted, all resource types are returned (optionally filtered by -Resource/-Alias).
    .PARAMETER Resource
        The friendly resource name to search for, e.g. 'Virtual machine'. Matches as a substring. Useful
        to disambiguate ARM resource types that cover more than one kind of resource.
    .PARAMETER Alias
        The CAF abbreviation to search for, e.g. 'vm'. Matches as a substring, and also accepts -Slug.
    .PARAMETER TerraformResourceType
        The Terraform azurerm resource type to search for, e.g. 'azurerm_storage_account'. Matches as a
        substring against any value on a resource type's TerraformResourceType property - which is
        usually a single string, but an array for the handful of resource types with more than one
        current real azurerm equivalent (e.g. 'azurerm_linux_virtual_machine' and
        'azurerm_windows_virtual_machine' for a virtual machine); either one resolves it. $null for
        resource types Terraform doesn't model distinctly.
    .EXAMPLE
        Get-CafResourceType -ResourceType Microsoft.Compute/virtualMachines

        Returns the naming rule for an Azure virtual machine.
    .EXAMPLE
        Get-CafResourceType -ResourceType storageAccount

        Finds resource types whose ARM type contains 'storageAccount'.
    .EXAMPLE
        Get-CafResourceType -Alias vm

        Finds the resource type(s) that use the 'vm' abbreviation.
    .EXAMPLE
        Get-CafResourceType -TerraformResourceType azurerm_storage_account

        Finds the resource type that corresponds to the 'azurerm_storage_account' Terraform resource.
    .EXAMPLE
        Get-CafResourceType

        Lists every resource type known to the module.
    .LINK
        https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations
    #>
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)]
        [string]
        $ResourceType,

        [string]
        $Resource,

        [Alias('Slug')]
        [string]
        $Alias,

        [Alias('Tf')]
        [string]
        $TerraformResourceType
    )

    $definitions = @(Get-CafResourceDefinition)

    if ($ResourceType) {
        $definitions = Select-CafMatch -InputObject $definitions -Property ResourceType -Value $ResourceType
    }

    if ($Resource) {
        $definitions = Select-CafMatch -InputObject $definitions -Property Resource -Value $Resource
    }

    if ($Alias) {
        $definitions = Select-CafMatch -InputObject $definitions -Property Slug -Value $Alias
    }

    if ($TerraformResourceType) {
        $definitions = Select-CafMatch -InputObject $definitions -Property TerraformResourceType -Value $TerraformResourceType
    }

    $definitions | Select-Object ResourceType, Resource, Slug, TerraformResourceType, Scope, MinLength, MaxLength, Lowercase, Dashes
}
