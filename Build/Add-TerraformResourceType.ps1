<#
.SYNOPSIS
    Reports on how resourceDefinition.json's TerraformResourceType field has drifted from the real
    azurerm Terraform provider, so a maintainer can keep it current.
.DESCRIPTION
    TerraformResourceType is a curated field - it is deliberately never auto-applied, because cross-
    referencing a CAF resource type against a real azurerm_* resource name requires human judgement,
    not just a mechanical merge. That was learned the hard way while first populating this field:
    aztfmod/terraform-provider-azurecaf's own naming data looked like a clean source to merge on (it
    carries both a CAF slug and, for some entries, the ARM type), but a significant fraction of its
    slug-based matches turned out to be wrong - coincidental abbreviation collisions between unrelated
    resources (e.g. 'cm' matching both "Content moderator" and azurerm_network_connection_monitor, 'dh'
    matching both "Azure Enclave dedicated hub" and azurerm_dedicated_host), and a few entries that were
    simply stale (e.g. azurerm_static_site, renamed to azurerm_static_web_app; azurerm_mssql_mi, renamed
    to azurerm_mssql_managed_instance). None of that is safe to auto-apply.

    This script instead:
    - Fetches the authoritative, current list of real azurerm_* resource types directly from the
      hashicorp/terraform-provider-azurerm repository's website/docs/r directory (the actual resource
      doc filenames - the ground truth for "does this resource currently exist", independent of any
      third-party naming tool).
    - Flags resourceDefinition.json entries whose stored TerraformResourceType no longer appears in
      that list ("drift" - the resource was renamed or removed upstream, needs review).
    - Separately, fetches aztfmod/terraform-provider-azurecaf's naming data purely as a *discovery aid*
      for entries that are still null: it lists any aztfmod entry sharing the same CAF Slug as a
      possible candidate to investigate, but never asserts it's correct - the same slug-collision risk
      above applies to every suggestion here.

    resourceDefinition.json is never modified by this script. Review the report, verify each candidate
    against the real provider docs, and update the file by hand (or ask an AI assistant to do it from
    this report, the same way the original field was populated).
.PARAMETER Path
    Path to the resourceDefinition.json file to report on. Defaults to the module's own copy at
    AzureCAF/Private/resourceDefinition.json.
.PARAMETER ReportPath
    Optional path to also write the report to as a text file, in addition to the console.
.EXAMPLE
    ./Build/Add-TerraformResourceType.ps1

    Reports on TerraformResourceType drift and surfaces candidates for still-unmapped entries.
.EXAMPLE
    ./Build/Add-TerraformResourceType.ps1 -ReportPath ./terraform-drift-report.txt

    Also saves the report to a file.
#>
[CmdletBinding()]
param(
    [string]
    $Path = (Join-Path $PSScriptRoot '..\AzureCAF\Private\resourceDefinition.json'),

    [string]
    $ReportPath
)

$AzurermDocsTreeUrl = 'https://api.github.com/repos/hashicorp/terraform-provider-azurerm/git/trees/567aadb0bb0bf06b7f87596cd512977ef7ba6954'
$AzurermRepoApiUrl = 'https://api.github.com/repos/hashicorp/terraform-provider-azurerm/contents/website/docs'
$AztfmodDataUrl = 'https://raw.githubusercontent.com/aztfmod/terraform-provider-azurecaf/main/resourceDefinition.json'

Write-Output "Resolving the current website/docs/r tree from hashicorp/terraform-provider-azurerm ..."
$DocsListing = Invoke-RestMethod -Uri $AzurermRepoApiUrl -UseBasicParsing
$DocsRSha = ($DocsListing | Where-Object Name -EQ 'r').Sha

if (-not $DocsRSha) {
    Write-Error "Couldn't resolve the website/docs/r directory's tree sha - the provider repo's layout may have changed."
    return
}

$DocsRTreeUrl = "https://api.github.com/repos/hashicorp/terraform-provider-azurerm/git/trees/$DocsRSha"
Write-Output "Fetching $DocsRTreeUrl ..."
$DocsRTree = Invoke-RestMethod -Uri $DocsRTreeUrl -UseBasicParsing

if ($DocsRTree.truncated) {
    Write-Warning 'The docs/r tree response was truncated - results may be incomplete.'
}

$RealResourceNames = [System.Collections.Generic.HashSet[string]]::new([string[]]@(
        $DocsRTree.tree.path | ForEach-Object { 'azurerm_' + ($_ -replace '\.(html\.)?markdown$', '') }
    ), [System.StringComparer]::Ordinal)

Write-Output "Found $($RealResourceNames.Count) real azurerm_* resources.`n"

$existing = @(Get-Content -Path $Path -Raw | ConvertFrom-Json)

$drifted = [System.Collections.Generic.List[object]]::new()
foreach ($e in $existing) {
    if ($e.TerraformResourceType -and -not $RealResourceNames.Contains($e.TerraformResourceType)) {
        $drifted.Add($e)
    }
}

$unmapped = @($existing | Where-Object { -not $_.TerraformResourceType })

Write-Output "Fetching $AztfmodDataUrl for candidate suggestions on unmapped entries ..."
$aztfmodBySlug = @{}
try {
    $aztfmodData = Invoke-RestMethod -Uri $AztfmodDataUrl -UseBasicParsing
    foreach ($d in $aztfmodData) {
        if (-not $aztfmodBySlug.ContainsKey($d.slug)) { $aztfmodBySlug[$d.slug] = @() }
        $aztfmodBySlug[$d.slug] += $d.name
    }
}
catch {
    Write-Warning "Couldn't fetch aztfmod's data - candidate suggestions will be skipped. $_"
}

$reportLines = [System.Collections.Generic.List[string]]::new()
$reportLines.Add("AzureCAF TerraformResourceType drift report - $(Get-Date -Format 'yyyy-MM-dd HH:mm')")
$reportLines.Add("Compared $($existing.Count) entries ($(@($existing | Where-Object TerraformResourceType).Count) currently mapped) against $($RealResourceNames.Count) real azurerm_* resources.")
$reportLines.Add('')

$reportLines.Add("== Stored TerraformResourceType no longer exists upstream - renamed or removed, needs review ($($drifted.Count)) ==")
foreach ($d in $drifted) {
    $reportLines.Add("  $($d.ResourceType) [$($d.Resource)]: '$($d.TerraformResourceType)' no longer found in the azurerm provider")
}
$reportLines.Add('')

$reportLines.Add("== Still unmapped - candidates below are unverified, cross-check each against the real provider docs before adding ($($unmapped.Count)) ==")
foreach ($u in $unmapped) {
    $candidates = $aztfmodBySlug[$u.Slug] | Where-Object { $RealResourceNames.Contains($_) }
    $candidateNote = if ($candidates) { "possible candidate(s), UNVERIFIED: $($candidates -join ', ')" } else { 'no candidate found' }
    $reportLines.Add("  $($u.ResourceType) [$($u.Resource)] (slug '$($u.Slug)') - $candidateNote")
}
$reportLines.Add('')

$reportLines.Add('resourceDefinition.json was NOT modified - this field is never auto-applied. Verify each candidate above against https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs before updating the file by hand.')

$report = $reportLines -join "`n"
Write-Output $report

if ($ReportPath) {
    Set-Content -Path $ReportPath -Value $report
    Write-Output "`nReport also written to $ReportPath"
}
