# Export-CafResourceType

## SYNOPSIS
Exports the Cloud Adoption Framework naming rules for one or more resource types to a CSV or
Markdown file.

## SYNTAX

```
Export-CafResourceType [-Path] <String> [-InputObject <Object[]>] [-Force] [-ProgressAction <ActionPreference>]
 [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Writes the ResourceType/Resource/Slug/TerraformResourceType/Scope/length/casing fields from
Get-CafResourceType to a CSV or Markdown file (format chosen from -Path's extension), as a
reference table to share outside PowerShell.
Accepts the same objects on the pipeline to export
a filtered subset; defaults to every resource type if nothing is piped in.
TerraformResourceType
is joined with '; ' in the export when a resource type has more than one real azurerm
equivalent (e.g.
a VM's Linux/Windows variants), since neither CSV nor Markdown cells hold a
list natively.

## EXAMPLES

### EXAMPLE 1
```
Export-CafResourceType -Path ./resource-types.md
```

Writes a Markdown table of every resource type the module knows about.

### EXAMPLE 2
```
Get-CafResourceType -ResourceType *storage* | Export-CafResourceType -Path ./storage-types.csv
```

Exports just the storage-related resource types to CSV.

## PARAMETERS

### -Path
Where to write the export.
Must end in .csv, .md or .markdown.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -InputObject
Resource type definitions to export, as returned by Get-CafResourceType.
Defaults to every
resource type the module knows about (equivalent to piping in \`Get-CafResourceType\`) if nothing is
supplied.

```yaml
Type: Object[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Force
Overwrite -Path if it already exists.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

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

