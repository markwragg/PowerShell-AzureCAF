function Get-CafRegionDefinition {
    <#
    .SYNOPSIS
        Returns the cached set of Azure region abbreviation definitions.
    .DESCRIPTION
        Loads regionDefinition.json from the module root the first time it's needed and caches it for
        the lifetime of the module session, so repeated calls to Get-CafResourceName/Get-CafRegion don't
        re-read and re-parse the file from disk every time.
    .EXAMPLE
        Get-CafRegionDefinition
    #>
    [CmdletBinding()]
    param()

    if (-not $Script:CafRegionDefinitions) {
        $Script:CafRegionDefinitions = Get-Content -Path $Script:RegionDefinitionPath -Raw | ConvertFrom-Json
    }

    $Script:CafRegionDefinitions
}
