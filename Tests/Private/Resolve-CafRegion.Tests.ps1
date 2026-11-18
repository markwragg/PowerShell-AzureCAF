BeforeAll {
    if (-not $env:BHProjectName) {
        $env:BHProjectName = (Get-ChildItem "$PSScriptRoot\..\..\*.psm1" -Recurse).BaseName
    }

    Get-Module $env:BHProjectName | Remove-Module -Force -ErrorAction Ignore
    Import-Module (Join-Path "$PSScriptRoot\..\.." $env:BHProjectName) -Force
}

Describe 'Resolve-CafRegion' {

    Context 'With controlled region definitions' {

        BeforeAll {
            Mock -ModuleName AzureCAF Get-CafRegionDefinition {
                @(
                    [pscustomobject]@{ Region = 'eastus'; DisplayName = 'East US'; Slug = 'eus' }
                    [pscustomobject]@{ Region = 'eastus2'; DisplayName = 'East US 2'; Slug = 'eus2' }
                    [pscustomobject]@{ Region = 'westeurope'; DisplayName = 'West Europe'; Slug = 'weu' }
                    [pscustomobject]@{ Region = 'canadaeast'; DisplayName = 'Canada East'; Slug = 'cne' }
                    [pscustomobject]@{ Region = 'australiaeast'; DisplayName = 'Australia East'; Slug = 'ae' }
                    [pscustomobject]@{ Region = 'contosoxyz'; DisplayName = 'Fabrikam Display Only'; Slug = 'fdo' }
                )
            }
        }

        It 'Resolves an exact match on the <Field>' -ForEach @(
            @{ Field = 'ARM region name'; Value = 'eastus' }
            @{ Field = 'display name'; Value = 'East US' }
            @{ Field = 'slug'; Value = 'eus' }
            @{ Field = 'ARM region name in a different case'; Value = 'EASTUS' }
        ) {
            InModuleScope AzureCAF -Parameters @{ Value = $Value } {
                (Resolve-CafRegion -Region $Value).Region | Should -Be 'eastus'
            }
        }

        It 'Prefers an exact slug match over a substring match in other ARM names' {
            # 'ae' is also a substring of 'canadaeast', but is Australia East's exact slug.
            InModuleScope AzureCAF {
                (Resolve-CafRegion -Region 'ae').Region | Should -Be 'australiaeast'
            }
        }

        It 'Falls back to a substring match on the ARM region name' {
            InModuleScope AzureCAF {
                (Resolve-CafRegion -Region 'westeur').Region | Should -Be 'westeurope'
            }
        }

        It 'Falls back to a substring match on the display name when no ARM name matches' {
            InModuleScope AzureCAF {
                (Resolve-CafRegion -Region 'Fabrikam').Region | Should -Be 'contosoxyz'
            }
        }

        It 'Does not substring match on the slug' {
            InModuleScope AzureCAF {
                Resolve-CafRegion -Region 'fd' -ErrorVariable Err -ErrorAction SilentlyContinue | Should -BeNullOrEmpty
                $Err[0] | Should -Match "No Azure region matches 'fd'"
            }
        }

        It 'Writes an error and returns nothing for an unknown region' {
            InModuleScope AzureCAF {
                Resolve-CafRegion -Region 'nowhere' -ErrorVariable Err -ErrorAction SilentlyContinue | Should -BeNullOrEmpty
                $Err[0] | Should -Match "No Azure region matches 'nowhere'"
            }
        }

        It 'Writes an error listing the candidates for an ambiguous region' {
            InModuleScope AzureCAF {
                Resolve-CafRegion -Region 'eastu' -ErrorVariable Err -ErrorAction SilentlyContinue | Should -BeNullOrEmpty
                $Err[0] | Should -Match "'eastu' matches more than one Azure region"
                $Err[0] | Should -Match ([regex]::Escape('eastus [East US]'))
                $Err[0] | Should -Match ([regex]::Escape('eastus2 [East US 2]'))
            }
        }

        It 'Writes a non-terminating error' {
            InModuleScope AzureCAF {
                { Resolve-CafRegion -Region 'nowhere' -ErrorAction SilentlyContinue } | Should -Not -Throw
            }
        }
    }

    Context 'With the real region definitions' {

        It 'Resolves <Value> to <Expected>' -ForEach @(
            @{ Value = 'uksouth'; Expected = 'uksouth' }
            @{ Value = 'East US 2'; Expected = 'eastus2' }
            @{ Value = 'ae'; Expected = 'australiaeast' }
        ) {
            InModuleScope AzureCAF -Parameters @{ Value = $Value; Expected = $Expected } {
                (Resolve-CafRegion -Region $Value).Region | Should -Be $Expected
            }
        }
    }
}
