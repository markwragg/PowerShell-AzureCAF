function Get-ResourceName {
    <#
    .EXAMPLE
        Get-ResourceName -Name azurerm_virtual_machine -Prefix tsp,dev,neu -Suffix phx,tst
    #>
    [cmdletbinding()]
    param(
    [string]
        $Name,

        [string[]]
        $Prefix,
        
        [string[]]
        $Suffix,

        [string]
        $Seperator = '-',

        [bool]
        $CleanInput = $true
    )

    function Get-CleanString {
        param (
            [string[]]$InputObject,
            [string]$Pattern
        )

        foreach ($Str in $InputObject) {
            $Str -replace $Pattern,''
        }
    }

    function Get-TrimString {
        param (
            [string]$InputObject,
            [int]$MaxLength
        )

        if ($InputObject.Length -gt $MaxLength) {
            $InputObject.Substring(0, $MaxLength -1)
        }
        else {
            $InputObject
        }
    }

    $resources = Get-Content $PSScriptRoot/resourceDefinition.json | ConvertFrom-Json

    $resource = $resources | Where-Object { $_.name -eq $Name }

    if ($resource) {

        if ($CleanInput) {
            $Prefix = Get-CleanString -InputObject $Prefix -Pattern $resource.regex
            $Suffix = Get-CleanString -InputObject $Suffix -Pattern $resource.regex
        }
        
        $resourceArr = @()

        $resourceArr += $Prefix
        $resourceArr += $resource.slug
        $resourceArr += $Suffix

        $Seperator = if ($resource.dashes) { $Seperator } else { '' }

        $resourceName = $resourceArr -join $Seperator

        if ($resource.lowercase -and $resourceName -cmatch "[A-Z]*$") {
            $resourceName = $resourceName.tolower()
            Write-Warning "Resource name has been converted to lower case due to naming requirement."
        }

        if ($resourceName.length -gt $resource.length.max) {
            $resourceName = $resourceName.Substring(0, $resource.length.max -1)
            Write-Warning "Resource name has been trimmed to $($resource.length.max) characters due to max length restriction."
        }

        if ($resourceName -cnotmatch $resource.regex) {
            Write-Error "faled validation $resourceName does not match $($resource.regex)"
        }

        return $resourceName
    }
    else {
        Write-Error "$Name not known."
    }
}