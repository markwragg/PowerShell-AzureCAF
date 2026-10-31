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

        $ResourceRegex = $resource.regex.trimstart('"').trimend('"')
        $ValidationRegex = $resource.validation_regex.trimstart('"').trimend('"')

        if ($CleanInput) {
            $Prefix = Get-CleanString -InputObject $Prefix -Pattern $ResourceRegex
            $Suffix = Get-CleanString -InputObject $Suffix -Pattern $ResourceRegex
        }
        
        $resourceArr = @()

        $resourceArr += $Prefix
        $resourceArr += $resource.slug
        $resourceArr += $Suffix

        $Seperator = if ($resource.dashes) { $Seperator } else { '' }

        $resourceName = $resourceArr -join $Seperator

        if ($resource.lowercase -and $resourceName -cnotmatch "^[a-z]*$") {
            $resourceName = $resourceName.tolower()
            Write-Warning "Resource name has been converted to lower case due to naming requirement."
        }

        if ($resourceName.length -gt $resource.max_length) {
            $resourceName = $resourceName.Substring(0, $resource.max_length -1)
            Write-Warning "Resource name has been trimmed to $($resource.max_length) characters due to max length restriction."
        }

        if ($resourceName -notmatch $ValidationRegex) {
            Write-Error "invalid name for CAF naming $Name, the pattern $ValidationRegex doesn't match $resourceName"
        }
        else {
            return $resourceName
        }
    }
    else {
        Write-Error "$Name not known."
    }
}