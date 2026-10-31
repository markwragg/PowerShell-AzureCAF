function Get-CafResourceDefinition {
    <#
    .SYNOPSIS
        Returns the cached set of CAF resource naming definitions.
    .DESCRIPTION
        Loads resourceDefinition.json from the module root the first time it's needed and caches it for
        the lifetime of the module session, so repeated calls to Get-CafResourceName/Get-CafResourceType don't
        re-read and re-parse the file from disk every time.
    .EXAMPLE
        Get-CafResourceDefinition
    #>
    [CmdletBinding()]
    param()

    if (-not $Script:CafResourceDefinitions) {
        $Script:CafResourceDefinitions = Get-Content -Path $Script:ResourceDefinitionPath -Raw | ConvertFrom-Json
    }

    $Script:CafResourceDefinitions
}
