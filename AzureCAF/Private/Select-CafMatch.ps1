function Select-CafMatch {
    <#
    .SYNOPSIS
        Filters a collection to the items whose property exactly matches a value, falling back to a
        partial ('contains') match only when nothing matches exactly.
    .DESCRIPTION
        Used by Get-CafResourceName/Get-CafResourceType to make -ResourceType/-Resource match as a substring
        for convenience, without that breaking exact lookups: partial matching alone is ambiguous for
        values like 'Microsoft.Compute/virtualMachines', since (case-insensitively) it's also a
        substring of 'Microsoft.Compute/virtualMachineScaleSets'. Checking for an exact match first means
        a fully-qualified value always resolves to itself, and the substring fallback only kicks in when
        there was no exact match to begin with.
    .EXAMPLE
        Select-CafMatch -InputObject $definitions -Property ResourceType -Value 'Microsoft.Compute/virtualMachines'
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [object[]]
        $InputObject,

        [Parameter(Mandatory)]
        [string]
        $Property,

        [Parameter(Mandatory)]
        [string]
        $Value
    )

    $exact = @($InputObject | Where-Object { $_.$Property -eq $Value })
    if ($exact.Count -gt 0) {
        return $exact
    }

    $pattern = Get-CafWildcardPattern -Value $Value
    @($InputObject | Where-Object { $_.$Property -like $pattern })
}
