<#
.SYNOPSIS
    Reports on how resourceDefinition.json has drifted from Microsoft's published CAF abbreviation
    guide, so a maintainer can keep the module's resource type coverage current.
.DESCRIPTION
    resourceDefinition.json is a curated, static data file - it is not regenerated automatically,
    because the length/character rules it contains need to be taken from a reliable source
    (currently aztfmod/terraform-provider-azurecaf) rather than guessed at. This script exists to
    find out *what's changed* since the file was last curated:

    - Re-fetches and re-parses the Microsoft Learn "Resource abbreviations" page.
    - Flags scraped resource/type/slug combinations that aren't in resourceDefinition.json yet
      ("new"), separating ones where another entry with the same slug already has naming-rule data
      to copy from, versus ones with no naming-rule data at all (which need the Microsoft Learn
      "Naming rules and restrictions for Azure resources" page consulted by hand - that page is
      free-text prose, not something safe to auto-convert into a validation regex).
    - Flags resourceDefinition.json entries that no longer appear on the Microsoft Learn page
      ("removed/renamed" - needs human review, since a rename can't be told apart from a removal
      automatically).
    - Optionally (-CompareAzResourceProvider) cross-checks live Azure resource provider types
      against the data file's coverage, for finding ARM types Azure now has that aren't in the CAF
      abbreviation guide yet. This needs the Az.Resources module and an active Azure sign-in; it's
      opt-in because the rest of this script has no dependency on either.

    By default resourceDefinition.json is never modified - review the report and update the file by
    hand (or ask an AI assistant to do it from this report), then commit the change. Pass -AutoApply
    to have it apply the subset of changes that are mechanical and don't require human judgement:
    new entries that can borrow naming-rule data from an existing entry with the same slug, and
    slugs that changed upstream for an entry that's otherwise unchanged. New entries with no
    naming-rule data to borrow, and removed/renamed entries, are still only reported - applying
    those automatically risks publishing a guessed-at validation regex or deleting an entry that was
    actually just renamed.
.PARAMETER Path
    Path to the resourceDefinition.json file to report on (and, with -AutoApply, update). Defaults
    to the module's own copy at AzureCAF/resourceDefinition.json.
.PARAMETER AutoApply
    Apply the "new, borrowable" and "slug changed" entries directly to -Path. Entries with no
    naming-rule data to borrow, and removed/renamed entries, are still left for manual review.
.PARAMETER CompareAzResourceProvider
    Also cross-check resourceDefinition.json's ARM type coverage against Get-AzResourceProvider
    -ListAvailable. Requires the Az.Resources module and an active Connect-AzAccount session.
.PARAMETER ReportPath
    Optional path to also write the report to as a text file, in addition to the console.
.EXAMPLE
    ./Build/Update-ResourceDefinition.ps1

    Reports on new/removed resource types compared to the Microsoft Learn abbreviation guide.
.EXAMPLE
    ./Build/Update-ResourceDefinition.ps1 -AutoApply

    Also writes the mechanical subset of changes (borrowable new entries, slug updates) back to
    resourceDefinition.json.
.EXAMPLE
    ./Build/Update-ResourceDefinition.ps1 -CompareAzResourceProvider -ReportPath ./drift-report.txt

    Also cross-checks against live Azure resource provider types, and saves the report to a file.
#>
[CmdletBinding()]
param(
    [string]
    $Path = (Join-Path $PSScriptRoot '..\AzureCAF\resourceDefinition.json'),

    [switch]
    $AutoApply,

    [switch]
    $CompareAzResourceProvider,

    [string]
    $ReportPath
)

$AbbreviationGuideUrl = 'https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations'
$NamingRulesGuideUrl = 'https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules'
$DataFilePath = $Path

function Get-CafAbbreviationTable {
    <#
    .SYNOPSIS
        Scrapes the Resource / Resource provider namespace / Abbreviation table from the Microsoft
        Learn CAF abbreviation guide.
    #>
    param(
        [string]$Uri
    )

    $html = (Invoke-WebRequest -Uri $Uri -UseBasicParsing).Content
    $tableMatches = [regex]::Matches($html, '(?s)<table>.*?</table>')

    foreach ($table in $tableMatches) {
        $rowMatches = [regex]::Matches($table.Value, '(?s)<tr>(.*?)</tr>')
        foreach ($row in $rowMatches) {
            if ($row.Groups[1].Value -match '<th>') { continue }

            $cells = [regex]::Matches($row.Groups[1].Value, '(?s)<td>(.*?)</td>')
            if ($cells.Count -ne 3) {
                Write-Warning "Skipping a row that didn't parse into exactly 3 columns: $($row.Value)"
                continue
            }

            # The ARM type cell sometimes carries a trailing qualifier, e.g.
            # 'Microsoft.CognitiveServices/accounts (kind: ComputerVision)' - that's not part of the
            # actual ARM type, so it's split off here rather than left baked into ArmType (which would
            # make ArmType an invalid/unusable value for Get-CafResourceName's -ResourceType). The
            # qualifier is kept alongside for a human reviewer to see, since it's still useful context
            # for telling kinds/modes of the same base type apart - it's just not part of the type name.
            $RawArmType = [System.Net.WebUtility]::HtmlDecode(($cells[1].Groups[1].Value -replace '<[^>]+>', '').Trim())
            $ArmType = $RawArmType
            $Qualifier = $null
            if ($RawArmType -match '^(?<Type>.*?)\s*\((?<Qualifier>(?:kind|mode):[^)]*)\)\.?\s*$') {
                $ArmType = $matches.Type
                $Qualifier = $matches.Qualifier
            }

            [pscustomobject]@{
                Resource  = [System.Net.WebUtility]::HtmlDecode(($cells[0].Groups[1].Value -replace '<[^>]+>', '').Trim())
                ArmType   = $ArmType
                Qualifier = $Qualifier
                Slug      = [System.Net.WebUtility]::HtmlDecode(($cells[2].Groups[1].Value -replace '<[^>]+>', '').Trim())
            }
        }
    }
}

Write-Output "Fetching $AbbreviationGuideUrl ..."
$scraped = @(Get-CafAbbreviationTable -Uri $AbbreviationGuideUrl)
Write-Output "Parsed $($scraped.Count) resource rows.`n"

$existing = @(Get-Content -Path $DataFilePath -Raw | ConvertFrom-Json)
$existingByKey = @{}
$existingBySlug = @{}
foreach ($e in $existing) {
    $existingByKey["$($e.ResourceType)|$($e.Resource)"] = $e
    if (-not $existingBySlug.ContainsKey($e.Slug)) {
        $existingBySlug[$e.Slug] = @()
    }
    $existingBySlug[$e.Slug] += $e
}

$newNoRules = [System.Collections.Generic.List[object]]::new()
$newBorrowable = [System.Collections.Generic.List[object]]::new()
$slugChanged = [System.Collections.Generic.List[object]]::new()
$seenKeys = [System.Collections.Generic.HashSet[string]]::new()

foreach ($row in $scraped) {
    $key = "$($row.ArmType)|$($row.Resource)"
    [void]$seenKeys.Add($key)

    $match = $existingByKey[$key]
    if ($match) {
        if ($match.Slug -ne $row.Slug) {
            $slugChanged.Add([pscustomobject]@{ ResourceType = $row.ArmType; Resource = $row.Resource; OldSlug = $match.Slug; NewSlug = $row.Slug })
        }
        continue
    }

    if ($existingBySlug.ContainsKey($row.Slug)) {
        $newBorrowable.Add([pscustomobject]@{ ResourceType = $row.ArmType; Resource = $row.Resource; Qualifier = $row.Qualifier; Slug = $row.Slug; LikeExisting = $existingBySlug[$row.Slug][0].ResourceType; SourceEntry = $existingBySlug[$row.Slug][0] })
    }
    else {
        $newNoRules.Add([pscustomobject]@{ ResourceType = $row.ArmType; Resource = $row.Resource; Qualifier = $row.Qualifier; Slug = $row.Slug })
    }
}

$removed = foreach ($e in $existing) {
    $key = "$($e.ResourceType)|$($e.Resource)"
    if (-not $seenKeys.Contains($key)) {
        [pscustomobject]@{ ResourceType = $e.ResourceType; Resource = $e.Resource; Slug = $e.Slug }
    }
}

$reportLines = [System.Collections.Generic.List[string]]::new()
$reportLines.Add("AzureCAF resourceDefinition.json drift report - $(Get-Date -Format 'yyyy-MM-dd HH:mm')")
$reportLines.Add("Compared $($existing.Count) existing entries against $($scraped.Count) rows scraped from the CAF abbreviation guide.")
$reportLines.Add('')

$reportLines.Add("== New: naming-rule data can be borrowed from an existing entry with the same slug ($($newBorrowable.Count)) ==")
foreach ($n in $newBorrowable) {
    $qualifierNote = if ($n.Qualifier) { " ($($n.Qualifier))" } else { '' }
    $reportLines.Add("  $($n.ResourceType)$qualifierNote [$($n.Resource)] -> slug '$($n.Slug)', copy rules from existing '$($n.LikeExisting)' entry and verify")
}
$reportLines.Add('')

$reportLines.Add("== New: no existing naming-rule data for this slug - needs the naming rules guide ($($newNoRules.Count)) ==")
foreach ($n in $newNoRules) {
    $qualifierNote = if ($n.Qualifier) { " ($($n.Qualifier))" } else { '' }
    $reportLines.Add("  $($n.ResourceType)$qualifierNote [$($n.Resource)] -> slug '$($n.Slug)'. See $NamingRulesGuideUrl for $($n.ResourceType.Split('/')[0])")
}
$reportLines.Add('')

$reportLines.Add("== Slug changed upstream ($($slugChanged.Count)) ==")
foreach ($s in $slugChanged) {
    $reportLines.Add("  $($s.ResourceType) [$($s.Resource)]: '$($s.OldSlug)' -> '$($s.NewSlug)'")
}
$reportLines.Add('')

$reportLines.Add("== In resourceDefinition.json but no longer on the abbreviation guide - review for rename/removal ($(@($removed).Count)) ==")
foreach ($r in $removed) {
    $reportLines.Add("  $($r.ResourceType) [$($r.Resource)] (slug '$($r.Slug)')")
}
$reportLines.Add('')

if ($CompareAzResourceProvider) {
    $reportLines.Add('== Live Azure resource provider coverage ==')

    if (-not (Get-Module -ListAvailable -Name Az.Resources)) {
        $reportLines.Add('  Az.Resources module not available - skipped. Install-Module Az.Resources to enable this check.')
    }
    elseif (-not (Get-AzContext -ErrorAction SilentlyContinue)) {
        $reportLines.Add('  Not signed in to Azure (Connect-AzAccount) - skipped.')
    }
    else {
        $liveTypes = foreach ($rp in Get-AzResourceProvider -ListAvailable) {
            foreach ($rt in $rp.ResourceTypes) {
                "$($rp.ProviderNamespace)/$($rt.ResourceTypeName)"
            }
        }
        $knownTypes = [System.Collections.Generic.HashSet[string]]::new([string[]]$existing.ResourceType, [System.StringComparer]::OrdinalIgnoreCase)
        $uncovered = $liveTypes | Where-Object { -not $knownTypes.Contains($_) } | Sort-Object -Unique
        $reportLines.Add("  $(@($uncovered).Count) ARM resource types registered in this subscription have no resourceDefinition.json entry:")
        foreach ($u in $uncovered) {
            $reportLines.Add("    $u")
        }
    }
    $reportLines.Add('')
}

if ($AutoApply) {
    $appliedBorrowed = [System.Collections.Generic.List[object]]::new()
    $appliedSlugChanges = [System.Collections.Generic.List[object]]::new()
    $updatedEntries = [System.Collections.Generic.List[object]]::new($existing)

    foreach ($n in $newBorrowable) {
        $source = $n.SourceEntry
        $updatedEntries.Add([pscustomobject][ordered]@{
                ResourceType      = $n.ResourceType
                Resource          = $n.Resource
                Slug              = $n.Slug
                Scope             = $source.Scope
                MinLength         = $source.MinLength
                MaxLength         = $source.MaxLength
                Lowercase         = $source.Lowercase
                Dashes            = $source.Dashes
                InvalidCharsRegex = $source.InvalidCharsRegex
                ValidationRegex   = $source.ValidationRegex
            })
        $appliedBorrowed.Add($n)
    }

    foreach ($s in $slugChanged) {
        $existingByKey["$($s.ResourceType)|$($s.Resource)"].Slug = $s.NewSlug
        $appliedSlugChanges.Add($s)
    }

    $reportLines.Add("== Auto-applied ($($appliedBorrowed.Count) new, $($appliedSlugChanges.Count) slug update(s)) ==")
    foreach ($n in $appliedBorrowed) {
        $reportLines.Add("  Added $($n.ResourceType) [$($n.Resource)] -> slug '$($n.Slug)', rules copied from '$($n.LikeExisting)'")
    }
    foreach ($s in $appliedSlugChanges) {
        $reportLines.Add("  Updated $($s.ResourceType) [$($s.Resource)]: slug '$($s.OldSlug)' -> '$($s.NewSlug)'")
    }
    $reportLines.Add('')

    if ($appliedBorrowed.Count -gt 0 -or $appliedSlugChanges.Count -gt 0) {
        $sorted = $updatedEntries | Sort-Object ResourceType, Resource
        Set-Content -Path $DataFilePath -Value ($sorted | ConvertTo-Json -Depth 5)
        $reportLines.Add("$DataFilePath was updated with the changes above. Entries under 'no existing naming-rule data' and 'no longer on the abbreviation guide' still need manual review.")
    }
    else {
        $reportLines.Add("$DataFilePath was NOT modified - no mechanical (borrowable/slug-only) changes were found. Entries above, if any, need manual review.")
    }
}
else {
    $reportLines.Add('resourceDefinition.json was NOT modified. Update it by hand using the entries above, then commit the change.')
}

$report = $reportLines -join "`n"
Write-Output $report

if ($ReportPath) {
    Set-Content -Path $ReportPath -Value $report
    Write-Output "`nReport also written to $ReportPath"
}
