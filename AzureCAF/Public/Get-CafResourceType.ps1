function Get-CafResourceType {
    <#
    .SYNOPSIS
        Looks up the Cloud Adoption Framework naming rules for one or more Azure resource types.
    .DESCRIPTION
        Searches the module's bundled resourceDefinition.json for Azure resource types and returns their
        recommended CAF abbreviation along with the naming scope, length limits and casing rules that
        Get-CafResourceName uses to build a compliant name.

        This is a local, offline lookup against a static data set bundled with the module. It's not a
        replacement for Get-AzResourceProvider (from the Az.Resources module): that cmdlet calls the live
        Azure Resource Manager API to report which resource providers/types are registered and available
        in a subscription, and requires being signed in to Azure. Get-CafResourceType has no dependency on
        Az.Resources or an Azure session - it only answers "what's the recommended naming convention for
        this resource type", not "is this resource type available to me right now".
    .PARAMETER ResourceType
        The ARM resource type to search for, e.g. 'Microsoft.Compute/virtualMachines'. Matches as a
        substring by default, e.g. 'virtualMachines' or 'compute' both match it too - pass an explicit
        wildcard pattern (e.g. 'Microsoft.Compute/*') for tighter control, such as anchoring to the
        start. If omitted, all resource types are returned (optionally filtered by -Resource/-Alias).
    .PARAMETER Resource
        The friendly resource name to search for, e.g. 'Virtual machine'. Matches as a substring by
        default, same as -ResourceType. Useful to disambiguate ARM resource types that cover more than
        one kind of resource (for example 'Microsoft.Compute/disks' covers both a "Managed disk (OS)"
        and a "Managed disk (data)").
    .PARAMETER Alias
        The Cloud Adoption Framework abbreviation to search for, e.g. 'vm', used as a short alias for
        the ARM resource type. Matches as a substring by default, same as -ResourceType/-Resource, and
        also accepts -Slug as an alias.
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
        $Alias
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

    $definitions | Select-Object ResourceType, Resource, Slug, Scope, MinLength, MaxLength, Lowercase, Dashes
}
