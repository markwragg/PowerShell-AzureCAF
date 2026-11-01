# Get-CafResourceName

## SYNOPSIS
Generates an Azure resource name that follows the Cloud Adoption Framework naming convention.

## SYNTAX

```
Get-CafResourceName [[-ResourceType] <String>] [-Alias <String>] [-Resource <String>] [-Prefix <String[]>]
 [-Suffix <String[]>] [-Region <String>] [-Separator <String>] [-InstanceNumber <Int32>]
 [-InstanceNumberPadding <Int32>] [-Count <Int32>] [-RandomSuffixLength <Int32>] [-RandomSuffixSeed <Int32>]
 [-ConventionPath <String>] [-NoClean] [-AsObject] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Builds a resource name from an optional prefix, the Cloud Adoption Framework recommended
abbreviation for the given Azure resource type, and an optional suffix.
The result is checked
against the resource type's length limit and allowed characters, and is trimmed and/or converted
to lowercase automatically if the resource type requires it.

Accepts pipeline input by property name, so a list of resource specs (e.g.
imported from a CSV
or a PSD1 describing a whole deployment) can be piped straight through to generate every name
for a project in one batch - see the pipeline example below.

Use Get-CafResourceType to discover the ResourceType/Resource values this cmdlet accepts.
Use
-Verbose to see the length-budget reasoning (reserved segments, trimming decisions) behind a
given result.

## EXAMPLES

### EXAMPLE 1
```
Get-CafResourceName -ResourceType Microsoft.Compute/virtualMachines -Prefix contoso, prod -Suffix 01
```

Generates a virtual machine name such as 'contoso-prod-vm-01'.

### EXAMPLE 2
```
Get-CafResourceName -ResourceType KeyVault -Prefix contoso
```

-ResourceType matches as a substring, so this is equivalent to specifying the full
'Microsoft.KeyVault/vaults' ARM type.
If a substring matches more than one resource type,
narrow it down with a longer -ResourceType value and/or -Resource.

### EXAMPLE 3
```
Get-CafResourceName -Alias vmss -Prefix contoso
```

If you already know the Cloud Adoption Framework abbreviation, -Alias (or its -Slug alias) is a
shorter alternative to -ResourceType.

### EXAMPLE 4
```
Get-CafResourceName -Resource 'Key vault' -Prefix contoso
```

-Resource alone works too, since every friendly name is unique - a third alternative to
-ResourceType/-Alias for when you only remember the resource's plain-English name.

### EXAMPLE 5
```
Get-CafResourceName -ResourceType Microsoft.Compute/virtualMachines -Prefix contoso, prod -Region eastus
```

Generates 'contoso-prod-vm-eus' - -Region resolves 'eastus' to its CAF-recommended abbreviation
the same way -ResourceType resolves to its slug, and appends it after any -Suffix.

### EXAMPLE 6
```
Get-CafResourceName -ResourceType Microsoft.Compute/virtualMachines -Prefix contoso, prod -InstanceNumber 1
```

Generates 'contoso-prod-vm-001' - -InstanceNumber is zero-padded to 3 digits by default, matching
the Cloud Adoption Framework's own example names such as 'vm-sql-test-001'.

### EXAMPLE 7
```
Get-CafResourceName -ResourceType Microsoft.Compute/virtualMachines -Prefix contoso, prod -Count 3
```

Generates 'contoso-prod-vm-001', 'contoso-prod-vm-002' and 'contoso-prod-vm-003' in one call.

### EXAMPLE 8
```
Get-CafResourceName -ResourceType Microsoft.Storage/storageAccounts -Prefix contoso -RandomSuffixLength 6
```

Generates a storage account name such as 'contosostabcdef', with 6 random characters appended to
help ensure the globally-unique name doesn't collide with one that already exists.

### EXAMPLE 9
```
Get-CafResourceName -ResourceType Microsoft.Storage/storageAccounts -Prefix contoso -RandomSuffixLength 6 -RandomSuffixSeed 42
```

Generates the same storage account name every time it's run, since the random suffix is seeded.

### EXAMPLE 10
```
Get-CafResourceName -ResourceType Microsoft.Web/sites -Resource 'Function app' -Prefix contoso, prod
```

Generates a function app name.
-Resource is required here because 'Microsoft.Web/sites' is also
used for web apps, which use a different abbreviation.

### EXAMPLE 11
```
Get-CafResourceType -Slug kv | Get-CafResourceName -Prefix contoso -RandomSuffixLength 4
```

Pipes the resource type definition for the 'kv' (Key Vault) abbreviation straight into
Get-CafResourceName.

### EXAMPLE 12
```
Get-CafResourceName -ResourceType Microsoft.Compute/virtualMachines -Prefix contoso -ConventionPath ./contoso.json
```

Uses -Prefix explicitly, but falls back to whatever -Suffix/-Region/-Separator/etc.
are saved in
contoso.json (see New-CafNamingConvention) for anything not specified here.

### EXAMPLE 13
```
Import-Csv ./resources.csv | Get-CafResourceName
```

Batch-generates a name for every row of resources.csv, which needs at least a ResourceType or
Alias column, and may also have Resource/Prefix/Suffix/Separator/InstanceNumber columns.

### EXAMPLE 14
```
Import-Csv ./resources.csv | Get-CafResourceName -AsObject | Export-Csv ./generated-names.csv
```

-AsObject keeps the ResourceType/Resource/Slug/InstanceNumber/RandomSuffix that produced each
name alongside it, rather than returning bare strings that lose track of which input row (or
which -Count iteration) each one came from.

## PARAMETERS

### -ResourceType
The ARM resource type to generate a name for, e.g.
'Microsoft.Compute/virtualMachines'.
Matches
as a substring by default, so 'virtualMachines' also works - as long as it narrows down to a
single resource type, or you also specify -Resource.
Tab completion lists the resource types
known to the module.
Normally used on its own (or -Alias, or -Resource, used instead); takes
precedence if more than one happens to be specified, e.g.
by piping in an object that has
ResourceType, Alias and Resource properties all describing the same entry.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Alias
The Cloud Adoption Framework abbreviation to generate a name for, e.g.
'vmss', if you already
know it, used as a short alias for the ARM resource type.
Matches as a substring by default,
same as -ResourceType, and also accepts -Slug as an alias (so piping Get-CafResourceType's output
straight in binds to this by its Slug property).
Normally used on its own, instead of
-ResourceType.

```yaml
Type: String
Parameter Sets: (All)
Aliases: Slug

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Resource
The friendly name of the resource to generate, e.g.
'Key vault' - every such name in the
module's data is unique, so on its own this works as a third alternative to -ResourceType/
-Alias (also matching as a substring, so 'vault' alone works too).
It also doubles as a
disambiguator when combined with -ResourceType/-Alias, for the handful of ARM types used by
more than one kind of resource (for example 'Microsoft.Web/sites' covers both a "Web app" and a
"Function app", with different recommended abbreviations) - required in that case, since
-ResourceType/-Alias alone would otherwise be ambiguous.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Prefix
One or more strings to prepend to the resource name, in order, e.g.
a company name, environment,
or region.
Falls back to -ConventionPath's value if not specified.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Suffix
One or more strings to append to the resource name, in order.
Falls back to -ConventionPath's
value if not specified.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Region
An Azure region to append to the resource name, as its ARM name (e.g.
'eastus'), display name
(e.g.
'East US') or its CAF slug (e.g.
'eus') - resolved to the CAF-recommended abbreviation the
same way -ResourceType resolves to -Slug, and added after any -Suffix.
Already passing the slug
in is a no-op that just confirms it's a recognized one.
Falls back to -ConventionPath's value if
not specified.
Use Get-CafRegion to look up the abbreviation a given region resolves to, or to
see every region the module knows about.
Region abbreviations aren't officially published by
Microsoft for every region, so an unrecognized value errors rather than guessing - pass the code
yourself via -Suffix instead if that happens.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Separator
The character(s) used to join the prefix, abbreviation and suffix segments together.
Ignored for
resource types that don't permit a separator character, in which case the segments are
concatenated directly.
Defaults to '-', or to -ConventionPath's value if it specifies one.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: -
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -InstanceNumber
An instance number to append to the resource name, for differentiating otherwise-identical
resources (e.g.
'vm-sql-test-001', 'vm-sql-test-002' in the Cloud Adoption Framework's own naming
examples).
Zero-padded to -InstanceNumberPadding digits and reserved out of the resource type's
maximum length before the rest of the name is trimmed, so it's never cut short.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -InstanceNumberPadding
The minimum number of digits to zero-pad -InstanceNumber to, e.g.
the default of 3 formats '1'
as '001'.
A number that's already at least this many digits long is left as-is.
Ignored unless
-InstanceNumber is specified.
Falls back to -ConventionPath's value if not specified.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 3
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Count
Generates this many names in one call, with sequential instance numbers, instead of just one.
Starts from -InstanceNumber if specified (e.g.
-InstanceNumber 5 -Count 3 produces 005, 006, 007),
or from 1 otherwise.
Implies an instance number even if -InstanceNumber isn't specified, since
otherwise every generated name would be identical.
Each generated name gets its own random
suffix if -RandomSuffixLength is also specified.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 1
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -RandomSuffixLength
Appends this many random lowercase alphanumeric characters to the end of the name, for
scenarios that require a globally unique name (such as a storage account or key vault).
Always
lowercase, even for a resource type that otherwise allows uppercase - the suffix exists for
uniqueness, not communication, and doesn't need the extra entropy.
The characters are reserved
out of the resource type's maximum length before the rest of the name is trimmed, so the random
suffix is never cut short.
Falls back to -ConventionPath's value if not specified.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -RandomSuffixSeed
Seeds the random number generator used by -RandomSuffixLength, so the same seed (with the same
other parameters) always produces the same random characters - useful if you need to generate
the same name idempotently, e.g.
across repeated deployments.
Ignored unless -RandomSuffixLength
is specified.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -ConventionPath
Path to a JSON file of organizational naming-convention defaults for -Prefix, -Suffix, -Region,
-Separator, -InstanceNumberPadding and -RandomSuffixLength, created with
New-CafNamingConvention.
Any of those you also specify explicitly (including via the
pipeline) take precedence over the file - this just saves retyping the same org-standard values
on every call.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -NoClean
By default, characters that aren't valid for the given resource type are stripped from -Prefix
and -Suffix before the name is built.
Specify -NoClean to pass them through unmodified instead
(the generated name will then fail validation if it contains invalid characters).

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -AsObject
Returns an object with Name, ResourceType, Resource, Slug, InstanceNumber and RandomSuffix
properties instead of just the name string - useful for telling generated names apart when
batch-generating across different resource types and/or -Count, or for exporting the result
(e.g.
to CSV) alongside the values that produced it.
InstanceNumber/RandomSuffix are $null when
-InstanceNumber/-Count or -RandomSuffixLength weren't in play for that name.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -ProgressAction
{{ Fill ProgressAction Description }}

```yaml
Type: ActionPreference
Parameter Sets: (All)
Aliases: proga

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS

[https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations)

