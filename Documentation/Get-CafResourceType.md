# Get-CafResourceType

## SYNOPSIS
Looks up the Cloud Adoption Framework naming rules for one or more Azure resource types.

## SYNTAX

```
Get-CafResourceType [[-ResourceType] <String>] [-Resource <String>] [-Alias <String>]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Searches the module's bundled resourceDefinition.json for Azure resource types and returns their
recommended CAF abbreviation along with the naming scope, length limits and casing rules that
Get-CafResourceName uses to build a compliant name.

This is a local, offline lookup against a static data set bundled with the module.
It's not a
replacement for Get-AzResourceProvider (from the Az.Resources module): that cmdlet calls the live
Azure Resource Manager API to report which resource providers/types are registered and available
in a subscription, and requires being signed in to Azure.
Get-CafResourceType has no dependency on
Az.Resources or an Azure session - it only answers "what's the recommended naming convention for
this resource type", not "is this resource type available to me right now".

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
substring by default, e.g.
'virtualMachines' or 'compute' both match it too - pass an explicit
wildcard pattern (e.g.
'Microsoft.Compute/*') for tighter control, such as anchoring to the
start.
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
Matches as a substring by
default, same as -ResourceType.
Useful to disambiguate ARM resource types that cover more than
one kind of resource (for example 'Microsoft.Compute/disks' covers both a "Managed disk (OS)"
and a "Managed disk (data)").

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
The Cloud Adoption Framework abbreviation to search for, e.g.
'vm', used as a short alias for
the ARM resource type.
Matches as a substring by default, same as -ResourceType/-Resource, and
also accepts -Slug as an alias.

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

