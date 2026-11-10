# Get-CafResourceType

## SYNOPSIS
Looks up the Cloud Adoption Framework naming rules for one or more Azure resource types.

## SYNTAX

```
Get-CafResourceType [[-ResourceType] <String>] [-Resource <String>] [-Alias <String>]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Searches the module's bundled resourceDefinition.json and returns a resource type's recommended
CAF abbreviation, naming scope, length limits and casing rules - the same rules Get-CafResourceName
builds a name against.
A local, offline lookup against static data - not a replacement for
Get-AzResourceProvider, which reports live resource provider availability from Azure.

## EXAMPLES

### EXAMPLE 1
```
Get-CafResourceType -ResourceType Microsoft.Compute/virtualMachines
```

Returns the naming rule for an Azure virtual machine.

### EXAMPLE 2
```
Get-CafResourceType -ResourceType storageAccount
```

Finds resource types whose ARM type contains 'storageAccount'.

### EXAMPLE 3
```
Get-CafResourceType -Alias vm
```

Finds the resource type(s) that use the 'vm' abbreviation.

### EXAMPLE 4
```
Get-CafResourceType
```

Lists every resource type known to the module.

## PARAMETERS

### -ResourceType
The ARM resource type to search for, e.g.
'Microsoft.Compute/virtualMachines'.
Matches as a
substring; pass an explicit wildcard pattern (e.g.
'Microsoft.Compute/*') for tighter control.
If omitted, all resource types are returned (optionally filtered by -Resource/-Alias).

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Resource
The friendly resource name to search for, e.g.
'Virtual machine'.
Matches as a substring.
Useful
to disambiguate ARM resource types that cover more than one kind of resource.

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

### -Alias
The CAF abbreviation to search for, e.g.
'vm'.
Matches as a substring, and also accepts -Slug.

```yaml
Type: String
Parameter Sets: (All)
Aliases: Slug

Required: False
Position: Named
Default value: None
Accept pipeline input: False
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

