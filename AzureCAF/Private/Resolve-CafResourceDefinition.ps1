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

        -ResourceType takes priority as the primary identifier if given, then -Alias, then
        -TerraformResourceType, with -Resource and (when -ResourceType/-Alias is primary)
        -TerraformResourceType all narrowing *within* whichever of those matched (for the handful of
        types used by more than one kind of resource). When none of -ResourceType/-Alias/
        -TerraformResourceType is given, -Resource is used as the primary identifier instead - every
        "Resource" friendly name in resourceDefinition.json happens to be globally unique today, so this
        only fails if that ever stops being true upstream.

        Callers don't need to guard against more than one of -ResourceType/-Alias/-Resource being
        supplied - e.g. piping Get-CafResourceType's output through by property name binds ResourceType,
        Resource and (via its Slug alias) Alias all at once, since they're all present on that object
        and all describe the same entry: narrowing by -Alias/-Resource after an already-unambiguous
        -ResourceType match is a no-op in that case, since the pipelined values already agree with it.
        Precedence just needs to be deterministic for that case, not an error - it's not a conflict
        unless the caller explicitly typed contradictory values, in which case -Alias/-Resource narrowing
        a -ResourceType match down to zero candidates reports that clearly rather than silently ignoring
        it.
    .EXAMPLE
        Resolve-CafResourceDefinition -ResourceType 'Microsoft.Compute/virtualMachines'
    .EXAMPLE
        Resolve-CafResourceDefinition -Alias 'afd' -Resource 'classic'
    .EXAMPLE
        Resolve-CafResourceDefinition -ResourceType 'Microsoft.Web/sites' -Alias 'func'
    .EXAMPLE
        Resolve-CafResourceDefinition -Resource 'Key vault'
    .EXAMPLE
        Resolve-CafResourceDefinition -TerraformResourceType 'azurerm_storage_account'
    #>
    [CmdletBinding()]
    param(
        [string]
        $ResourceType,

        [string]
        $Alias,

        [string]
        $Resource,

        [string]
        $TerraformResourceType
    )

    $ResourceIsPrimary = -not $ResourceType -and -not $Alias -and -not $TerraformResourceType

    if ($ResourceType) {
        $identifier = "'$ResourceType'"
        $candidates = Select-CafMatch -InputObject @(Get-CafResourceDefinition) -Property ResourceType -Value $ResourceType
    }
    elseif ($Alias) {
        $identifier = "alias '$Alias'"
        $candidates = Select-CafMatch -InputObject @(Get-CafResourceDefinition) -Property Slug -Value $Alias
    }
    elseif ($TerraformResourceType) {
        $identifier = "terraform resource type '$TerraformResourceType'"
        $candidates = Select-CafMatch -InputObject @(Get-CafResourceDefinition) -Property TerraformResourceType -Value $TerraformResourceType
    }
    else {
        $identifier = "resource '$Resource'"
        $candidates = Select-CafMatch -InputObject @(Get-CafResourceDefinition) -Property Resource -Value $Resource
    }

    if ($candidates.Count -eq 0) {
        Write-Error "No resource type matches $identifier. Use Get-CafResourceType to search for a supported resource type."
        return
    }

    if ($Alias -and $ResourceType) {
        $allCandidates = $candidates
        $candidates = Select-CafMatch -InputObject $candidates -Property Slug -Value $Alias

        if ($candidates.Count -eq 0) {
            $options = ($allCandidates | ForEach-Object { "$($_.ResourceType) [$($_.Resource)]" }) -join "', '"
            Write-Error "'$Alias' doesn't match any resource for $identifier. Available: '$options'."
            return
        }
    }

    if ($TerraformResourceType -and ($ResourceType -or $Alias)) {
        $allCandidates = $candidates
        $candidates = Select-CafMatch -InputObject $candidates -Property TerraformResourceType -Value $TerraformResourceType

        if ($candidates.Count -eq 0) {
            $options = ($allCandidates | ForEach-Object { "$($_.ResourceType) [$($_.Resource)]" }) -join "', '"
            Write-Error "'$TerraformResourceType' doesn't match any resource for $identifier. Available: '$options'."
            return
        }
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
