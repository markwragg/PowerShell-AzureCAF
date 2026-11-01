function Get-CafRegion {
    <#
    .SYNOPSIS
        Looks up the abbreviation for one or more Azure regions.
    .DESCRIPTION
        Searches the module's bundled regionDefinition.json for Azure regions and returns the short
        abbreviation Get-CafResourceName's -Region parameter resolves it to (e.g. 'eastus' -> 'eus'),
        along with its Azure-paired region (e.g. 'eastus' -> 'westus'), if it has one.

        This is a local, offline lookup against a static data set bundled with the module - it's not a
        replacement for Get-AzLocation (from the Az.Resources module), which calls the live Azure
        Resource Manager API to report which regions are available to a subscription right now.

        Region abbreviations aren't officially published by Microsoft for every region - the bundled
        list is sourced from https://www.jlaundry.nz/2022/azure_region_abbreviations/, a community
        reference, and may not cover newly-announced regions. PairedRegion is sourced from Microsoft's
        official https://learn.microsoft.com/en-us/azure/reliability/regions-list and is $null for a
        region that doesn't have one - newer regions increasingly don't, having moved to availability
        zones instead of a paired region for resiliency. PairedRegion is informational only;
        Get-CafResourceName's -Region doesn't resolve against it.
    .PARAMETER Region
        The ARM region name to search for, e.g. 'eastus', its display name, e.g. 'East US', or its CAF
        slug, e.g. 'eus'. The ARM name and display name match as a substring by default, same as
        -ResourceType on Get-CafResourceType, so 'east' alone matches multiple regions - the slug only
        matches exactly, since it's short enough that partial matching on it would mostly just be
        ambiguous. If omitted, every known region is returned.
    .EXAMPLE
        Get-CafRegion -Region eastus

        Returns the 'eus' abbreviation for East US, along with its paired region, 'westus'.
    .EXAMPLE
        Get-CafRegion -Region 'East US'

        Looks up the same region by its display name instead of its ARM name.
    .EXAMPLE
        Get-CafRegion -Region eus

        Looks up the same region by its slug instead.
    .EXAMPLE
        Get-CafRegion

        Lists every region known to the module.
    .LINK
        https://www.jlaundry.nz/2022/azure_region_abbreviations/
    #>
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)]
        [string]
        $Region
    )

    $AllDefinitions = @(Get-CafRegionDefinition)
    $definitions = $AllDefinitions

    if ($Region) {
        $definitions = @($AllDefinitions | Where-Object Slug -EQ $Region)

        if ($definitions.Count -eq 0) {
            $definitions = Select-CafMatch -InputObject $AllDefinitions -Property Region -Value $Region
        }

        if ($definitions.Count -eq 0) {
            $definitions = Select-CafMatch -InputObject $AllDefinitions -Property DisplayName -Value $Region
        }
    }

    $definitions | Select-Object Region, DisplayName, Slug, PairedRegion
}
