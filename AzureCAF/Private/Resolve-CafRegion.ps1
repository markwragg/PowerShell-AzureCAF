function Resolve-CafRegion {
    <#
    .SYNOPSIS
        Resolves a -Region value to exactly one regionDefinition.json entry.
    .DESCRIPTION
        Shared resolution logic for Get-CafResourceName and Get-CafRegion, so both cmdlets identify a
        region the same way and report identical errors for an unknown/ambiguous value. Matches against
        the ARM region name (e.g. 'eastus') first, since that's the unambiguous machine-readable form,
        then falls back to the display name (e.g. 'East US') if nothing matched - both match as a
        substring by default, same as -ResourceType/-Resource elsewhere in the module, via
        Select-CafMatch.

        Writes a non-terminating error and returns nothing if the value doesn't resolve to exactly one
        entry - callers should check for a $null/empty result and return without continuing.
    .EXAMPLE
        Resolve-CafRegion -Region 'eastus'
    .EXAMPLE
        Resolve-CafRegion -Region 'East US'
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]
        $Region
    )

    $definitions = @(Get-CafRegionDefinition)

    $candidates = Select-CafMatch -InputObject $definitions -Property Region -Value $Region

    if ($candidates.Count -eq 0) {
        $candidates = Select-CafMatch -InputObject $definitions -Property DisplayName -Value $Region
    }

    if ($candidates.Count -eq 0) {
        Write-Error "No Azure region matches '$Region'. Use Get-CafRegion to search for a supported region."
        return
    }

    if ($candidates.Count -gt 1) {
        $options = ($candidates | ForEach-Object { "$($_.Region) [$($_.DisplayName)]" }) -join "', '"
        Write-Error "'$Region' matches more than one Azure region. Narrow it down with the ARM region name: '$options'."
        return
    }

    $candidates[0]
}
