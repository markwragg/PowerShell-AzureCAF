function Export-CafResourceType {
    <#
    .SYNOPSIS
        Exports the Cloud Adoption Framework naming rules for one or more resource types to a CSV or
        Markdown file.
    .DESCRIPTION
        Writes the ResourceType/Resource/Slug/Scope/length/casing fields returned by Get-CafResourceType to
        a file, as a reference table a team can review without running PowerShell - e.g. to print, link
        from a wiki page, or attach to a design doc. The format is chosen from -Path's extension: .csv
        or .md (.markdown also works).

        Accepts the same objects Get-CafResourceType returns on the pipeline, so you can export a filtered
        subset; with nothing piped in, it exports every resource type the module knows about.
    .PARAMETER Path
        Where to write the export. Must end in .csv, .md or .markdown.
    .PARAMETER InputObject
        Resource type definitions to export, as returned by Get-CafResourceType. Defaults to every
        resource type the module knows about (equivalent to piping in `Get-CafResourceType`) if nothing is
        supplied.
    .PARAMETER Force
        Overwrite -Path if it already exists.
    .EXAMPLE
        Export-CafResourceType -Path ./resource-types.md

        Writes a Markdown table of every resource type the module knows about.
    .EXAMPLE
        Get-CafResourceType -ResourceType *storage* | Export-CafResourceType -Path ./storage-types.csv

        Exports just the storage-related resource types to CSV.
    .LINK
        https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Path,

        [Parameter(ValueFromPipeline)]
        [object[]]
        $InputObject,

        [switch]
        $Force
    )

    begin {
        $Items = [System.Collections.Generic.List[object]]::new()
    }

    process {
        foreach ($Item in $InputObject) {
            $Items.Add($Item)
        }
    }

    end {
        $Extension = [System.IO.Path]::GetExtension($Path).ToLowerInvariant()

        if ($Extension -notin '.csv', '.md', '.markdown') {
            Write-Error "'$Path' must end in .csv, .md or .markdown."
            return
        }

        if ($Items.Count -eq 0) {
            $Items.AddRange(@(Get-CafResourceType))
        }

        if ((Test-Path -Path $Path) -and -not $Force) {
            Write-Error "'$Path' already exists. Specify -Force to overwrite it."
            return
        }

        if (-not $PSCmdlet.ShouldProcess($Path, "Export $($Items.Count) resource type(s)")) {
            return
        }

        $Properties = 'ResourceType', 'Resource', 'Slug', 'Scope', 'MinLength', 'MaxLength', 'Lowercase', 'Dashes'

        if ($Extension -eq '.csv') {
            $Items | Select-Object -Property $Properties | Export-Csv -Path $Path -NoTypeInformation
        }
        else {
            $Lines = [System.Collections.Generic.List[string]]::new()
            $Lines.Add("| $($Properties -join ' | ') |")
            $Lines.Add("| $(($Properties | ForEach-Object { '---' }) -join ' | ') |")

            foreach ($Item in $Items) {
                $Cells = foreach ($Property in $Properties) {
                    "$($Item.$Property)".Replace('|', '\|')
                }
                $Lines.Add("| $($Cells -join ' | ') |")
            }

            Set-Content -Path $Path -Value $Lines
        }

        Get-Item -Path $Path
    }
}
