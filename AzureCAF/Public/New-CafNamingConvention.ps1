function New-CafNamingConvention {
    <#
    .SYNOPSIS
        Saves a reusable set of Get-CafResourceName defaults to a JSON file, so your organization's
        naming convention doesn't need to be retyped on every call.
    .DESCRIPTION
        Writes a small JSON file that Get-CafResourceName's -ConventionPath reads defaults from for
        -Prefix, -Suffix, -Region, -Separator, -Casing, -InstanceNumberPadding and -RandomSuffixLength.
        Anything also passed explicitly to Get-CafResourceName still takes precedence over the file.

        -RandomSuffixSeed deliberately isn't included: a shared seed would make the "random" suffix
        identical for everyone using the file, defeating the uniqueness -RandomSuffixLength exists for -
        it only makes sense passed directly, per call.
    .PARAMETER Path
        Where to save the convention file, e.g. './contoso.json'.
    .PARAMETER Prefix
        One or more strings to use as the default -Prefix, e.g. a company name or environment.
    .PARAMETER Suffix
        One or more strings to use as the default -Suffix.
    .PARAMETER Region
        An Azure region (ARM name, display name or slug) to use as the default -Region - resolved and
        stored as its ARM name, so an unrecognized value is caught here rather than on every later call.
    .PARAMETER Separator
        The default -Separator. Omit to leave this to Get-CafResourceName's own default ('-').
    .PARAMETER Casing
        The default -Casing ('None', 'Lower', 'Upper' or 'Title'). Omit to leave this to
        Get-CafResourceName's own default ('None').
    .PARAMETER InstanceNumberPadding
        The default -InstanceNumberPadding. Omit to leave this to Get-CafResourceName's own default (3).
        Also accepts -Inp as an alias.
    .PARAMETER RandomSuffixLength
        The default -RandomSuffixLength. Omit to leave this to Get-CafResourceName's own default (0, i.e.
        no random suffix unless a call asks for one explicitly). Also accepts -Rsl as an alias.
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

        [ValidateSet('None', 'Lower', 'Upper', 'Title')]
        [string]
        $Casing,

        [Alias('Inp')]
        [ValidateRange(1, 10)]
        [int]
        $InstanceNumberPadding,

        [Alias('Rsl')]
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
    if ($PSBoundParameters.ContainsKey('Casing')) { $Convention.Casing = $Casing }
    if ($PSBoundParameters.ContainsKey('InstanceNumberPadding')) { $Convention.InstanceNumberPadding = $InstanceNumberPadding }
    if ($PSBoundParameters.ContainsKey('RandomSuffixLength')) { $Convention.RandomSuffixLength = $RandomSuffixLength }

    if ($Convention.Count -eq 0) {
        Write-Error 'Specify at least one of -Prefix, -Suffix, -Region, -Separator, -Casing, -InstanceNumberPadding or -RandomSuffixLength.'
        return
    }

    if ($PSCmdlet.ShouldProcess($Path, 'Create naming convention file')) {
        $Convention | ConvertTo-Json | Set-Content -Path $Path
        Get-Item -Path $Path
    }
}
