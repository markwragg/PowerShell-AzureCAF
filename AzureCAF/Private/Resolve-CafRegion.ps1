function Resolve-CafRegion {
    <#
    .SYNOPSIS
        Resolves a -Region value to exactly one regionDefinition.json entry.
    .DESCRIPTION
        Shared resolution logic for Get-CafResourceName and Get-CafRegion, so both cmdlets identify a
        region the same way and report identical errors for an unknown/ambiguous value.

        Checks for an exact (case-insensitive) match against the ARM region name (e.g. 'eastus'), its
        display name (e.g. 'East US') or its CAF slug (e.g. 'eus') first - checking all three up front,
        rather than one at a time, matters for a short value like a slug: 'ae' (Australia East's slug)
        is also a substring of several other regions' ARM names (e.g. 'canadaeast', 'israelcentral'), so
        falling through to a substring search would make it ambiguous instead of resolving it.

        Only once no exact match exists does it fall back to a substring ('contains') search, same as
        -ResourceType/-Resource elsewhere in the module - against the ARM region name first, then the
        display name. The slug isn't included in that substring fallback: it's short enough that partial
        matching on it would mostly just produce ambiguous results, and a caller who doesn't already know
        the exact slug should be matching on the region name/display name instead.

        Writes a non-terminating error and returns nothing if the value doesn't resolve to exactly one
        entry - callers should check for a $null/empty result and return without continuing.
    .EXAMPLE
        Resolve-CafRegion -Region 'eastus'
    .EXAMPLE
        Resolve-CafRegion -Region 'East US'
    .EXAMPLE
        Resolve-CafRegion -Region 'eus'
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]
        $Region
    )

    $definitions = @(Get-CafRegionDefinition)

    $candidates = @($definitions | Where-Object { $_.Region -eq $Region -or $_.DisplayName -eq $Region -or $_.Slug -eq $Region })

    if ($candidates.Count -eq 0) {
        $candidates = Select-CafMatch -InputObject $definitions -Property Region -Value $Region

        if ($candidates.Count -eq 0) {
            $candidates = Select-CafMatch -InputObject $definitions -Property DisplayName -Value $Region
        }
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
