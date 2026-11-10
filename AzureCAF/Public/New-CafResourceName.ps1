function New-CafResourceName {
    <#
    .SYNOPSIS
        Generates an Azure resource name that follows the Cloud Adoption Framework naming convention,
        returning the full result as an object.
    .DESCRIPTION
        Builds a resource name from an optional prefix, the CAF-recommended abbreviation for the given
        Azure resource type, and an optional suffix - trimmed, cleaned and cased to fit that resource
        type's length limit, allowed characters and casing rules.

        Returns an object with Name, ResourceType, Resource, Slug, InstanceNumber and RandomSuffix
        properties - use Get-CafResourceName instead for just the name as a plain string. Accepts
        pipeline input by property name, so a list of resource specs (e.g. from a CSV) can be batch-
        generated in one call - see the pipeline example below. Use Get-CafResourceType to discover the
        accepted ResourceType/Resource values, and -Verbose to see the length-budget reasoning behind a
        result.
    .PARAMETER ResourceType
        The ARM resource type to generate a name for, e.g. 'Microsoft.Compute/virtualMachines'. Matches
        as a substring; use -Resource to disambiguate if needed. Tab-completable, and takes precedence
        over -Alias/-Resource if more than one is specified.
    .PARAMETER Alias
        The CAF abbreviation to generate a name for, e.g. 'vmss' - a shorter alternative to
        -ResourceType (also accepts -Slug). Can also disambiguate an ambiguous -ResourceType, the same
        way -Resource does.
    .PARAMETER Resource
        The resource's friendly name, e.g. 'Key vault' - a third alternative to -ResourceType/-Alias.
        Required alongside either when an ARM type covers more than one kind of resource, e.g.
        'Microsoft.Web/sites' (Web app vs Function app).
    .PARAMETER Prefix
        One or more strings to prepend to the resource name, in order. Falls back to -ConventionPath's
        value if not specified.
    .PARAMETER Suffix
        One or more strings to append to the resource name, in order. Falls back to -ConventionPath's
        value if not specified.
    .PARAMETER Region
        An Azure region (ARM name, display name or CAF slug, e.g. 'eastus'/'East US'/'eus') to resolve
        and append after any -Suffix. Falls back to -ConventionPath's value if not specified. Use
        Get-CafRegion to look up supported regions.
    .PARAMETER Separator
        The character(s) used to join the prefix/slug/suffix segments. Ignored for resource types that
        don't permit one. Defaults to '-', or to -ConventionPath's value if it specifies one.
    .PARAMETER Casing
        Re-cases every segment of the generated name - -Prefix/-Suffix, the slug and -Region: 'Lower',
        'Upper' or 'Title'. Defaults to 'None', or to -ConventionPath's value. Overridden by a resource
        type that requires an all-lowercase name. Doesn't affect the returned object's Slug property,
        which always reports the canonical CAF abbreviation.
    .PARAMETER InstanceNumber
        An instance number to append, for differentiating otherwise-identical resources (e.g.
        'vm-sql-test-001'). Zero-padded to -InstanceNumberPadding digits. Also accepts -In.
    .PARAMETER InstanceNumberPadding
        Minimum digits to zero-pad -InstanceNumber to (default 3). Falls back to -ConventionPath's
        value if not specified. Also accepts -Inp.
    .PARAMETER Count
        Generates this many names in one call, with sequential instance numbers starting from
        -InstanceNumber (or 1). Each name gets its own random suffix if -RandomSuffixLength is used.
    .PARAMETER RandomSuffixLength
        Appends this many random lowercase alphanumeric characters, for resource types that need a
        globally-unique name. Falls back to -ConventionPath's value if not specified. Also accepts -Rsl.
    .PARAMETER RandomSuffixSeed
        Seeds -RandomSuffixLength's randomness, so the same seed reproduces the same name every time.
        Also accepts -Rss.
    .PARAMETER ConventionPath
        Path to a JSON file of organizational naming-convention defaults (created with
        New-CafNamingConvention) for -Prefix/-Suffix/-Region/-Separator/-Casing/-InstanceNumberPadding/
        -RandomSuffixLength. Anything also specified explicitly takes precedence over the file.
    .PARAMETER NoClean
        Skip stripping characters that aren't valid for the resource type from -Prefix/-Suffix (the
        generated name will then fail validation if any remain).
    .EXAMPLE
        New-CafResourceName -ResourceType Microsoft.Compute/virtualMachines -Prefix contoso, prod -Suffix 01

        Generates a virtual machine name such as 'contoso-prod-vm-01', returned as an object with Name,
        ResourceType, Resource, Slug, InstanceNumber and RandomSuffix properties.
    .EXAMPLE
        New-CafResourceName -ResourceType KeyVault -Prefix contoso

        -ResourceType matches as a substring, so this is equivalent to specifying the full
        'Microsoft.KeyVault/vaults' ARM type. If a substring matches more than one resource type,
        narrow it down with a longer -ResourceType value and/or -Resource.
    .EXAMPLE
        New-CafResourceName -Alias vmss -Prefix contoso

        If you already know the Cloud Adoption Framework abbreviation, -Alias (or its -Slug alias) is a
        shorter alternative to -ResourceType.
    .EXAMPLE
        New-CafResourceName -Resource 'Key vault' -Prefix contoso

        -Resource alone works too, since every friendly name is unique - a third alternative to
        -ResourceType/-Alias for when you only remember the resource's plain-English name.
    .EXAMPLE
        New-CafResourceName -ResourceType Microsoft.Compute/virtualMachines -Prefix contoso, prod -Region eastus

        Generates 'contoso-prod-vm-eus' - -Region resolves 'eastus' to its CAF-recommended abbreviation
        the same way -ResourceType resolves to its slug, and inserts it after any -Suffix, so -Suffix
        always comes right after the resource type's slug.
    .EXAMPLE
        New-CafResourceName -ResourceType Microsoft.Compute/virtualMachines -Prefix Contoso, Prod -Casing Upper

        Generates 'CONTOSO-PROD-VM' - -Casing re-cases every segment, including the resource type's
        own 'vm' slug, without needing to retype -Prefix/-Suffix in a particular case. The returned
        Slug property still reports the canonical 'vm', regardless of -Casing.
    .EXAMPLE
        New-CafResourceName -ResourceType Microsoft.Compute/virtualMachines -Prefix contoso, prod -InstanceNumber 1

        Generates 'contoso-prod-vm-001' - -InstanceNumber is zero-padded to 3 digits by default, matching
        the Cloud Adoption Framework's own example names such as 'vm-sql-test-001'.
    .EXAMPLE
        New-CafResourceName -ResourceType Microsoft.Compute/virtualMachines -Prefix contoso, prod -Count 3

        Generates 'contoso-prod-vm-001', 'contoso-prod-vm-002' and 'contoso-prod-vm-003' in one call.
    .EXAMPLE
        New-CafResourceName -ResourceType Microsoft.Storage/storageAccounts -Prefix contoso -RandomSuffixLength 6

        Generates a storage account name such as 'contosostabcdef', with 6 random characters appended to
        help ensure the globally-unique name doesn't collide with one that already exists.
    .EXAMPLE
        New-CafResourceName -ResourceType Microsoft.Storage/storageAccounts -Prefix contoso -RandomSuffixLength 6 -RandomSuffixSeed 42

        Generates the same storage account name every time it's run, since the random suffix is seeded.
    .EXAMPLE
        New-CafResourceName -ResourceType Microsoft.Web/sites -Resource 'Function app' -Prefix contoso, prod

        Generates a function app name. -Resource is required here because 'Microsoft.Web/sites' is also
        used for web apps, which use a different abbreviation.
    .EXAMPLE
        New-CafResourceName -ResourceType Microsoft.Web/sites -Alias func -Prefix contoso, prod

        Equivalent to the previous example - -Alias disambiguates 'Microsoft.Web/sites' just like
        -Resource does, if you already know the abbreviation rather than the friendly name.
    .EXAMPLE
        Get-CafResourceType -Slug kv | New-CafResourceName -Prefix contoso -RandomSuffixLength 4

        Pipes the resource type definition for the 'kv' (Key Vault) abbreviation straight into
        New-CafResourceName.
    .EXAMPLE
        New-CafResourceName -ResourceType Microsoft.Compute/virtualMachines -Prefix contoso -ConventionPath ./contoso.json

        Uses -Prefix explicitly, but falls back to whatever -Suffix/-Region/-Separator/etc. are saved in
        contoso.json (see New-CafNamingConvention) for anything not specified here.
    .EXAMPLE
        Import-Csv ./resources.csv | New-CafResourceName | Export-Csv ./generated-names.csv

        Batch-generates a name for every row of resources.csv, which needs at least a ResourceType or
        Alias column, and may also have Resource/Prefix/Suffix/Separator/InstanceNumber columns. The
        ResourceType/Resource/Slug/InstanceNumber/RandomSuffix that produced each name is kept alongside
        it, rather than returning bare strings that lose track of which input row (or which -Count
        iteration) each one came from.
    .LINK
        https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = 'Pure in-memory name generator - the New verb reflects that it returns a new result object (as opposed to Get-CafResourceName''s plain string), not that it changes any external state.')]
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
        $Region,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string]
        $Separator = '-',

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateSet('None', 'Lower', 'Upper', 'Title')]
        [string]
        $Casing = 'None',

        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('In')]
        [ValidateRange(0, [int]::MaxValue)]
        [int]
        $InstanceNumber,

        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('Inp')]
        [ValidateRange(1, 10)]
        [int]
        $InstanceNumberPadding = 3,

        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateRange(1, 1000)]
        [int]
        $Count = 1,

        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('Rsl')]
        [ValidateRange(0, 24)]
        [int]
        $RandomSuffixLength = 0,

        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('Rss')]
        [int]
        $RandomSuffixSeed,

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

        function Get-CasedString {
            param (
                [string[]]$InputObject,
                [string]$Casing
            )

            foreach ($Str in $InputObject) {
                switch ($Casing) {
                    'Lower' { $Str.ToLower() }
                    'Upper' { $Str.ToUpper() }
                    # Lowercased first so an all-caps segment (e.g. 'NYC') isn't left alone as a
                    # presumed acronym - .NET's ToTitleCase skips re-casing words that are already
                    # all-uppercase.
                    'Title' { (Get-Culture).TextInfo.ToTitleCase($Str.ToLower()) }
                    default { $Str }
                }
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

        $EffectiveRegion = if ($PSBoundParameters.ContainsKey('Region')) { $Region } else { $Convention.Region }

        if ($EffectiveRegion) {
            $RegionDefinition = Resolve-CafRegion -Region $EffectiveRegion

            if (-not $RegionDefinition) {
                return
            }

            Write-Verbose "Resolved region '$EffectiveRegion' to '$($RegionDefinition.Region)' (slug '$($RegionDefinition.Slug)')."
            $EffectiveRegionSlug = $RegionDefinition.Slug
        }

        $EffectiveSeparator = if ($PSBoundParameters.ContainsKey('Separator')) { $Separator } elseif ($null -ne $Convention.Separator) { $Convention.Separator } else { $Separator }
        $EffectiveCasing = if ($PSBoundParameters.ContainsKey('Casing')) { $Casing } elseif ($Convention.Casing) { $Convention.Casing } else { $Casing }
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

        if ($EffectiveCasing -notin 'None', 'Lower', 'Upper', 'Title') {
            Write-Error "Casing from the naming convention must be one of 'None', 'Lower', 'Upper' or 'Title', but was '$EffectiveCasing'."
            return
        }

        if ($NoClean) {
            $CleanPrefix = $EffectivePrefix
            $CleanSuffix = $EffectiveSuffix
            $CleanRegionSlug = $EffectiveRegionSlug
        }
        else {
            $CleanPrefix = Get-CleanString -InputObject $EffectivePrefix -Pattern $definition.InvalidCharsRegex
            $CleanSuffix = Get-CleanString -InputObject $EffectiveSuffix -Pattern $definition.InvalidCharsRegex
            $CleanRegionSlug = Get-CleanString -InputObject $EffectiveRegionSlug -Pattern $definition.InvalidCharsRegex
        }

        # $CasedSlug is kept separate from $definition.Slug (used as-is for the returned Slug property
        # and in error/verbose messages) so casing only affects the composed Name, not the canonical
        # CAF abbreviation callers can use to cross-reference Get-CafResourceType.
        $CasedSlug = $definition.Slug

        if ($EffectiveCasing -ne 'None') {
            $CleanPrefix = Get-CasedString -InputObject $CleanPrefix -Casing $EffectiveCasing
            $CleanSuffix = Get-CasedString -InputObject $CleanSuffix -Casing $EffectiveCasing
            $CleanRegionSlug = Get-CasedString -InputObject $CleanRegionSlug -Casing $EffectiveCasing
            $CasedSlug = Get-CasedString -InputObject $CasedSlug -Casing $EffectiveCasing
        }

        $ActualSeparator = if ($definition.Dashes) { $EffectiveSeparator } else { '' }

        $HasInstanceNumber = $PSBoundParameters.ContainsKey('InstanceNumber') -or $Count -gt 1
        $StartInstanceNumber = if ($PSBoundParameters.ContainsKey('InstanceNumber')) { $InstanceNumber } else { 1 }
        $EndInstanceNumber = $StartInstanceNumber + $Count - 1

        # Reserve space based on the longest instance number in the sequence, so the trimmed base name
        # (prefix/slug/region/suffix) is the same length for every generated name, not just the first one.
        $InstanceSegment = if ($HasInstanceNumber) { $EndInstanceNumber.ToString().PadLeft($EffectiveInstanceNumberPadding, '0') } else { $null }

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
            Write-Verbose "Reserving $reservedLength character(s) for $($reservedDescriptions -join ' and '); $mainBudget of $($definition.MaxLength) remain for the prefix/slug/region/suffix."
        }
        else {
            Write-Verbose "No reserved segments; the full $mainBudget character limit is available for the prefix/slug/region/suffix."
        }

        if ($mainBudget -lt $definition.Slug.Length) {
            Write-Error "Not enough room within the $($definition.MaxLength) character limit for $($definition.ResourceType): '$($definition.Slug)' needs $($definition.Slug.Length) characters, but only $mainBudget are available after reserving space for $($reservedDescriptions -join ' and ')."
            return
        }

        $resourceArr = @($CleanPrefix) + @($CasedSlug) + @($CleanSuffix) + @($CleanRegionSlug) | Where-Object { $_ }

        $resourceName = $resourceArr -join $ActualSeparator
        Write-Verbose "Joined '$($resourceArr -join "', '")' with separator '$ActualSeparator' -> '$resourceName' ($($resourceName.Length) characters)."

        if ($resourceName.Length -gt $mainBudget) {
            $beforeTrimLength = $resourceName.Length
            $resourceName = $resourceName.Substring(0, $mainBudget)
            $reservedNote = if ($reservedDescriptions.Count -gt 0) { " (after reserving space for $($reservedDescriptions -join ' and '))" } else { '' }
            Write-Warning "Resource name has been trimmed to $mainBudget characters due to the $($definition.MaxLength) character max length restriction$reservedNote."
            Write-Verbose "Trimmed from $beforeTrimLength to $mainBudget characters -> '$resourceName'."
        }

        # A single shared Random, created once per pipeline item rather than per generated name, so a
        # -RandomSuffixSeed produces a reproducible sequence of distinct suffixes across the whole -Count batch.
        $Random = if ($EffectiveRandomSuffixLength -gt 0) {
            if ($PSBoundParameters.ContainsKey('RandomSuffixSeed')) { [System.Random]::new($RandomSuffixSeed) } else { [System.Random]::new() }
        }
        else {
            $null
        }
        $CharPool = 'abcdefghijklmnopqrstuvwxyz0123456789'

        for ($InstanceCounter = $StartInstanceNumber; $InstanceCounter -le $EndInstanceNumber; $InstanceCounter++) {
            $FinalName = $resourceName

            if ($HasInstanceNumber) {
                $CurrentInstanceSegment = $InstanceCounter.ToString().PadLeft($EffectiveInstanceNumberPadding, '0')
                $FinalName = $FinalName + $ActualSeparator + $CurrentInstanceSegment
                Write-Verbose "Appended instance segment '$CurrentInstanceSegment' -> '$FinalName'."
            }

            if ($EffectiveRandomSuffixLength -gt 0) {
                # Always lowercase alphanumeric, even for resource types that allow uppercase - the
                # random suffix exists for uniqueness, not communication, and 36^RandomSuffixLength is
                # already far more entropy than a uniqueness suffix needs.
                $RandomSuffix = -join (1..$EffectiveRandomSuffixLength | ForEach-Object { $CharPool[$Random.Next($CharPool.Length)] })
                $FinalName = $FinalName + $ActualSeparator + $RandomSuffix
                Write-Verbose "Appended random suffix '$RandomSuffix' -> '$FinalName'."
            }

            if ($definition.Lowercase -and $FinalName -cmatch '[A-Z]') {
                $FinalName = $FinalName.ToLower()
                Write-Warning 'Resource name has been converted to lower case due to naming requirement.'
                Write-Verbose "Converted to lowercase -> '$FinalName'."
            }

            if ($FinalName -notmatch $definition.ValidationRegex) {
                Write-Error "The generated name '$FinalName' is not valid for $($definition.ResourceType) (pattern: $($definition.ValidationRegex))."
            }
            else {
                Write-Verbose "Final result: '$FinalName'."
                [pscustomobject]@{
                    Name           = $FinalName
                    ResourceType   = $definition.ResourceType
                    Resource       = $definition.Resource
                    Slug           = $definition.Slug
                    InstanceNumber = if ($HasInstanceNumber) { $InstanceCounter } else { $null }
                    RandomSuffix   = if ($EffectiveRandomSuffixLength -gt 0) { $RandomSuffix } else { $null }
                }
            }
        }
    }
}
