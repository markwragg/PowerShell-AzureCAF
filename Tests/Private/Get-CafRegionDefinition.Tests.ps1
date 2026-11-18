BeforeAll {
    if (-not $env:BHProjectName) {
        $env:BHProjectName = (Get-ChildItem "$PSScriptRoot\..\..\*.psm1" -Recurse).BaseName
    }

    Get-Module $env:BHProjectName | Remove-Module -Force -ErrorAction Ignore
    Import-Module (Join-Path "$PSScriptRoot\..\.." $env:BHProjectName) -Force
}

Describe 'Get-CafRegionDefinition' {

    AfterEach {
        # Clear the cache so later tests (and other files) reload the real data.
        InModuleScope AzureCAF { $Script:CafRegionDefinitions = $null }
    }

    It 'Loads every entry from regionDefinition.json' {
        InModuleScope AzureCAF {
            $Script:CafRegionDefinitions = $null
            $Expected = Get-Content -Path $Script:RegionDefinitionPath -Raw | ConvertFrom-Json

            $Result = @(Get-CafRegionDefinition)
            $Result.Count | Should -Be $Expected.Count
            $Result.Count | Should -BeGreaterThan 0
        }
    }

    It 'Returns entries with the expected properties' {
        InModuleScope AzureCAF {
            $Properties = (Get-CafRegionDefinition)[0].PSObject.Properties.Name
            foreach ($Property in @('Region', 'DisplayName', 'Slug')) {
                $Properties | Should -Contain $Property
            }
        }
    }

    It 'Reads the file only once and serves later calls from the cache' {
        InModuleScope AzureCAF {
            $Script:CafRegionDefinitions = $null
            Mock Get-Content { '[{"Name":"one"},{"Name":"two"}]' }

            $null = Get-CafRegionDefinition
            $Result = @(Get-CafRegionDefinition)

            Should -Invoke Get-Content -Times 1 -Exactly
            $Result.Count | Should -Be 2
        }
    }

    It 'Returns the already-cached definitions without touching the file' {
        InModuleScope AzureCAF {
            $Script:CafRegionDefinitions = @([pscustomobject]@{ Name = 'cached' })
            Mock Get-Content { throw 'should not be called' }

            (Get-CafRegionDefinition).Name | Should -Be 'cached'
            Should -Invoke Get-Content -Times 0 -Exactly
        }
    }
}
