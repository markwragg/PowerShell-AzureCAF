$Script:ModuleRoot = $PSScriptRoot
$Script:ResourceDefinitionPath = Join-Path $PSScriptRoot 'resourceDefinition.json'
$Script:RegionDefinitionPath = Join-Path $PSScriptRoot 'regionDefinition.json'

$Public = @( Get-ChildItem -Path "$PSScriptRoot\Public\*.ps1" -Recurse )
$Private = @( Get-ChildItem -Path "$PSScriptRoot\Private\*.ps1" -Recurse )

@($Public + $Private) | ForEach-Object {
    Try {
        . $_.FullName
    }
    Catch {
        Write-Error -Message "Failed to import function $($_.FullName): $_"
    }
}

# Registered here (rather than via the [ArgumentCompleter(...)] attribute on each parameter) because an
# attribute scriptblock isn't bound to this module's session state, so it can't see private functions
# like Get-CafResourceDefinition - it would silently fail and PowerShell would fall back to file
# completion. A scriptblock defined directly in the .psm1 doesn't have that problem.
$ResourceTypeCompleter = {
    param($CommandName, $ParameterName, $WordToComplete, $CommandAst, $FakeBoundParameters)
    $null = $CommandName, $ParameterName, $CommandAst, $FakeBoundParameters
    # Substring match, same as the cmdlets' own -ResourceType/-Alias partial matching, so what
    # tab-completes is consistent with what actually resolves.
    $Pattern = Get-CafWildcardPattern -Value $WordToComplete
    (Get-CafResourceDefinition).ResourceType |
        Select-Object -Unique |
        Where-Object { $_ -like $Pattern } |
        ForEach-Object { [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_) }
}

$SlugCompleter = {
    param($CommandName, $ParameterName, $WordToComplete, $CommandAst, $FakeBoundParameters)
    $null = $CommandName, $ParameterName, $CommandAst, $FakeBoundParameters
    $Pattern = Get-CafWildcardPattern -Value $WordToComplete
    (Get-CafResourceDefinition).Slug |
        Select-Object -Unique |
        Where-Object { $_ -like $Pattern } |
        ForEach-Object { [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_) }
}

$ResourceCompleter = {
    param($CommandName, $ParameterName, $WordToComplete, $CommandAst, $FakeBoundParameters)
    $null = $CommandName, $ParameterName, $CommandAst

    $Definitions = @(Get-CafResourceDefinition)

    # Narrow to whichever resource type the caller has already typed, if any, so -Resource only
    # offers the friendly names that actually apply to it (e.g. just 'Web app'/'Function app' once
    # -ResourceType Microsoft.Web/sites is on the line), rather than every friendly name there is.
    # $FakeBoundParameters is always keyed by the canonical parameter name, even if the caller typed
    # the -Slug alias instead of -Alias, so there's no separate case to handle for that.
    if ($FakeBoundParameters.ResourceType) {
        $Definitions = Select-CafMatch -InputObject $Definitions -Property ResourceType -Value $FakeBoundParameters.ResourceType
    }
    elseif ($FakeBoundParameters.Alias) {
        $Definitions = Select-CafMatch -InputObject $Definitions -Property Slug -Value $FakeBoundParameters.Alias
    }

    $Pattern = Get-CafWildcardPattern -Value $WordToComplete
    $Definitions.Resource |
        Select-Object -Unique |
        Where-Object { $_ -like $Pattern } |
        Sort-Object |
        ForEach-Object {
            # Friendly names routinely contain spaces/parentheses (e.g. 'Managed disk (OS)'), so the
            # completion text needs quoting to stay a single valid token once it's inserted.
            $Quoted = "'" + $_.Replace("'", "''") + "'"
            [System.Management.Automation.CompletionResult]::new($Quoted, $_, 'ParameterValue', $_)
        }
}

$RegionCompleter = {
    param($CommandName, $ParameterName, $WordToComplete, $CommandAst, $FakeBoundParameters)
    $null = $CommandName, $ParameterName, $CommandAst, $FakeBoundParameters
    # Matches against both the ARM region name and its display name, same as Resolve-CafRegion, so
    # typing either 'east' or 'East US' offers a completion - but always completes to the ARM name,
    # since that's the unambiguous value every other Azure PowerShell -Location parameter expects.
    $Pattern = Get-CafWildcardPattern -Value $WordToComplete
    (Get-CafRegionDefinition) |
        Where-Object { $_.Region -like $Pattern -or $_.DisplayName -like $Pattern } |
        Sort-Object -Property Region -Unique |
        ForEach-Object { [System.Management.Automation.CompletionResult]::new($_.Region, "$($_.Region) ($($_.DisplayName))", 'ParameterValue', $_.DisplayName) }
}

Register-ArgumentCompleter -CommandName 'Get-CafResourceName', 'Test-CafResourceName', 'Get-CafResourceType' -ParameterName 'ResourceType' -ScriptBlock $ResourceTypeCompleter
Register-ArgumentCompleter -CommandName 'Get-CafResourceName', 'Test-CafResourceName', 'Get-CafResourceType' -ParameterName 'Alias' -ScriptBlock $SlugCompleter
Register-ArgumentCompleter -CommandName 'Get-CafResourceName', 'Test-CafResourceName', 'Get-CafResourceType' -ParameterName 'Resource' -ScriptBlock $ResourceCompleter
Register-ArgumentCompleter -CommandName 'Get-CafResourceName', 'Get-CafRegion' -ParameterName 'Region' -ScriptBlock $RegionCompleter
