BeforeAll {
    if (-not $env:BHProjectName) {
        $env:BHProjectName = (Get-ChildItem "$PSScriptRoot\..\..\*.psm1" -Recurse).BaseName
    }

    Get-Module $env:BHProjectName | Remove-Module -Force -ErrorAction Ignore
    Import-Module (Join-Path "$PSScriptRoot\..\.." $env:BHProjectName) -Force
}

Describe 'Get-CafRegion' {

    It 'Returns every known region when called with no parameters' {
        (Get-CafRegion).Count | Should -BeGreaterThan 50
    }

    It 'Finds an exact region by ARM name' {
        $Result = Get-CafRegion -Region 'eastus'
        $Result.Slug | Should -Be 'eus'
    }

    It 'Finds a region by its display name' {
        $Result = Get-CafRegion -Region 'East US'
        $Result.Slug | Should -Be 'eus'
    }

    It 'Finds a region by its slug' {
        $Result = Get-CafRegion -Region 'eus'
        $Result.Region | Should -Be 'eastus'
    }

    It 'Matches the slug exactly rather than finding it ambiguous as a substring of other regions'' ARM names' {
        # 'ae' is Australia East's slug, but also a substring of 'canadaeast' and 'israelcentral'.
        $Result = Get-CafRegion -Region 'ae'
        $Result.Region | Should -Be 'australiaeast'
    }

    It 'Matches as a substring without requiring explicit wildcards' {
        $Result = Get-CafRegion -Region 'us2eu'
        $Result.Region | Should -Be 'eastus2euap'
    }

    It 'Prefers an exact ARM name match over a partial one that would otherwise also match' {
        # Case-insensitively, 'eastus' is also a substring of 'eastus2' and 'eastus2euap'.
        $Result = Get-CafRegion -Region 'eastus'
        $Result.Region | Should -Be 'eastus'
    }

    It 'Returns nothing for a region that does not exist' {
        Get-CafRegion -Region 'doesnotexist' | Should -BeNullOrEmpty
    }

    Context 'PairedRegion' {

        It 'Includes the Azure-paired region when one exists' {
            $Result = Get-CafRegion -Region 'eastus'
            $Result.PairedRegion | Should -Be 'westus'
        }

        It 'Is null for a region that does not have a paired region' {
            $Result = Get-CafRegion -Region 'swedencentral'
            $Result.PairedRegion | Should -BeNullOrEmpty
        }
    }
}
