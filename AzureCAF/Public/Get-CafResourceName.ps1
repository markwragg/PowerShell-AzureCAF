function Get-CafResourceName {
    <#
    .SYNOPSIS
        Generates an Azure resource name that follows the Cloud Adoption Framework naming convention.
    .DESCRIPTION
        Builds a resource name from an optional prefix, the Cloud Adoption Framework recommended
        abbreviation for the given Azure resource type, and an optional suffix. The result is checked
        against the resource type's length limit and allowed characters, and is trimmed and/or converted
        to lowercase automatically if the resource type requires it.

        Accepts pipeline input by property name, so a list of resource specs (e.g. imported from a CSV
        or a PSD1 describing a whole deployment) can be piped straight through to generate every name
        for a project in one batch - see the pipeline example below.

        Use Get-CafResourceType to discover the ResourceType/Resource values this cmdlet accepts. Use
        -Verbose to see the length-budget reasoning (reserved segments, trimming decisions) behind a
        given result.
    .PARAMETER ResourceType
        The ARM resource type to generate a name for, e.g. 'Microsoft.Compute/virtualMachines'. Matches
        as a substring by default, so 'virtualMachines' also works - as long as it narrows down to a
        single resource type, or you also specify -Resource. Tab completion lists the resource types
        known to the module. Normally used on its own (or -Alias, or -Resource, used instead); takes
        precedence if more than one happens to be specified, e.g. by piping in an object that has
        ResourceType, Alias and Resource properties all describing the same entry.
    .PARAMETER Alias
        The Cloud Adoption Framework abbreviation to generate a name for, e.g. 'vmss', if you already
        know it, used as a short alias for the ARM resource type. Matches as a substring by default,
        same as -ResourceType, and also accepts -Slug as an alias (so piping Get-CafResourceType's output
        straight in binds to this by its Slug property). Normally used on its own, instead of
        -ResourceType.
    .PARAMETER Resource
        The friendly name of the resource to generate, e.g. 'Key vault' - every such name in the
        module's data is unique, so on its own this works as a third alternative to -ResourceType/
        -Alias (also matching as a substring, so 'vault' alone works too). It also doubles as a
        disambiguator when combined with -ResourceType/-Alias, for the handful of ARM types used by
        more than one kind of resource (for example 'Microsoft.Web/sites' covers both a "Web app" and a
        "Function app", with different recommended abbreviations) - required in that case, since
        -ResourceType/-Alias alone would otherwise be ambiguous.
    .PARAMETER Prefix
        One or more strings to prepend to the resource name, in order, e.g. a company name, environment,
        or region. Falls back to -ConventionPath's value if not specified.
    .PARAMETER Suffix
        One or more strings to append to the resource name, in order. Falls back to -ConventionPath's
        value if not specified.
    .PARAMETER Separator
        The character(s) used to join the prefix, abbreviation and suffix segments together. Ignored for
        resource types that don't permit a separator character, in which case the segments are
        concatenated directly. Defaults to '-', or to -ConventionPath's value if it specifies one.
    .PARAMETER InstanceNumber
        An instance number to append to the resource name, for differentiating otherwise-identical
        resources (e.g. 'vm-sql-test-001', 'vm-sql-test-002' in the Cloud Adoption Framework's own naming
        examples). Zero-padded to -InstanceNumberPadding digits and reserved out of the resource type's
        maximum length before the rest of the name is trimmed, so it's never cut short.
    .PARAMETER InstanceNumberPadding
        The minimum number of digits to zero-pad -InstanceNumber to, e.g. the default of 3 formats '1'
        as '001'. A number that's already at least this many digits long is left as-is. Ignored unless
        -InstanceNumber is specified. Falls back to -ConventionPath's value if not specified.
    .PARAMETER RandomSuffixLength
        Appends this many random lowercase alphanumeric characters to the end of the name, for
        scenarios that require a globally unique name (such as a storage account or key vault). Always
        lowercase, even for a resource type that otherwise allows uppercase - the suffix exists for
        uniqueness, not communication, and doesn't need the extra entropy. The characters are reserved
        out of the resource type's maximum length before the rest of the name is trimmed, so the random
        suffix is never cut short. Falls back to -ConventionPath's value if not specified.
    .PARAMETER Seed
        Seeds the random number generator used by -RandomSuffixLength, so the same seed (with the same
        other parameters) always produces the same random characters - useful if you need to generate
        the same name idempotently, e.g. across repeated deployments. Ignored unless -RandomSuffixLength
        is specified.
    .PARAMETER ConventionPath
        Path to a JSON file of organizational naming-convention defaults for -Prefix, -Suffix,
        -Separator, -InstanceNumberPadding and -RandomSuffixLength, created with
        New-CafResourceNamingConvention. Any of those you also specify explicitly (including via the
        pipeline) take precedence over the file - this just saves retyping the same org-standard values
        on every call.
    .PARAMETER NoClean
        By default, characters that aren't valid for the given resource type are stripped from -Prefix
        and -Suffix before the name is built. Specify -NoClean to pass them through unmodified instead
        (the generated name will then fail validation if it contains invalid characters).
    .EXAMPLE
        Get-CafResourceName -ResourceType Microsoft.Compute/virtualMachines -Prefix contoso, prod -Suffix 01

        Generates a virtual machine name such as 'contoso-prod-vm-01'.
    .EXAMPLE
        Get-CafResourceName -ResourceType KeyVault -Prefix contoso

        -ResourceType matches as a substring, so this is equivalent to specifying the full
        'Microsoft.KeyVault/vaults' ARM type. If a substring matches more than one resource type,
        narrow it down with a longer -ResourceType value and/or -Resource.
    .EXAMPLE
        Get-CafResourceName -Alias vmss -Prefix contoso

        If you already know the Cloud Adoption Framework abbreviation, -Alias (or its -Slug alias) is a
        shorter alternative to -ResourceType.
    .EXAMPLE
        Get-CafResourceName -Resource 'Key vault' -Prefix contoso

        -Resource alone works too, since every friendly name is unique - a third alternative to
        -ResourceType/-Alias for when you only remember the resource's plain-English name.
    .EXAMPLE
        Get-CafResourceName -ResourceType Microsoft.Compute/virtualMachines -Prefix contoso, prod -InstanceNumber 1

        Generates 'contoso-prod-vm-001' - -InstanceNumber is zero-padded to 3 digits by default, matching
        the Cloud Adoption Framework's own example names such as 'vm-sql-test-001'.
    .EXAMPLE
        Get-CafResourceName -ResourceType Microsoft.Storage/storageAccounts -Prefix contoso -RandomSuffixLength 6

        Generates a storage account name such as 'contosostabcdef', with 6 random characters appended to
        help ensure the globally-unique name doesn't collide with one that already exists.
    .EXAMPLE
        Get-CafResourceName -ResourceType Microsoft.Storage/storageAccounts -Prefix contoso -RandomSuffixLength 6 -Seed 42

        Generates the same storage account name every time it's run, since the random suffix is seeded.
    .EXAMPLE
        Get-CafResourceName -ResourceType Microsoft.Web/sites -Resource 'Function app' -Prefix contoso, prod

        Generates a function app name. -Resource is required here because 'Microsoft.Web/sites' is also
        used for web apps, which use a different abbreviation.
    .EXAMPLE
        Get-CafResourceType -Slug kv | Get-CafResourceName -Prefix contoso -RandomSuffixLength 4

        Pipes the resource type definition for the 'kv' (Key Vault) abbreviation straight into
        Get-CafResourceName.
    .EXAMPLE
        Get-CafResourceName -ResourceType Microsoft.Compute/virtualMachines -Prefix contoso -ConventionPath ./contoso.json

        Uses -Prefix explicitly, but falls back to whatever -Suffix/-Separator/etc. are saved in
        contoso.json (see New-CafResourceNamingConvention) for anything not specified here.
    .EXAMPLE
        Import-Csv ./resources.csv | Get-CafResourceName

        Batch-generates a name for every row of resources.csv, which needs at least a ResourceType or
        Alias column, and may also have Resource/Prefix/Suffix/Separator/InstanceNumber columns.
    .LINK
        https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations
    #>
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]
        $ResourceType,

        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('Slug')]
        [ValidateNotNullOrEmpty()]
        [string]
        $Alias,

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Resource,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string[]]
        $Prefix,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string[]]
        $Suffix,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]
        $Separator = '-',

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateRange(0, [int]::MaxValue)]
        [int]
        $InstanceNumber,

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateRange(1, 10)]
        [int]
        $InstanceNumberPadding = 3,

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateRange(0, 24)]
        [int]
        $RandomSuffixLength = 0,

        [Parameter(ValueFromPipelineByPropertyName)]
        [int]
        $Seed,

        [string]
        $ConventionPath,

        [Parameter(ValueFromPipelineByPropertyName)]
        [switch]
        $NoClean
    )

    begin {
        function Get-CleanString {
            param (
                [string[]]$InputObject,
                [string]$Pattern
            )

            foreach ($Str in $InputObject) {
                $Str -replace $Pattern, ''
            }
        }

        function Get-TrimString {
            param (
                [string]$InputObject,
                [int]$MaxLength
            )

            if ($InputObject.Length -gt $MaxLength) {
                $InputObject.Substring(0, $MaxLength)
            }
            else {
                $InputObject
            }
        }

        $Convention = $null
        if ($ConventionPath) {
            if (-not (Test-Path -Path $ConventionPath -PathType Leaf)) {
                $PSCmdlet.ThrowTerminatingError(
                    [System.Management.Automation.ErrorRecord]::new(
                        [System.IO.FileNotFoundException]::new("Naming convention file not found: '$ConventionPath'."),
                        'ConventionFileNotFound',
                        [System.Management.Automation.ErrorCategory]::ObjectNotFound,
                        $ConventionPath
                    )
                )
            }

            try {
                $Convention = Get-Content -Path $ConventionPath -Raw -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop
                Write-Verbose "Loaded naming convention from '$ConventionPath'."
            }
            catch {
                $PSCmdlet.ThrowTerminatingError($_)
            }
        }
    }

    process {
        if (-not $ResourceType -and -not $Alias -and -not $Resource) {
            Write-Error 'Specify -ResourceType, -Alias or -Resource to identify the resource type.'
            return
        }

        $definition = Resolve-CafResourceDefinition -ResourceType $ResourceType -Alias $Alias -Resource $Resource

        if (-not $definition) {
            return
        }

        Write-Verbose "Resolved to $($definition.ResourceType) [$($definition.Resource)] (slug '$($definition.Slug)', max length $($definition.MaxLength), dashes $($definition.Dashes), lowercase $($definition.Lowercase))."

        $EffectivePrefix = if ($PSBoundParameters.ContainsKey('Prefix')) { $Prefix } else { $Convention.Prefix }
        $EffectiveSuffix = if ($PSBoundParameters.ContainsKey('Suffix')) { $Suffix } else { $Convention.Suffix }
        $EffectiveSeparator = if ($PSBoundParameters.ContainsKey('Separator')) { $Separator } elseif ($Convention.Separator) { $Convention.Separator } else { $Separator }
        $EffectiveInstanceNumberPadding = if ($PSBoundParameters.ContainsKey('InstanceNumberPadding')) { $InstanceNumberPadding } elseif ($Convention.InstanceNumberPadding) { $Convention.InstanceNumberPadding } else { $InstanceNumberPadding }
        $EffectiveRandomSuffixLength = if ($PSBoundParameters.ContainsKey('RandomSuffixLength')) { $RandomSuffixLength } elseif ($null -ne $Convention.RandomSuffixLength) { $Convention.RandomSuffixLength } else { $RandomSuffixLength }

        if ($EffectiveInstanceNumberPadding -lt 1 -or $EffectiveInstanceNumberPadding -gt 10) {
            Write-Error "InstanceNumberPadding from the naming convention must be between 1 and 10, but was $EffectiveInstanceNumberPadding."
            return
        }

        if ($EffectiveRandomSuffixLength -lt 0 -or $EffectiveRandomSuffixLength -gt 24) {
            Write-Error "RandomSuffixLength from the naming convention must be between 0 and 24, but was $EffectiveRandomSuffixLength."
            return
        }

        if ($NoClean) {
            $CleanPrefix = $EffectivePrefix
            $CleanSuffix = $EffectiveSuffix
        }
        else {
            $CleanPrefix = Get-CleanString -InputObject $EffectivePrefix -Pattern $definition.InvalidCharsRegex
            $CleanSuffix = Get-CleanString -InputObject $EffectiveSuffix -Pattern $definition.InvalidCharsRegex
        }

        $ActualSeparator = if ($definition.Dashes) { $EffectiveSeparator } else { '' }

        $HasInstanceNumber = $PSBoundParameters.ContainsKey('InstanceNumber')
        $InstanceSegment = if ($HasInstanceNumber) { $InstanceNumber.ToString().PadLeft($EffectiveInstanceNumberPadding, '0') } else { $null }

        $reservedLength = 0
        $reservedDescriptions = @()

        if ($InstanceSegment) {
            $reservedLength += $InstanceSegment.Length + $ActualSeparator.Length
            $reservedDescriptions += 'the instance number'
        }

        if ($EffectiveRandomSuffixLength -gt 0) {
            $reservedLength += $EffectiveRandomSuffixLength + $ActualSeparator.Length
            $reservedDescriptions += 'the random suffix'
        }

        $mainBudget = $definition.MaxLength - $reservedLength

        if ($reservedDescriptions.Count -gt 0) {
            Write-Verbose "Reserving $reservedLength character(s) for $($reservedDescriptions -join ' and '); $mainBudget of $($definition.MaxLength) remain for the prefix/slug/suffix."
        }
        else {
            Write-Verbose "No reserved segments; the full $mainBudget character limit is available for the prefix/slug/suffix."
        }

        if ($mainBudget -lt $definition.Slug.Length) {
            Write-Error "Not enough room within the $($definition.MaxLength) character limit for $($definition.ResourceType): '$($definition.Slug)' needs $($definition.Slug.Length) characters, but only $mainBudget are available after reserving space for $($reservedDescriptions -join ' and ')."
            return
        }

        $resourceArr = @($CleanPrefix) + @($definition.Slug) + @($CleanSuffix) | Where-Object { $_ }

        $resourceName = $resourceArr -join $ActualSeparator
        Write-Verbose "Joined '$($resourceArr -join "', '")' with separator '$ActualSeparator' -> '$resourceName' ($($resourceName.Length) characters)."

        if ($resourceName.Length -gt $mainBudget) {
            $beforeTrimLength = $resourceName.Length
            $resourceName = Get-TrimString -InputObject $resourceName -MaxLength $mainBudget
            $reservedNote = if ($reservedDescriptions.Count -gt 0) { " (after reserving space for $($reservedDescriptions -join ' and '))" } else { '' }
            Write-Warning "Resource name has been trimmed to $mainBudget characters due to the $($definition.MaxLength) character max length restriction$reservedNote."
            Write-Verbose "Trimmed from $beforeTrimLength to $mainBudget characters -> '$resourceName'."
        }

        if ($InstanceSegment) {
            $resourceName = $resourceName + $ActualSeparator + $InstanceSegment
            Write-Verbose "Appended instance segment '$InstanceSegment' -> '$resourceName'."
        }

        if ($EffectiveRandomSuffixLength -gt 0) {
            # Always lowercase alphanumeric, even for resource types that allow uppercase - the
            # random suffix exists for uniqueness, not communication, and 36^RandomSuffixLength is
            # already far more entropy than a uniqueness suffix needs.
            $CharPool = 'abcdefghijklmnopqrstuvwxyz0123456789'
            $Random = if ($PSBoundParameters.ContainsKey('Seed')) { [System.Random]::new($Seed) } else { [System.Random]::new() }
            $RandomSuffix = -join (1..$EffectiveRandomSuffixLength | ForEach-Object { $CharPool[$Random.Next($CharPool.Length)] })
            $resourceName = $resourceName + $ActualSeparator + $RandomSuffix
            Write-Verbose "Appended random suffix '$RandomSuffix' -> '$resourceName'."
        }

        if ($definition.Lowercase -and $resourceName -cmatch '[A-Z]') {
            $resourceName = $resourceName.ToLower()
            Write-Warning 'Resource name has been converted to lower case due to naming requirement.'
            Write-Verbose "Converted to lowercase -> '$resourceName'."
        }

        if ($resourceName -notmatch $definition.ValidationRegex) {
            Write-Error "The generated name '$resourceName' is not valid for $($definition.ResourceType) (pattern: $($definition.ValidationRegex))."
        }
        else {
            Write-Verbose "Final result: '$resourceName'."
            return $resourceName
        }
    }
}
