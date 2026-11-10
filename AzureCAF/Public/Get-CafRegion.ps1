function Get-CafRegion {
    <#
    .SYNOPSIS
        Looks up the abbreviation for one or more Azure regions.
    .DESCRIPTION
        Searches the module's bundled regionDefinition.json and returns the abbreviation
        Get-CafResourceName's -Region resolves to (e.g. 'eastus' -> 'eus'), along with its Azure-paired
        region if it has one. A local, offline lookup against static data - not a replacement for
        Get-AzLocation, which reports live region availability from Azure.

        Abbreviations aren't officially published by Microsoft for every region, so coverage may lag
        newly-announced ones. PairedRegion is informational only ($null where a region has moved to
        availability zones instead) - -Region doesn't resolve against it.
    .PARAMETER Region
        The ARM region name (e.g. 'eastus'), display name (e.g. 'East US') or CAF slug (e.g. 'eus') to
        search for. The name/display name match as a substring; the slug matches exactly only, since
        partial matching on it would mostly just be ambiguous. If omitted, every region is returned.
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
