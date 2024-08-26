function Get-ResourceName {
    param (
        [string]$prefix,
        [string]$resourceType,
        [string]$separator = "",
        [string]$convention = "pascal",
        [int]$maxLength = 24,
        [string]$extra = ""
    )

    # Helper function to apply case conventions
    function ConvertToConvention {
        param (
            [string]$name,
            [string]$convention
        )

        switch ($convention) {
            "camel" {
                return (-join ($name[0].ToLower() + $name.Substring(1)))
            }
            "pascal" {
                return ($name -replace '(\w)(\w*)', { 
                    param($m)
                    $m.Groups[1].Value.ToUpper() + $m.Groups[2].Value.ToLower() 
                })
            }
            "kebab" {
                return ($name -replace '\s+', '-').ToLower()
            }
            "snake" {
                return ($name -replace '\s+', '_').ToLower()
            }
            default { 
                return $name 
            }
        }
    }

    # Define the length rule based on resource type (simplified example)
    $lengthRule = @{
        "storage_account" = 24;
        "resource_group" = 90;
        "virtual_machine" = 15;
    }

    # Determine the maximum allowed length for the resource type
    if ($lengthRule.ContainsKey($resourceType)) {
        $maxAllowedLength = $lengthRule[$resourceType]
    } else {
        $maxAllowedLength = $maxLength
    }

    # Combine prefix and resource type
    $combinedName = "$prefix$separator$resourceType$extra"

    # Ensure the name is within the allowed length
    if ($combinedName.Length -gt $maxAllowedLength) {
        $combinedName = $combinedName.Substring(0, $maxAllowedLength)
    }

    # Apply the convention
    $formattedName = ConvertToConvention -name $combinedName -convention $convention

    return $formattedName
}

# Example usage
$prefix = "myPrefix"
$resourceType = "storage_account"
$separator = "-"
$convention = "snake"
$maxLength = 24
$extra = "extraText"

$resourceName = Get-ResourceName -prefix $prefix -resourceType $resourceType -separator $separator -convention $convention -maxLength $maxLength -extra $extra
Write-Output "Generated Resource Name: $resourceName"
