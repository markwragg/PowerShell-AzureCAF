function New-CafNamingConvention {
    <#
    .SYNOPSIS
        Saves a reusable set of Get-CafResourceName defaults (prefix, suffix, region, separator, etc.)
        to a JSON file, so your organization's naming convention doesn't need to be retyped on every
        call.
    .DESCRIPTION
        Writes a small JSON file that Get-CafResourceName's -ConventionPath reads defaults from for
        -Prefix, -Suffix, -Region, -Separator, -InstanceNumberPadding and -RandomSuffixLength. Anything
        you pass explicitly to Get-CafResourceName still takes precedence over the file - this is just a
        way to avoid repeating the same organization-standard values (company name, environment, region,
        your preferred separator/padding) on every call.

        -RandomSuffixSeed deliberately isn't one of these defaults, even though Get-CafResourceName has
        it - a convention file is meant to be the same shared values reused verbatim by everyone who
        points -ConventionPath at it, but a seed baked in that way would make the "random" suffix
        identical for every one of those calls, defeating the uniqueness -RandomSuffixLength exists for.
        It only makes sense as a per-call value (e.g. for one idempotent redeploy), so it stays something
        you pass to Get-CafResourceName directly.
    .PARAMETER Path
        Where to save the convention file, e.g. './contoso.json'.
    .PARAMETER Prefix
        One or more strings to use as the default -Prefix, e.g. a company name or environment - see the
        naming components guide this links to for what's commonly included.
    .PARAMETER Suffix
        One or more strings to use as the default -Suffix.
    .PARAMETER Region
        An Azure region (ARM name, display name or slug) to use as the default -Region - resolved and
        stored as its ARM region name, the same way Get-CafResourceName resolves it, so an unrecognized
        value is caught here rather than on every later call that uses the file.
    .PARAMETER Separator
        The default -Separator. Omit to leave this to Get-CafResourceName's own default ('-').
    .PARAMETER InstanceNumberPadding
        The default -InstanceNumberPadding. Omit to leave this to Get-CafResourceName's own default (3).
    .PARAMETER RandomSuffixLength
        The default -RandomSuffixLength. Omit to leave this to Get-CafResourceName's own default (0, i.e.
        no random suffix unless a call asks for one explicitly).
    .PARAMETER Force
        Overwrite -Path if it already exists.
    .EXAMPLE
        New-CafNamingConvention -Path ./contoso.json -Prefix contoso, prod -Region eastus -Separator '-' -InstanceNumberPadding 2

        Saves a convention so that Get-CafResourceName -ConventionPath ./contoso.json applies that
        prefix, region, separator and padding by default.
    .EXAMPLE
        Get-CafResourceName -ResourceType Microsoft.Compute/virtualMachines -ConventionPath ./contoso.json -InstanceNumber 1

        Uses the saved convention, overriding only -InstanceNumber for this particular call.
    .LINK
        https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming#choose-naming-components
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory, Position = 0)]
        [string]
        $Path,

        [string[]]
        $Prefix,

        [string[]]
        $Suffix,

        [string]
        $Region,

        [string]
        $Separator,

        [ValidateRange(1, 10)]
        [int]
        $InstanceNumberPadding,

        [ValidateRange(0, 24)]
        [int]
        $RandomSuffixLength,

        [switch]
        $Force
    )

    if ((Test-Path -Path $Path) -and -not $Force) {
        Write-Error "'$Path' already exists. Specify -Force to overwrite it."
        return
    }

    $Convention = [ordered]@{}

    if ($PSBoundParameters.ContainsKey('Prefix')) { $Convention.Prefix = $Prefix }
    if ($PSBoundParameters.ContainsKey('Suffix')) { $Convention.Suffix = $Suffix }

    if ($PSBoundParameters.ContainsKey('Region')) {
        $RegionDefinition = Resolve-CafRegion -Region $Region

        if (-not $RegionDefinition) {
            return
        }

        $Convention.Region = $RegionDefinition.Region
    }

    if ($PSBoundParameters.ContainsKey('Separator')) { $Convention.Separator = $Separator }
    if ($PSBoundParameters.ContainsKey('InstanceNumberPadding')) { $Convention.InstanceNumberPadding = $InstanceNumberPadding }
    if ($PSBoundParameters.ContainsKey('RandomSuffixLength')) { $Convention.RandomSuffixLength = $RandomSuffixLength }

    if ($Convention.Count -eq 0) {
        Write-Error 'Specify at least one of -Prefix, -Suffix, -Region, -Separator, -InstanceNumberPadding or -RandomSuffixLength.'
        return
    }

    if ($PSCmdlet.ShouldProcess($Path, 'Create naming convention file')) {
        $Convention | ConvertTo-Json | Set-Content -Path $Path
        Get-Item -Path $Path
    }
}
