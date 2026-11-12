# PowerShell-AzureCAF

[![Build Status](https://github.com/markwragg/Powershell-AzureCAF/actions/workflows/build.yml/badge.svg)](https://github.com/markwragg/Powershell-AzureCAF/actions/workflows/build.yml)
![coverage](https://img.shields.io/badge/coverage-98%25-brightgreen.svg)
[![PowerShell Gallery Version](https://img.shields.io/powershellgallery/v/AzureCAF?label=PS%20Gallery)](https://www.powershellgallery.com/packages/AzureCAF)
[![PowerShell Gallery Downloads](https://img.shields.io/powershellgallery/dt/AzureCAF?color=D3D3D3)](https://www.powershellgallery.com/packages/AzureCAF)

> A PowerShell module for generating valid and consistent Azure Resource names per the [Cloud Adoption Framework naming recommendations](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations).

- Generates consistent, informative resource names that align with CAF best practice.
- Enables scripts/tools to fail fast, should you attempt to use an invalid resource name.
- Corrects some resource names by default, e.g does not attempt to create Storage accounts with invalid characters.
- Appends a random string suffix when required (to ensure global uniqueness) and can do so in an idempotent way.

Use this module as part of PowerShell deployment scripts to generate suitable names for resources, or as part of pre-planning work to prepare resource names in advance, ensuring that each resource name is valid for the type of resource being deployed (giving consideration to valid characters, casing and length).

See the [Examples](/Examples/) folder for some sample usage scripts.

## Installation

The module is published in the PowerShell Gallery, so if you have PowerShell 5 or newer can be installed by running:

```powershell
Install-Module AzureCAF
```

Or

```powershell
Install-PSResource AzureCAF
```

## Cmdlets

| Cmdlet | Synopsis |
| --- | --- |
| `Get-CafResourceName` | Generates an Azure resource name that follows the Cloud Adoption Framework naming convention, returning just the name as a string. |
| `New-CafResourceName` | Generates an Azure resource name that follows the Cloud Adoption Framework naming convention, returning the full result as an object. |
| `Test-CafResourceName` | Tests whether a name complies with the Cloud Adoption Framework naming rules for an Azure resource type. |
| `Get-CafResourceType` | Looks up the Cloud Adoption Framework naming rules for one or more Azure resource types. |
| `Get-CafRegion` | Looks up the abbreviation for one or more Azure regions. |
| `New-CafNamingConvention` | Saves a reusable set of Get-CafResourceName defaults (prefix, suffix, region, separator, etc.) to a JSON file, so your organization's naming convention doesn't need to be retyped on every call. |
| `Export-CafResourceType` | Exports the Cloud Adoption Framework naming rules for one or more resource types to a CSV or Markdown file. |

## Usage

This module can be used to generate consistent resource names, while ensuring that those names are valid for each specific resource types.

Per the CAF, the recommended naming order is:


- `{type}`-`{workload}`-`{environment}`-`{region}`-`{instance}`

Or with company and department added:

- `{type}`-`{company}`-`{department}`-`{workload}`-`{environment}`-`{region}`-`{instance}`

With a hyphen (-) used as a separator for most resources (where permitted).

Except for `{type}`, this module does not prescribe the use of any of the above fields, but provides the following options, allowing you flexibility to define how your naming convention is configured:

| Segment | Parameter/s | Description |
| --- | --- | --- |
| `{type}` | `‑ResourceType`<br>`‑Resource`<br>`‑Alias`<br>`‑TerraformResourceType` | (Required) The ARM resource type's CAF abbreviation (also known as `slug`). `-Resource` is sometimes required alongside `‑ResourceType` to avoid ambiguity; `-Alias` is a shorter alternative if you already know the abbreviation; `-TerraformResourceType` identifies it by its Terraform `azurerm_*` resource type instead, where one exists. |
| `{separator}` | `‑Separator` | The character(s) to use between each naming segment. `-` by default (except where a resource type does not permit the character). Specify `''` for no separator at all. |
| `{prefix}` | `-Prefix` | One or more strings appended before `{type}`, joined via `{separator}`. This could be company, workload, environment etc. |
| `{suffix}` | `‑Suffix` | One or more strings appended after `{type}`, joined via `{separator}`. This could be company, workload, environment etc. |
| `{region}` | `‑Region` | Appends the abbreviation for the specified region after `{suffix}` and before `{instance}`. If you want region to appear elsewhere in the order, add it to your `-Prefix` or `-Suffix` arrays instead. |
| `{instance}` | `‑InstanceNumber` | Appends a number to the end of the resource name, padded with leading zeros as specified via `-InstanceNumberPadding`, which is set to 3 by default (so a single digit is padded by two zeros). |

If you want the generated name in a particular case, `-Casing` re-cases every segment - `-Prefix`/`-Suffix`, `{type}`'s own slug and a resolved `{region}` abbreviation: `Lower`, `Upper` or `Title` (e.g. `-Prefix 'contoso'` with `-Casing Upper` becomes `'CONTOSO'`, and `{type}`'s `'vm'` slug becomes `'VM'` alongside it). A resource type that requires an all-lowercase name still overrides it regardless.

If you want to append a random string of characters to the end of a resource name (useful where you need to ensure global uniqueness), you can use `-RandomSuffixLength` (Alias: `-Rsl`) to define how many characters to append.

By default, this will be randomly generated each time the cmdlet is called. If you want the random string to be consistent (but still unique for each resource), provide a value to `-RandomSuffixSeed` (Alias: `-Rss`) and when generating a name for the same resource, the module will always generate the same random string (this is useful if you want a script to be idempotent, i.e: the same resources are created wit hthe same names every time).

### Generate a resource name

`Get-CafResourceName` builds a name by combining zero or more prefixes, the CAF-recommended abbreviation for an Azure resource type, zero or more suffixes, an optional instance number and random string - checking the result against that resource type's length limit and allowed characters along the way. `Get-CafResourceName` returns only the resource name, as a string. Use `New-CafResourceName` to return a PowerShell object with `Name`/`ResourceType`/`Resource`/`Slug`/`TerraformResourceType`/`InstanceNumber`/`RandomSuffix` properties instead (see the batch-generation example below).

The default parameter to identify the resource is `-ResourceType`:

```powershell
Get-CafResourceName -ResourceType Microsoft.Compute/virtualMachines -Suffix contoso,sales,web,prod -Region ukwest
```
```text
vm-contoso-sales-web-prod-ukw
```

Because this is the default parameter, you can use it implicitly:

```powershell
Get-CafResourceName Microsoft.Compute/virtualMachines -Suffix web,dev -Prefix contoso,sales
```
```text
contoso-sales-vm-web-dev
```

You can also identify a resource using it's friendly name, via `-Resource`:

```powershell
Get-CafResourceName -Resource 'Virtual Machine' -Suffix contoso,uat
```
```text
vm-contoso-uat
```

Or if you already know the Alias/Slug for a specific resource, via `-Alias` (Alias: `-Slug`):

```powershell
Get-CafResourceName -Alias vm -Suffix contoso,prod
```
```text
vm-contoso-prod
```

If you work primarily in Terraform, you can identify the resource by its `azurerm_*` resource type instead, via `-TerraformResourceType` (Alias: `-Tf`):

```powershell
Get-CafResourceName -TerraformResourceType azurerm_storage_account -Prefix contoso -RandomSuffixLength 6
```
```text
contosostabcdef
```

> `TerraformResourceType` is usually a single string, but an array for the handful of resource types with more than one current real `azurerm` equivalent (e.g. `azurerm_linux_virtual_machine` and `azurerm_windows_virtual_machine` for a virtual machine) - `-TerraformResourceType` resolves the row from either one. It's `$null` for resource types Terraform doesn't model distinctly (e.g. most Azure Policy resources).

> Use `Get-CafResourceType` to list all available `ResourceType`/`Resource`/`Slug` (Alias)/`TerraformResourceType` options, along with their naming restriction rules.

If you need to number your resource, use `-InstanceNumber` (Alias: `-In`) to append a number to the end of the resource name (zero-padded to 3 digits by default):

```powershell
Get-CafResourceName Microsoft.Compute/virtualMachines -Suffix contoso,prod -In 1
```
```text
vm-contoso-prod-001
```

Use `-InstanceNumberPadding` (Alias: `-Inp`) to specify a different number of leading zeros:

```powershell
Get-CafResourceName Microsoft.Compute/virtualMachines -Suffix contoso,prod -In 1 -Inp 2
```
```text
vm-contoso-prod-01
```

When using `-ResourceType` a small number of resources use the same base identifier, so must be distinguished by also providing `-Resource`. For example:

```powershell
Get-CafResourceName Microsoft.Web/sites -Suffix contoso,prod
```
> [!CAUTION]
> ```
> Write-Error: 'Microsoft.Web/sites' matches more than one resource type. Narrow it down with -Resource:
> 'Microsoft.Web/sites [Function app]','Microsoft.Web/sites [Web app]'.
>```

```powershell
Get-CafResourceName Microsoft.Web/sites -Resource 'Web app' -Suffix contoso,prod
```
```text
app-contoso-prod
```

> Note that for the above example, you could just do `Get-CafResourceName -Resource 'Web app' -Suffix contoso,prod`, or `Get-CafResourceName -Alias app -Suffix contoso,prod`.

To ensure that a name is unique, it can sometimes be useful to append a number of random characters. Achieve this via the `-RandomSuffixLength` parameter (Alias: `-Rsl`), specifying the number of characters to append:

```powershell
Get-CafResourceName Microsoft.Storage/storageAccounts -Suffix contoso,prod -Rsl 6
```
```text
contosostabcdef
```

Pass `-RandomSuffixSeed` (Alias: `-Rss`) when you need the random suffix to be reproducible - e.g. so repeated deployments of the same resource result in the same name being generated every time:

```powershell
Get-CafResourceName Microsoft.Storage/storageAccounts -Suffix contoso,prod -Rsl 6 -Rss 456
```
```text
stcontosoprod8ws5dc
```

If you need to generate a series of names for the same resource type, `-Count` can be used to generate several sequential instance numbers in one call, starting from a value specified via `-InstanceNumber`, or `1` if not used:

```powershell
Get-CafResourceName Microsoft.Compute/virtualMachines -Suffix contoso,prod -Count 3
```
```text
vm-contoso-prod-001
vm-contoso-prod-002
vm-contoso-prod-003
```

```powershell
Get-CafResourceName Microsoft.Compute/virtualMachines -Suffix contoso,prod -InstanceNumber 4 -Count 3
```
```text
vm-contoso-prod-004
vm-contoso-prod-005
vm-contoso-prod-006
```

As detailed above, the [naming components guide](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming#choose-naming-components) calls out workload/application, environment and region as useful naming components - CAF deliberately leaves their order up to you, so just include any naming values you deem useful via `-Prefix`/`-Suffix` in whichever order your organization has standardized on, e.g. `-Prefix workload1,prod`.

`-Region` resolves an Azure region to its abbreviation the same way `-ResourceType` resolves to its slug (e.g. `eastus` -> `eus`), and inserts it after any `-Suffix`, so `-Suffix` always comes right after the resource type's slug (aside from an instance number, which stays last):

```powershell
Get-CafResourceName Microsoft.Compute/virtualMachines -Prefix contoso,prod -Region eastus
```
```text
contoso-prod-vm-eus
```

You can also use the resolved shortname if you already know it:

```powershell
Get-CafResourceName Microsoft.Compute/virtualMachines -Prefix contoso,prod -Region eus
```
```text
contoso-prod-vm-eus
```

> Use `Get-CafRegion` to list all available `Region`/`DisplayName`/`Slug` options, along with each region's paired region where available.

Use `-Casing` to get the whole generated name in a consistent case, including the resource type's own slug:

```powershell
Get-CafResourceName Microsoft.Compute/virtualMachines -Prefix Contoso, PROD -Casing Upper
```
```text
CONTOSO-PROD-VM
```

`Get-CafResourceName` accepts pipeline input by property name, so a list of resource specs - e.g. imported from a CSV, or any objects with ResourceType/Alias/Prefix/Suffix/etc. properties - can be batch-generated in one call:

```powershell
Import-Csv ./resources.csv | Get-CafResourceName
```

Batch-generating like this returns bare strings, which lose track of which input row (or which `-Count` iteration) produced which name. Use `New-CafResourceName` instead to get back a `Name`/`ResourceType`/`Resource`/`Slug`/`TerraformResourceType`/`InstanceNumber`/`RandomSuffix` object - handy for exporting alongside the values that produced each name:

```powershell
Import-Csv ./resources.csv | New-CafResourceName | Export-Csv ./generated-names.csv
```

Add `-Verbose` to see the length-budget reasoning behind a result (reserved segments, trimming decisions):

```powershell
Get-CafResourceName -Alias st -Prefix contoso -Rsl 6 -Verbose
```
> [!NOTE]
> ```
> VERBOSE: Resolved to Microsoft.Storage/storageAccounts [Storage account] (slug 'st', max length 24, dashes False, lowercase True).
> VERBOSE: Reserving 6 character(s) for the random suffix; 18 of 24 remain for the prefix/slug/region/suffix.
> VERBOSE: Joined 'contoso', 'st' with separator '' -> 'contosost' (9 characters).
> VERBOSE: Appended random suffix 'ujiqhs' -> 'contosostujiqhs'.
> VERBOSE: Final result: 'contosostujiqhs'.
>```

```text
contosostujiqhs
```

### Reusable naming conventions

If your organization always uses the same prefix, region, separator, casing, instance-number padding or random-suffix length, save them once with `New-CafNamingConvention` instead of retyping them on every call:

```powershell
New-CafNamingConvention -Path ./contoso-prod.json -Prefix contoso, prod -Region eastus -Separator '-' -InstanceNumberPadding 2

Get-CafResourceName Microsoft.Compute/virtualMachines -ConventionPath ./contoso-prod.json -InstanceNumber 1
```
```text
contoso-prod-vm-eus-01
```

Anything you also specify explicitly (including via the pipeline) still takes precedence over the file. `-Region` is resolved and saved as its ARM name at this point, so a typo is caught here rather than on every later call that reads the file - `-RandomSuffixSeed` is deliberately not one of these saved defaults, since a shared seed baked into a convention file everyone reuses would make the "random" suffix identical for every one of those calls, defeating the uniqueness `-RandomSuffixLength` exists for.

### Validate a resource name

`Test-CafResourceName` checks an existing name against the same rules `Get-CafResourceName` enforces - minimum/maximum length, required casing, whether a dash is allowed, and the overall set of valid characters - returning an object showing which rules pass or fail, or just an overall `$true`/`$false` with `-Quiet`:

```powershell
Test-CafResourceName -Name 'contoso-prod-vm-001' Microsoft.Compute/virtualMachines
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
Test-CafResourceName -Name 'CONTOSO' Microsoft.Storage/storageAccounts -Quiet
```
```text
False
```

`IsValid` is the authoritative result; the other fields are a diagnostic breakdown that can't always add up to it perfectly for every resource type (see the cmdlet's help for why) - treat `IsValid` as the source of truth if the two ever disagree. When invalid, `Reason` explains why in plain English:

```powershell
(Test-CafResourceName -Name 'CONTOSO' Microsoft.Storage/storageAccounts).Reason
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
Get-CafResourceType -TerraformResourceType azurerm_storage_account
```

Export it as a reference table for sharing outside PowerShell with `Export-CafResourceType` - the format (CSV or Markdown) is chosen from `-Path`'s extension:

```powershell
Export-CafResourceType -Path ./resource-types.md
Get-CafResourceType -ResourceType *storage* | Export-CafResourceType -Path ./storage-types.csv
```

### Discover regions

`Get-CafRegion` is the same kind of local, offline lookup as `Get-CafResourceType`, but for the region abbreviations `-Region` resolves to. It also returns the region's Azure-paired region (`$null` if it doesn't have one - increasingly common for newer regions, which favour availability zones over region pairing for resiliency) - informational only, since `-Region` doesn't resolve against it:

```powershell
Get-CafRegion -Region eastus
Get-CafRegion -Region 'West Europe'
```
```text
Region DisplayName Slug PairedRegion
------ ----------- ---- ------------
eastus East US     eus  westus
```

## Data source and maintenance

`AzureCAF/Private/resourceDefinition.json` is a static, curated data set keyed by real ARM resource type (e.g. `Microsoft.Compute/virtualMachines`), built by joining:

- The abbreviations from Microsoft's [CAF resource abbreviations guide](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations).
- The length/scope/allowed-character rules from [aztfmod/terraform-provider-azurecaf](https://github.com/aztfmod/terraform-provider-azurecaf) (MIT licensed), matched by abbreviation. That project's data isn't used for its (Terraform-specific) resource names - only for the naming-rule regexes it has already reverse-engineered and tested against real Azure behaviour.

As Azure adds resource types, run [`Build/Update-ResourceDefinition.ps1`](Build/Update-ResourceDefinition.ps1) to see what's changed:

```powershell
./Build/Update-ResourceDefinition.ps1
```

It re-scrapes the CAF abbreviations guide and reports resource types that are new, removed, or have changed slug since `resourceDefinition.json` was last updated - splitting new entries into ones where naming-rule data can be copied from an existing entry with the same abbreviation, versus ones that need a naming rule looked up by hand from the [naming rules and restrictions guide](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules) (deliberately not auto-parsed - that page is free-text prose, and generating a wrong validation regex is worse than flagging a gap). It never modifies `resourceDefinition.json` itself; review the report and update the file by hand. Pass `-CompareAzResourceProvider` to additionally cross-check against `Get-AzResourceProvider -ListAvailable` for ARM types Azure now has that aren't in the CAF guide yet (requires `Az.Resources` and `Connect-AzAccount`).

`AzureCAF/Private/regionDefinition.json` is a similar static data set for region abbreviations, sourced from [jlaundry.nz's Azure region abbreviations](https://www.jlaundry.nz/2022/azure_region_abbreviations/) rather than an official Microsoft source - Microsoft doesn't publish a complete abbreviation for every region. Region names/existence are cross-checked against Microsoft's official [list of Azure regions](https://learn.microsoft.com/en-us/azure/reliability/regions-list); a handful of entries that jlaundry's list carried but don't appear there (`Brazil US`, the retired classic `Germany Central`/`Germany Northeast`, `Jio India Central`/`Jio India West`, `Malaysia South`, `Sweden South`) were dropped, and regions missing an abbreviation from either source (`India South Central`, `Southeast Asia 3`, `Taiwan North`) got one coined by hand, following the style of neighbouring entries. There's no scraper for it; update the file by hand as new regions launch.
