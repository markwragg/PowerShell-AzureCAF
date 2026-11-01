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
Writes the ResourceType/Resource/Slug/Scope/length/casing fields returned by Get-CafResourceType to
a file, as a reference table a team can review without running PowerShell - e.g.
to print, link
from a wiki page, or attach to a design doc.
The format is chosen from -Path's extension: .csv
or .md (.markdown also works).

Accepts the same objects Get-CafResourceType returns on the pipeline, so you can export a filtered
subset; with nothing piped in, it exports every resource type the module knows about.

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

