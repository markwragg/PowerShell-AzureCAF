# Change Log

## [0.3.0] - 2026-11-01

* Validated `regionDefinition.json` against Microsoft's official [list of Azure regions](https://learn.microsoft.com/en-us/azure/reliability/regions-list): removed entries that don't appear there (`Brazil US`, the retired classic `Germany Central`/`Germany Northeast`, `Jio India Central`/`Jio India West`, `Malaysia South`, `Sweden South`) and added `India South Central`, `Southeast Asia 3` and `Taiwan North`, which it lists but the original data source predated.
* `Get-CafResourceName`'s `-Region` parameter (and `Get-CafRegion`'s `-Region`) now also accepts the slug itself (e.g. `-Region eus`), matched exactly rather than as a substring, so passing through a value already known to be valid is a no-op instead of an error.
* [Breaking] `New-CafResourceNamingConvention` has been renamed to `New-CafNamingConvention`.
* `New-CafNamingConvention` supports a `-Region` default, resolved and saved as its ARM region name (so an unrecognized value is caught at save time, not on every later call) - consumed by `Get-CafResourceName -ConventionPath` the same way `-Prefix`/`-Suffix`/etc. already are.

## [0.2.0] - 2026-11-01

* Added a `-Region` parameter to `Get-CafResourceName` to add a region short-code after the suffix, based on specifying the full region name or display name.
* Added `Get-CafRegion`, a local/offline lookup of the abbreviation `Get-CafResourceName`'s new `-Region` parameter resolves an Azure region to (e.g. `eastus` -> `eus`, appended after any `-Suffix`), covering 77 regions.
* Expanded `resourceDefinition.json` from 127 to 239 resource types, adding coverage for services such as Azure Cache for Redis, Azure NetApp Files, Azure AI Foundry/Cognitive Services kind variants, load balancers, private endpoints, DNS zones, backup vaults, and the Operator Nexus (`NetworkCloud/*`) family.

## [0.1.0] - 2026-10-31

* [Breaking] `Get-CafResourceName` `-Seed` parameter has been renamed to `-ResourceSuffixSeed`.
* `Get-CafResourceName` supports `-Count` to generate several sequential instance numbers in one call (e.g. `-Count 3` produces `-001`, `-002`, `-003`), starting from `-InstanceNumber` if specified, otherwise `1`. Each generated name gets its own random suffix when `-RandomSuffixLength` is also used.
* `Get-CafResourceName` supports `-AsObject`, returning a `Name`/`ResourceType`/`Resource`/`Slug`/`InstanceNumber`/`RandomSuffix` object instead of a bare string - useful for telling results apart when batch-generating across resource types and/or `-Count`, or for exporting alongside the values that produced each name.

## [0.0.1] - 2026-10-31

* Added `Get-CafResourceName`, generating Azure resource names from their real ARM resource type (e.g. `Microsoft.Compute/virtualMachines`) using the Cloud Adoption Framework recommended abbreviation, with optional zero-padded instance number and random-character (`-RandomSuffixLength`, always lowercase) suffixes for instance differentiation and globally-unique naming scenarios. Pass `-Seed` to make the random suffix reproducible, for idempotent name generation.
* Added `Get-CafResourceType`, a local/offline lookup of the CAF naming rules (abbreviation, scope, length, casing) for a given resource type.
* Added `Test-CafResourceName`, validating an existing name against a resource type's naming rules, returning a pass/fail breakdown, a plain-English `Reason` when invalid, or an overall `$true`/`$false` with `-Quiet`.
* Added `New-CafResourceNamingConvention`, saving a reusable set of `-Prefix`/`-Suffix`/`-Separator`/`-InstanceNumberPadding`/`-RandomSuffixLength` defaults to a JSON file, so an organization's naming convention doesn't need to be retyped on every call - consumed by `Get-CafResourceName -ConventionPath`, with anything also specified explicitly still taking precedence.
* Added `Export-CafResourceType`, writing the known resource types to a CSV or Markdown reference file (format chosen from `-Path`'s extension), for sharing outside PowerShell.
* `Get-CafResourceName` accepts pipeline input by property name on all of its parameters, so a list of resource specs (e.g. from `Import-Csv`) can be batch-generated in one call. Added `-Verbose` tracing of the length-budget reasoning (reserved segments, trimming decisions) behind a result.
* `-ResourceType` and `-Resource` match as a substring by default (falling back from an exact match), so the full ARM type doesn't need to be typed out. An `-Alias` parameter (aliased `-Slug`) is also available as a shorter alternative to `-ResourceType` on all cmdlets, including `Get-CafResourceType` itself (previously just `-Slug`). On `Get-CafResourceName`/`Test-CafResourceName`, `-Resource` can now also be used on its own to identify the resource - every friendly name in the data is unique, so e.g. `-Resource 'Key vault'` resolves without needing `-ResourceType`/`-Alias` at all; `-ResourceType` takes precedence if more than one of the three happens to be specified (e.g. by piping in an object with all three properties).
* Tab completion for `-ResourceType`/`-Alias`/`-Resource` is registered in the module file itself rather than via the `[ArgumentCompleter(...)]` parameter attribute, since an attribute-scriptblock isn't bound to the module's session state and silently failed to see the module's private functions (falling back to file-path completion). The `-Resource` completer narrows its suggestions to whichever `-ResourceType`/`-Alias` has already been typed on the line.
* Added `AzureCAF/resourceDefinition.json`, a curated data set of CAF naming rules keyed by ARM resource type, and `Build/Update-ResourceDefinition.ps1` to report on upstream changes to maintain it over time.
