# PowerShell-AzureCAF

[![Build Status](https://github.com/markwragg/Powershell-AzureCAF/actions/workflows/build.yml/badge.svg)](https://github.com/markwragg/Powershell-AzureCAF/actions/workflows/build.yml)
![coverage](https://img.shields.io/badge/coverage-97%25-brightgreen.svg)
[![PowerShell Gallery Version](https://img.shields.io/powershellgallery/v/AzureCAF?label=PS%20Gallery)](https://www.powershellgallery.com/packages/AzureCAF)
[![PowerShell Gallery Downloads](https://img.shields.io/powershellgallery/dt/AzureCAF?color=D3D3D3)](https://www.powershellgallery.com/packages/AzureCAF)

A PowerShell module for generating Azure Resource names per the [Cloud Adoption Framework naming recommendations](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations).

## Installation

The module is published in the PSGallery, so if you have PowerShell 5 or newer can be installed by running:

```powershell
Install-Module AzureCAF
```

## Usage

### Generate a resource name

`Get-CafResourceName` builds a name from an optional prefix, the CAF-recommended abbreviation for an Azure resource type, and an optional suffix - checking the result against that resource type's length limit and allowed characters along the way.

```powershell
Get-CafResourceName -ResourceType Microsoft.Compute/virtualMachines -Prefix contoso, prod -Suffix 01
```
```text
contoso-prod-vm-01
```

`-InstanceNumber` is zero-padded to 3 digits by default:

```powershell
Get-CafResourceName -ResourceType Microsoft.Compute/virtualMachines -Prefix contoso, prod -InstanceNumber 1
```
```text
contoso-prod-vm-001
```

`-RandomSuffixLength` appends random characters for scenarios that need a globally-unique name:

```powershell
Get-CafResourceName -ResourceType Microsoft.Storage/storageAccounts -Prefix contoso -RandomSuffixLength 6
```
```text
contosostabcdef
```

Pass `-RandomSuffixSeed` when you need the random suffix to be reproducible - e.g. so repeated deployments of the same resource land on the same name:

```powershell
Get-CafResourceName -ResourceType Microsoft.Storage/storageAccounts -Prefix contoso -RandomSuffixLength 6 -RandomSuffixSeed 42
```

`-Count` generates several sequential instance numbers in one call, starting from `-InstanceNumber` if specified, otherwise `1`:

```powershell
Get-CafResourceName -ResourceType Microsoft.Compute/virtualMachines -Prefix contoso, prod -Count 3
```
```text
contoso-prod-vm-001
contoso-prod-vm-002
contoso-prod-vm-003
```

The [naming components guide](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming#choose-naming-components) also calls out workload/application, environment and region as useful naming components - CAF deliberately leaves their order up to you, so just include them in `-Prefix`/`-Suffix` in whichever order your organization has standardized on, e.g. `-Prefix workload1, prod, eastus2`.

Some ARM resource types cover more than one kind of resource with different abbreviations (for example `Microsoft.Web/sites` is used by both a "Web app" and a "Function app"). When that happens, `Get-CafResourceName` tells you which `-Resource` values to choose between:

```powershell
Get-CafResourceName -ResourceType Microsoft.Web/sites -Resource 'Function app' -Prefix contoso
```
```text
contoso-func
```

If you already know the CAF abbreviation, `-Alias` (aliased `-Slug`) is a shorter alternative to `-ResourceType`:

```powershell
Get-CafResourceName -Alias vmss -Prefix contoso
```
```text
contoso-vmss
```

Every `-Resource` friendly name in the data is unique, so it works as a third alternative on its own too - handy if you only remember the resource's plain-English name:

```powershell
Get-CafResourceName -Resource 'Key vault' -Prefix contoso
```
```text
contoso-kv
```

`Get-CafResourceName` accepts pipeline input by property name, so a list of resource specs - e.g. imported from a CSV, or any objects with ResourceType/Alias/Prefix/Suffix/etc. properties - can be batch-generated in one call:

```powershell
Import-Csv ./resources.csv | Get-CafResourceName
```

Batch-generating like this returns bare strings, which lose track of which input row (or which `-Count` iteration) produced which name. Add `-AsObject` to get back `Name`/`ResourceType`/`Resource`/`Slug`/`InstanceNumber`/`RandomSuffix` instead - handy for exporting alongside the values that produced each name:

```powershell
Import-Csv ./resources.csv | Get-CafResourceName -AsObject | Export-Csv ./generated-names.csv
```

Add `-Verbose` to see the length-budget reasoning behind a result (reserved segments, trimming decisions):

```powershell
Get-CafResourceName -ResourceType Microsoft.Storage/storageAccounts -Prefix contoso -RandomSuffixLength 6 -Verbose
```
```text
VERBOSE: Resolved to Microsoft.Storage/storageAccounts [Storage account] (slug 'st', max length 24, ...).
VERBOSE: Reserving 6 character(s) for the random suffix; 18 of 24 remain for the prefix/slug/suffix.
VERBOSE: Joined 'contoso', 'st' with separator '' -> 'contosost' (9 characters).
VERBOSE: Appended random suffix 'xxxxxx' -> 'contosostxxxxxx'.
VERBOSE: Final result: 'contosostxxxxxx'.
```

### Reusable naming conventions

If your organization always uses the same prefix, separator, instance-number padding or random-suffix length, save them once with `New-CafResourceNamingConvention` instead of retyping them on every call:

```powershell
New-CafResourceNamingConvention -Path ./contoso-prod.json -Prefix contoso, prod -Separator '-' -InstanceNumberPadding 2

Get-CafResourceName -ResourceType Microsoft.Compute/virtualMachines -ConventionPath ./contoso-prod.json -InstanceNumber 1
```
```text
contoso-prod-vm-01
```

Anything you also specify explicitly (including via the pipeline) still takes precedence over the file.

### Validate a resource name

`Test-CafResourceName` checks an existing name against the same rules `Get-CafResourceName` enforces - minimum/maximum length, required casing, whether a dash is allowed, and the overall set of valid characters - returning an object showing which rules pass or fail, or just an overall `$true`/`$false` with `-Quiet`:

```powershell
Test-CafResourceName -Name 'contoso-prod-vm-001' -ResourceType Microsoft.Compute/virtualMachines
```
```text
Name            : contoso-prod-vm-001
ResourceType    : Microsoft.Compute/virtualMachines
Resource        : Virtual machine
IsValid         : True
MinLength       : True
MaxLength       : True
Casing          : True
Dashes          : True
ValidCharacters : True
```

`-Quiet` returns just the boolean - here `$false` because storage account names must be lowercase:

```powershell
Test-CafResourceName -Name 'CONTOSO' -ResourceType Microsoft.Storage/storageAccounts -Quiet
```
```text
False
```

`IsValid` is the authoritative result; the other fields are a diagnostic breakdown that can't always add up to it perfectly for every resource type (see the cmdlet's help for why) - treat `IsValid` as the source of truth if the two ever disagree. When invalid, `Reason` explains why in plain English:

```powershell
(Test-CafResourceName -Name 'CONTOSO' -ResourceType Microsoft.Storage/storageAccounts).Reason
```
```text
Name must be all lowercase for this resource type.
```

### Discover resource types

`Get-CafResourceType` is a local, offline lookup over the module's bundled naming-rule data - it doesn't call Azure, so it doesn't need `Connect-AzAccount`. Use it to find the right `-ResourceType`/`-Resource` values, or to see the length/casing rules a resource type is subject to. This is different from `Get-AzResourceProvider` (from the `Az.Resources` module), which asks Azure which resource providers and types are registered/available in a subscription - that's a live-service question, not a naming-rules one.

```powershell
Get-CafResourceType -ResourceType *storageAccount*
Get-CafResourceType -Alias kv
Get-CafResourceType -Resource 'Key vault' | Get-CafResourceName -Prefix contoso -RandomSuffixLength 4
```

Export it as a reference table for sharing outside PowerShell with `Export-CafResourceType` - the format (CSV or Markdown) is chosen from `-Path`'s extension:

```powershell
Export-CafResourceType -Path ./resource-types.md
Get-CafResourceType -ResourceType *storage* | Export-CafResourceType -Path ./storage-types.csv
```

## Data source and maintenance

`AzureCAF/resourceDefinition.json` is a static, curated data set keyed by real ARM resource type (e.g. `Microsoft.Compute/virtualMachines`), built by joining:

- The abbreviations from Microsoft's [CAF resource abbreviations guide](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations).
- The length/scope/allowed-character rules from [aztfmod/terraform-provider-azurecaf](https://github.com/aztfmod/terraform-provider-azurecaf) (MIT licensed), matched by abbreviation. That project's data isn't used for its (Terraform-specific) resource names - only for the naming-rule regexes it has already reverse-engineered and tested against real Azure behaviour.

As Azure adds resource types, run [`Build/Update-ResourceDefinition.ps1`](Build/Update-ResourceDefinition.ps1) to see what's changed:

```powershell
./Build/Update-ResourceDefinition.ps1
```

It re-scrapes the CAF abbreviations guide and reports resource types that are new, removed, or have changed slug since `resourceDefinition.json` was last updated - splitting new entries into ones where naming-rule data can be copied from an existing entry with the same abbreviation, versus ones that need a naming rule looked up by hand from the [naming rules and restrictions guide](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules) (deliberately not auto-parsed - that page is free-text prose, and generating a wrong validation regex is worse than flagging a gap). It never modifies `resourceDefinition.json` itself; review the report and update the file by hand. Pass `-CompareAzResourceProvider` to additionally cross-check against `Get-AzResourceProvider -ListAvailable` for ARM types Azure now has that aren't in the CAF guide yet (requires `Az.Resources` and `Connect-AzAccount`).
