# Get-CafRegion

## SYNOPSIS
Looks up the abbreviation for one or more Azure regions.

## SYNTAX

```
Get-CafRegion [[-Region] <String>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Searches the module's bundled regionDefinition.json and returns the abbreviation
Get-CafResourceName's -Region resolves to (e.g.
'eastus' -\> 'eus'), along with its Azure-paired
region if it has one.
A local, offline lookup against static data - not a replacement for
Get-AzLocation, which reports live region availability from Azure.

Abbreviations aren't officially published by Microsoft for every region, so coverage may lag
newly-announced ones.
PairedRegion is informational only ($null where a region has moved to
availability zones instead) - -Region doesn't resolve against it.

## EXAMPLES

### EXAMPLE 1
```
Get-CafRegion -Region eastus
```

Returns the 'eus' abbreviation for East US, along with its paired region, 'westus'.

### EXAMPLE 2
```
Get-CafRegion -Region 'East US'
```

Looks up the same region by its display name instead of its ARM name.

### EXAMPLE 3
```
Get-CafRegion -Region eus
```

Looks up the same region by its slug instead.

### EXAMPLE 4
```
Get-CafRegion
```

Lists every region known to the module.

## PARAMETERS

### -Region
The ARM region name (e.g.
'eastus'), display name (e.g.
'East US') or CAF slug (e.g.
'eus') to
search for.
The name/display name match as a substring; the slug matches exactly only, since
partial matching on it would mostly just be ambiguous.
If omitted, every region is returned.

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

[https://www.jlaundry.nz/2022/azure_region_abbreviations/](https://www.jlaundry.nz/2022/azure_region_abbreviations/)

