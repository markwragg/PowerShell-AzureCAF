# Get-CafRegion

## SYNOPSIS
Looks up the abbreviation for one or more Azure regions.

## SYNTAX

```
Get-CafRegion [[-Region] <String>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Searches the module's bundled regionDefinition.json for Azure regions and returns the short
abbreviation Get-CafResourceName's -Region parameter resolves it to (e.g.
'eastus' -\> 'eus').

This is a local, offline lookup against a static data set bundled with the module - it's not a
replacement for Get-AzLocation (from the Az.Resources module), which calls the live Azure
Resource Manager API to report which regions are available to a subscription right now.

Region abbreviations aren't officially published by Microsoft for every region - the bundled
list is sourced from https://www.jlaundry.nz/2022/azure_region_abbreviations/, a community
reference, and may not cover newly-announced regions.

## EXAMPLES

### EXAMPLE 1
```
Get-CafRegion -Region eastus
```

Returns the 'eus' abbreviation for East US.

### EXAMPLE 2
```
Get-CafRegion -Region 'East US'
```

Looks up the same region by its display name instead of its ARM name.

### EXAMPLE 3
```
Get-CafRegion
```

Lists every region known to the module.

## PARAMETERS

### -Region
The ARM region name to search for, e.g.
'eastus', or its display name, e.g.
'East US'.
Matches
as a substring by default, same as -ResourceType on Get-CafResourceType, so 'east' alone matches
multiple regions.
If omitted, every known region is returned.

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

