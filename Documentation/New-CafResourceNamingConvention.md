# New-CafResourceNamingConvention

## SYNOPSIS
Saves a reusable set of Get-CafResourceName defaults (prefix, suffix, separator, etc.) to a JSON
file, so your organization's naming convention doesn't need to be retyped on every call.

## SYNTAX

```
New-CafResourceNamingConvention [-Path] <String> [-Prefix <String[]>] [-Suffix <String[]>]
 [-Separator <String>] [-InstanceNumberPadding <Int32>] [-RandomSuffixLength <Int32>] [-Force]
 [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Writes a small JSON file that Get-CafResourceName's -ConventionPath reads defaults from for
-Prefix, -Suffix, -Separator, -InstanceNumberPadding and -RandomSuffixLength.
Anything you pass
explicitly to Get-CafResourceName still takes precedence over the file - this is just a way to
avoid repeating the same organization-standard values (company name, environment, region, your
preferred separator/padding) on every call.

## EXAMPLES

### EXAMPLE 1
```
New-CafResourceNamingConvention -Path ./contoso.json -Prefix contoso, prod -Separator '-' -InstanceNumberPadding 2
```

Saves a convention so that Get-CafResourceName -ConventionPath ./contoso.json applies that prefix,
separator and padding by default.

### EXAMPLE 2
```
Get-CafResourceName -ResourceType Microsoft.Compute/virtualMachines -ConventionPath ./contoso.json -InstanceNumber 1
```

Uses the saved convention, overriding only -InstanceNumber for this particular call.

## PARAMETERS

### -Path
Where to save the convention file, e.g.
'./contoso.json'.

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

### -Prefix
One or more strings to use as the default -Prefix, e.g.
a company name, environment, or region -
see the naming components guide this links to for what's commonly included.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Suffix
One or more strings to use as the default -Suffix.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Separator
The default -Separator.
Omit to leave this to Get-CafResourceName's own default ('-').

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

### -InstanceNumberPadding
The default -InstanceNumberPadding.
Omit to leave this to Get-CafResourceName's own default (3).

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
Accept wildcard characters: False
```

### -RandomSuffixLength
The default -RandomSuffixLength.
Omit to leave this to Get-CafResourceName's own default (0, i.e.
no random suffix unless a call asks for one explicitly).

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: False
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

[https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming#choose-naming-components](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming#choose-naming-components)

