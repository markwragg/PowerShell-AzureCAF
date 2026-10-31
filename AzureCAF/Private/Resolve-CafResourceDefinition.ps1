function Resolve-CafResourceDefinition {
    <#
    .SYNOPSIS
        Resolves a -ResourceType, -Alias or -Resource value to exactly one resourceDefinition.json
        entry.
    .DESCRIPTION
        Shared resolution logic for Get-CafResourceName and Test-CafResourceName, so all three cmdlets
        identify a resource type the same way and report identical errors for an unknown/ambiguous
        value. Writes a non-terminating error and returns nothing if the value doesn't resolve to
        exactly one entry - callers should check for a $null/empty result and return without
        continuing.

        -ResourceType takes priority as the primary identifier if given, then -Alias, with -Resource
        narrowing *within* whichever of those matched (for the handful of types used by more than one
        kind of resource). When neither -ResourceType nor -Alias is given, -Resource is used as the
        primary identifier instead - every "Resource" friendly name in resourceDefinition.json happens
        to be globally unique today, so this only fails if that ever stops being true upstream.

        Callers don't need to guard against more than one of -ResourceType/-Alias/-Resource being
        supplied - e.g. piping Get-CafResourceType's output through by property name binds ResourceType,
        Resource and (via its Slug alias) Alias all at once, since they're all present on that object
        and all describe the same entry. Precedence just needs to be deterministic for that case, not
        an error - it's not a conflict unless the caller explicitly typed contradictory values, which
        isn't something this function can distinguish from the pipeline case anyway.
    .EXAMPLE
        Resolve-CafResourceDefinition -ResourceType 'Microsoft.Compute/virtualMachines'
    .EXAMPLE
        Resolve-CafResourceDefinition -Alias 'afd' -Resource 'classic'
    .EXAMPLE
        Resolve-CafResourceDefinition -Resource 'Key vault'
    #>
    [CmdletBinding()]
    param(
        [string]
        $ResourceType,

        [string]
        $Alias,

        [string]
        $Resource
    )

    $ResourceIsPrimary = -not $ResourceType -and -not $Alias

    if ($ResourceType) {
        $identifier = "'$ResourceType'"
        $candidates = Select-CafMatch -InputObject @(Get-CafResourceDefinition) -Property ResourceType -Value $ResourceType
    }
    elseif ($Alias) {
        $identifier = "alias '$Alias'"
        $candidates = Select-CafMatch -InputObject @(Get-CafResourceDefinition) -Property Slug -Value $Alias
    }
    else {
        $identifier = "resource '$Resource'"
        $candidates = Select-CafMatch -InputObject @(Get-CafResourceDefinition) -Property Resource -Value $Resource
    }

    if ($candidates.Count -eq 0) {
        Write-Error "No resource type matches $identifier. Use Get-CafResourceType to search for a supported resource type."
        return
    }

    if ($Resource -and -not $ResourceIsPrimary) {
        $allCandidates = $candidates
        $candidates = Select-CafMatch -InputObject $candidates -Property Resource -Value $Resource

        if ($candidates.Count -eq 0) {
            $options = ($allCandidates | ForEach-Object { "$($_.ResourceType) [$($_.Resource)]" }) -join "', '"
            Write-Error "'$Resource' doesn't match any resource for $identifier. Available: '$options'."
            return
        }
    }

    if ($candidates.Count -gt 1) {
        $options = ($candidates | ForEach-Object { "$($_.ResourceType) [$($_.Resource)]" }) -join "', '"
        $suggestion = if ($ResourceIsPrimary) { '-ResourceType' } else { '-Resource' }
        Write-Error "$identifier matches more than one resource type. Narrow it down with $suggestion`: '$options'."
        return
    }

    $candidates[0]
}
