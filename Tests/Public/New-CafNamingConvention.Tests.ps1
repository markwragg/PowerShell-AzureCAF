BeforeAll {
    if (-not $env:BHProjectName) {
        $env:BHProjectName = (Get-ChildItem "$PSScriptRoot\..\..\*.psm1" -Recurse).BaseName
    }

    Get-Module $env:BHProjectName | Remove-Module -Force -ErrorAction Ignore
    Import-Module (Join-Path "$PSScriptRoot\..\.." $env:BHProjectName) -Force
}

Describe 'New-CafNamingConvention' {

    It 'Writes only the parameters that were specified' {
        $Path = Join-Path $TestDrive 'convention.json'
        New-CafNamingConvention -Path $Path -Prefix 'contoso', 'prod' -InstanceNumberPadding 2

        $Convention = Get-Content -Path $Path -Raw | ConvertFrom-Json
        $Convention.Prefix | Should -Be @('contoso', 'prod')
        $Convention.InstanceNumberPadding | Should -Be 2
        $Convention.PSObject.Properties.Name | Should -Not -Contain 'Suffix'
        $Convention.PSObject.Properties.Name | Should -Not -Contain 'Region'
        $Convention.PSObject.Properties.Name | Should -Not -Contain 'Separator'
        $Convention.PSObject.Properties.Name | Should -Not -Contain 'RandomSuffixLength'
    }

    It 'Produces a file Get-CafResourceName -ConventionPath can consume' {
        $Path = Join-Path $TestDrive 'roundtrip.json'
        New-CafNamingConvention -Path $Path -Prefix 'contoso' -RandomSuffixLength 4

        Get-CafResourceName -ResourceType 'Microsoft.Compute/virtualMachines' -ConventionPath $Path -RandomSuffixSeed 1 |
            Should -Be 'contoso-vm-idq1'
    }

    It 'Refuses to overwrite an existing file without -Force' {
        $Path = Join-Path $TestDrive 'existing.json'
        New-CafNamingConvention -Path $Path -Prefix 'contoso'

        { New-CafNamingConvention -Path $Path -Prefix 'fabrikam' -ErrorAction Stop } | Should -Throw
    }

    It 'Overwrites an existing file with -Force' {
        $Path = Join-Path $TestDrive 'overwrite.json'
        New-CafNamingConvention -Path $Path -Prefix 'contoso'
        New-CafNamingConvention -Path $Path -Prefix 'fabrikam' -Force

        (Get-Content -Path $Path -Raw | ConvertFrom-Json).Prefix | Should -Be 'fabrikam'
    }

    It 'Does not write the file when -WhatIf is specified' {
        $Path = Join-Path $TestDrive 'whatif.json'
        New-CafNamingConvention -Path $Path -Prefix 'contoso' -WhatIf

        Test-Path -Path $Path | Should -BeFalse
    }

    It 'Errors when no convention values are specified' {
        $Path = Join-Path $TestDrive 'empty.json'
        { New-CafNamingConvention -Path $Path -ErrorAction Stop } | Should -Throw
    }

    Context 'Region' {

        It 'Resolves and normalizes -Region to its ARM name' {
            $Path = Join-Path $TestDrive 'region.json'
            New-CafNamingConvention -Path $Path -Region 'East US'

            (Get-Content -Path $Path -Raw | ConvertFrom-Json).Region | Should -Be 'eastus'
        }

        It 'Accepts the slug as a -Region value' {
            $Path = Join-Path $TestDrive 'region-slug.json'
            New-CafNamingConvention -Path $Path -Region 'eus'

            (Get-Content -Path $Path -Raw | ConvertFrom-Json).Region | Should -Be 'eastus'
        }

        It 'Errors rather than saving an unrecognized region' {
            $Path = Join-Path $TestDrive 'region-invalid.json'
            { New-CafNamingConvention -Path $Path -Region 'doesnotexist' -ErrorAction Stop } | Should -Throw
            Test-Path -Path $Path | Should -BeFalse
        }

        It 'Flows through to Get-CafResourceName -ConventionPath' {
            $Path = Join-Path $TestDrive 'region-roundtrip.json'
            New-CafNamingConvention -Path $Path -Prefix 'contoso' -Region 'eastus'

            Get-CafResourceName -ResourceType 'Microsoft.Compute/virtualMachines' -ConventionPath $Path |
                Should -Be 'contoso-vm-eus'
        }
    }
}
