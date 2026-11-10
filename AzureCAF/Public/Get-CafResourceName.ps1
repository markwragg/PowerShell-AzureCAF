function Get-CafResourceName {
    <#
    .SYNOPSIS
        Generates an Azure resource name that follows the Cloud Adoption Framework naming convention,
        returning just the name as a string.
    .DESCRIPTION
        A thin wrapper around New-CafResourceName that returns just the generated Name string, for
        callers who don't need the ResourceType/Resource/Slug/InstanceNumber/RandomSuffix that produced
        it - every parameter here behaves exactly as it does there; see its help for the full
        length-budget/trimming/cleaning/-ConventionPath behaviour. Use New-CafResourceName directly
        instead if you need to trace which input produced which name, e.g. when batch-generating.
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
        type that requires an all-lowercase name.
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
        Get-CafResourceName -ResourceType Microsoft.Compute/virtualMachines -Prefix contoso, prod -Region eastus

        Generates 'contoso-prod-vm-eus' - -Region resolves 'eastus' to its CAF-recommended abbreviation
        the same way -ResourceType resolves to its slug, and inserts it after any -Suffix, so -Suffix
        always comes right after the resource type's slug.
    .EXAMPLE
        Get-CafResourceName -ResourceType Microsoft.Compute/virtualMachines -Prefix Contoso, Prod -Casing Upper

        Generates 'CONTOSO-PROD-VM' - -Casing re-cases every segment, including the resource type's
        own 'vm' slug, without needing to retype -Prefix/-Suffix in a particular case.
    .EXAMPLE
        Get-CafResourceName -ResourceType Microsoft.Compute/virtualMachines -Prefix contoso, prod -InstanceNumber 1

        Generates 'contoso-prod-vm-001' - -InstanceNumber is zero-padded to 3 digits by default, matching
        the Cloud Adoption Framework's own example names such as 'vm-sql-test-001'.
    .EXAMPLE
        Get-CafResourceName -ResourceType Microsoft.Compute/virtualMachines -Prefix contoso, prod -Count 3

        Generates 'contoso-prod-vm-001', 'contoso-prod-vm-002' and 'contoso-prod-vm-003' in one call.
    .EXAMPLE
        Get-CafResourceName -ResourceType Microsoft.Storage/storageAccounts -Prefix contoso -RandomSuffixLength 6

        Generates a storage account name such as 'contosostabcdef', with 6 random characters appended to
        help ensure the globally-unique name doesn't collide with one that already exists.
    .EXAMPLE
        Get-CafResourceName -ResourceType Microsoft.Storage/storageAccounts -Prefix contoso -RandomSuffixLength 6 -RandomSuffixSeed 42

        Generates the same storage account name every time it's run, since the random suffix is seeded.
    .EXAMPLE
        Get-CafResourceName -ResourceType Microsoft.Web/sites -Resource 'Function app' -Prefix contoso, prod

        Generates a function app name. -Resource is required here because 'Microsoft.Web/sites' is also
        used for web apps, which use a different abbreviation.
    .EXAMPLE
        Get-CafResourceName -ResourceType Microsoft.Web/sites -Alias func -Prefix contoso, prod

        Equivalent to the previous example - -Alias disambiguates 'Microsoft.Web/sites' just like
        -Resource does, if you already know the abbreviation rather than the friendly name.
    .EXAMPLE
        Get-CafResourceType -Slug kv | Get-CafResourceName -Prefix contoso -RandomSuffixLength 4

        Pipes the resource type definition for the 'kv' (Key Vault) abbreviation straight into
        Get-CafResourceName.
    .EXAMPLE
        Get-CafResourceName -ResourceType Microsoft.Compute/virtualMachines -Prefix contoso -ConventionPath ./contoso.json

        Uses -Prefix explicitly, but falls back to whatever -Suffix/-Region/-Separator/etc. are saved in
        contoso.json (see New-CafNamingConvention) for anything not specified here.
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
        # Every parameter above exists only to be bound and forwarded to New-CafResourceName via the
        # proxy-command plumbing below (for CmdletBinding/tab-completion/help purposes), never read
        # directly here - this satisfies PSScriptAnalyzer's PSReviewUnusedParameter rule.
        $null = $ResourceType, $Alias, $Resource, $Prefix, $Suffix, $Region, $Separator, $Casing, $InstanceNumber,
        $InstanceNumberPadding, $Count, $RandomSuffixLength, $RandomSuffixSeed, $ConventionPath, $NoClean

        # A hand-rolled `New-CafResourceName @PSBoundParameters` here would be unsafe: $PSBoundParameters
        # keeps stale values from a previous pipeline object once a later object lacks that property (a
        # known PowerShell quirk), which would leak e.g. one row's -Suffix into the next row's call. The
        # proxy-command pattern below instead feeds each pipeline object into New-CafResourceName's own
        # pipeline binding, which rebinds correctly per object.
        $WrappedCommand = $ExecutionContext.InvokeCommand.GetCommand('New-CafResourceName', [System.Management.Automation.CommandTypes]::Function)
        $ScriptCmd = { & $WrappedCommand @PSBoundParameters | ForEach-Object Name }
        $SteppablePipeline = $ScriptCmd.GetSteppablePipeline($MyInvocation.CommandOrigin)
        $SteppablePipeline.Begin($PSCmdlet)
    }

    process {
        $SteppablePipeline.Process($_)
    }

    end {
        $SteppablePipeline.End()
    }
}
