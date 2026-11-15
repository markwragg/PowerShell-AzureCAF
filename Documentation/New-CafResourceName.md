# New-CafResourceName

## SYNOPSIS
Generates an Azure resource name that follows the Cloud Adoption Framework naming convention,
returning the full result as an object.

## SYNTAX

```
New-CafResourceName [[-ResourceType] <String>] [-Alias <String>] [-Resource <String>]
 [-TerraformResourceType <String>] [-Prefix <String[]>] [-Suffix <String[]>] [-Region <String>]
 [-Separator <String>] [-Casing <String>] [-InstanceNumber <Int32>] [-InstanceNumberPadding <Int32>]
 [-Count <Int32>] [-RandomSuffixLength <Int32>] [-RandomSuffixSeed <Int32>] [-ConventionPath <String>]
 [-NoClean] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Builds a resource name from an optional prefix, the CAF-recommended abbreviation for the given
Azure resource type, and an optional suffix - trimmed, cleaned and cased to fit that resource
type's length limit, allowed characters and casing rules.

Returns an object with Name, ResourceType, Resource, Slug, TerraformResourceType, InstanceNumber
and RandomSuffix properties - use Get-CafResourceName instead for just the name as a plain
string.
Accepts
pipeline input by property name, so a list of resource specs (e.g.
from a CSV) can be batch-
generated in one call - see the pipeline example below.
Use Get-CafResourceType to discover the
accepted ResourceType/Resource values, and -Verbose to see the length-budget reasoning behind a
result.

## EXAMPLES

### EXAMPLE 1
```
New-CafResourceName -ResourceType Microsoft.Compute/virtualMachines -Prefix contoso, prod -Suffix 01
```

Generates a virtual machine name such as 'contoso-prod-vm-01', returned as an object with Name,
ResourceType, Resource, Slug, TerraformResourceType, InstanceNumber and RandomSuffix properties.

### EXAMPLE 2
```
New-CafResourceName -ResourceType KeyVault -Prefix contoso
```

-ResourceType matches as a substring, so this is equivalent to specifying the full
'Microsoft.KeyVault/vaults' ARM type.
If a substring matches more than one resource type,
narrow it down with a longer -ResourceType value and/or -Resource.

### EXAMPLE 3
```
New-CafResourceName -Alias vmss -Prefix contoso
```

If you already know the Cloud Adoption Framework abbreviation, -Alias (or its -Slug alias) is a
shorter alternative to -ResourceType.

### EXAMPLE 4
```
New-CafResourceName -Resource 'Key vault' -Prefix contoso
```

-Resource alone works too, since every friendly name is unique - a third alternative to
-ResourceType/-Alias for when you only remember the resource's plain-English name.

### EXAMPLE 5
```
New-CafResourceName -TerraformResourceType azurerm_storage_account -Prefix contoso -RandomSuffixLength 6
```

Generates a storage account name identified by its Terraform resource type instead of its ARM
type, alias or friendly name - a fourth alternative to -ResourceType/-Alias/-Resource.

### EXAMPLE 6
```
New-CafResourceName -ResourceType Microsoft.Compute/virtualMachines -Prefix contoso, prod -Region eastus
```

Generates 'contoso-prod-vm-eus' - -Region resolves 'eastus' to its CAF-recommended abbreviation
the same way -ResourceType resolves to its slug, and inserts it after any -Suffix, so -Suffix
always comes right after the resource type's slug.

### EXAMPLE 7
```
New-CafResourceName -ResourceType Microsoft.Compute/virtualMachines -Prefix Contoso, Prod -Casing Upper
```

Generates 'CONTOSO-PROD-VM' - -Casing re-cases every segment, including the resource type's
own 'vm' slug, without needing to retype -Prefix/-Suffix in a particular case.
The returned
Slug property still reports the canonical 'vm', regardless of -Casing.

### EXAMPLE 8
```
New-CafResourceName -ResourceType Microsoft.Compute/virtualMachines -Prefix contoso, prod -InstanceNumber 1
```

Generates 'contoso-prod-vm-001' - -InstanceNumber is zero-padded to 3 digits by default, matching
the Cloud Adoption Framework's own example names such as 'vm-sql-test-001'.

### EXAMPLE 9
```
New-CafResourceName -ResourceType Microsoft.Compute/virtualMachines -Prefix contoso, prod -Count 3
```

Generates 'contoso-prod-vm-001', 'contoso-prod-vm-002' and 'contoso-prod-vm-003' in one call.

### EXAMPLE 10
```
New-CafResourceName -ResourceType Microsoft.Storage/storageAccounts -Prefix contoso -RandomSuffixLength 6
```

Generates a storage account name such as 'contosostabcdef', with 6 random characters appended to
help ensure the globally-unique name doesn't collide with one that already exists.

### EXAMPLE 11
```
New-CafResourceName -ResourceType Microsoft.Storage/storageAccounts -Prefix contoso -RandomSuffixLength 6 -RandomSuffixSeed 42
```

Generates the same storage account name every time it's run, since the random suffix is seeded.

### EXAMPLE 12
```
New-CafResourceName -ResourceType Microsoft.Web/sites -Resource 'Function app' -Prefix contoso, prod
```

Generates a function app name.
-Resource is required here because 'Microsoft.Web/sites' is also
used for web apps, which use a different abbreviation.

### EXAMPLE 13
```
New-CafResourceName -ResourceType Microsoft.Web/sites -Alias func -Prefix contoso, prod
```

Equivalent to the previous example - -Alias disambiguates 'Microsoft.Web/sites' just like
-Resource does, if you already know the abbreviation rather than the friendly name.

### EXAMPLE 14
```
Get-CafResourceType -Slug kv | New-CafResourceName -Prefix contoso -RandomSuffixLength 4
```

Pipes the resource type definition for the 'kv' (Key Vault) abbreviation straight into
New-CafResourceName.

### EXAMPLE 15
```
New-CafResourceName -ResourceType Microsoft.Compute/virtualMachines -Prefix contoso -ConventionPath ./contoso.json
```

Uses -Prefix explicitly, but falls back to whatever -Suffix/-Region/-Separator/etc.
are saved in
contoso.json (see New-CafNamingConvention) for anything not specified here.

### EXAMPLE 16
```
Import-Csv ./resources.csv | New-CafResourceName | Export-Csv ./generated-names.csv
```

Batch-generates a name for every row of resources.csv, which needs at least a ResourceType,
Alias or TerraformResourceType column, and may also have Resource/Prefix/Suffix/Separator/
InstanceNumber columns.
The ResourceType/Resource/Slug/TerraformResourceType/InstanceNumber/
RandomSuffix that produced each name is kept alongside it, rather than returning bare strings
that lose track of which input row (or which -Count
iteration) each one came from.

## PARAMETERS

### -ResourceType
The ARM resource type to generate a name for, e.g.
'Microsoft.Compute/virtualMachines'.
Matches
as a substring; use -Resource to disambiguate if needed.
Tab-completable, and takes precedence
over -Alias/-Resource if more than one is specified.

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
The CAF abbreviation to generate a name for, e.g.
'vmss' - a shorter alternative to
-ResourceType (also accepts -Slug).
Can also disambiguate an ambiguous -ResourceType, the same
way -Resource does.

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
The resource's friendly name, e.g.
'Key vault' - a third alternative to -ResourceType/-Alias.
Required alongside either when an ARM type covers more than one kind of resource, e.g.
'Microsoft.Web/sites' (Web app vs Function app).

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

### -TerraformResourceType
The Terraform azurerm resource type to generate a name for, e.g.
'azurerm_storage_account' - a
fourth alternative to -ResourceType/-Alias/-Resource.
A resource type with more than one
current real azurerm equivalent (e.g.
a virtual machine's Linux/Windows variants) resolves from
either one; $null for resource types Terraform doesn't model distinctly.
Use Get-CafResourceType
to check coverage.

```yaml
Type: String
Parameter Sets: (All)
Aliases: Tf

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Prefix
One or more strings to prepend to the resource name, in order.
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
An Azure region (ARM name, display name or CAF slug, e.g.
'eastus'/'East US'/'eus') to resolve
and append after any -Suffix.
Falls back to -ConventionPath's value if not specified.
Use
Get-CafRegion to look up supported regions.

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
The character(s) used to join the prefix/slug/suffix segments.
Ignored for resource types that
don't permit one.
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

### -Casing
Re-cases every segment of the generated name - -Prefix/-Suffix, the slug and -Region: 'Lower',
'Upper' or 'Title'.
Defaults to 'None', or to -ConventionPath's value.
Overridden by a resource
type that requires an all-lowercase name.
Doesn't affect the returned object's Slug property,
which always reports the canonical CAF abbreviation.

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

### -InstanceNumber
An instance number to append, for differentiating otherwise-identical resources (e.g.
'vm-sql-test-001').
Zero-padded to -InstanceNumberPadding digits.
Also accepts -In.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases: In

Required: False
Position: Named
Default value: 0
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -InstanceNumberPadding
Minimum digits to zero-pad -InstanceNumber to (default 3).
Falls back to -ConventionPath's
value if not specified.
Also accepts -Inp.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases: Inp

Required: False
Position: Named
Default value: 3
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Count
Generates this many names in one call, with sequential instance numbers starting from
-InstanceNumber (or 1).
Each name gets its own random suffix if -RandomSuffixLength is used.

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
Appends this many random lowercase alphanumeric characters, for resource types that need a
globally-unique name.
Falls back to -ConventionPath's value if not specified.
Also accepts -Rsl.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases: Rsl

Required: False
Position: Named
Default value: 0
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -RandomSuffixSeed
Seeds -RandomSuffixLength's randomness, so the same seed reproduces the same name every time.
Also accepts -Rss.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases: Rss

Required: False
Position: Named
Default value: 0
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -ConventionPath
Path to a JSON file of organizational naming-convention defaults (created with
New-CafNamingConvention) for -Prefix/-Suffix/-Region/-Separator/-Casing/-InstanceNumberPadding/
-RandomSuffixLength.
Anything also specified explicitly takes precedence over the file.

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
Skip stripping characters that aren't valid for the resource type from -Prefix/-Suffix (the
generated name will then fail validation if any remain).

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
{{Fill ProgressAction Description}}

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
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS

[https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations)

