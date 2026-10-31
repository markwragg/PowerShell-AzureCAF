function Get-CafWildcardPattern {
    <#
    .SYNOPSIS
        Turns a plain string into a partial ('contains') wildcard pattern.
    .DESCRIPTION
        Used by Get-CafResourceName/Get-CafResourceType so that -ResourceType and -Resource match as a
        substring by default (e.g. 'virtualMachines' matches 'Microsoft.Compute/virtualMachines'),
        while still respecting an explicit wildcard pattern (e.g. '*storageAccount*' or 'disk?') if the
        caller already supplied one, rather than wrapping it a second time.
    .EXAMPLE
        Get-CafWildcardPattern -Value 'virtualMachines'
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [string]
        $Value
    )

    if ($Value -match '[*?\[\]]') {
        $Value
    }
    else {
        "*$Value*"
    }
}
