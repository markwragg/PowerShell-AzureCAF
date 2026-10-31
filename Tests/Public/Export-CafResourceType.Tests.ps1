BeforeAll {
    if (-not $env:BHProjectName) {
        $env:BHProjectName = (Get-ChildItem "$PSScriptRoot\..\..\*.psm1" -Recurse).BaseName
    }

    Get-Module $env:BHProjectName | Remove-Module -Force -ErrorAction Ignore
    Import-Module (Join-Path "$PSScriptRoot\..\.." $env:BHProjectName) -Force
}

Describe 'Export-CafResourceType' {

    Context 'CSV export' {

        It 'Exports every resource type when nothing is piped in' {
            $Path = Join-Path $TestDrive 'all.csv'
            Export-CafResourceType -Path $Path

            (Import-Csv -Path $Path).Count | Should -Be (Get-CafResourceType).Count
        }

        It 'Exports only the piped-in subset' {
            $Path = Join-Path $TestDrive 'kv.csv'
            Get-CafResourceType -Alias 'kv' | Export-CafResourceType -Path $Path

            $Rows = @(Import-Csv -Path $Path)
            $Rows | Should -HaveCount 1
            $Rows[0].ResourceType | Should -Be 'Microsoft.KeyVault/vaults'
            $Rows[0].Slug | Should -Be 'kv'
        }
    }

    Context 'Markdown export' {

        It 'Writes a Markdown table with a header, separator and one row per item' {
            $Path = Join-Path $TestDrive 'kv.md'
            Get-CafResourceType -Alias 'kv' | Export-CafResourceType -Path $Path

            $Lines = Get-Content -Path $Path
            $Lines[0] | Should -Match '^\| ResourceType \| Resource \|'
            $Lines[1] | Should -Match '^\| --- \| --- \|'
            $Lines[2] | Should -Match 'Microsoft\.KeyVault/vaults'
            $Lines.Count | Should -Be 3
        }

        It 'Accepts a .markdown extension too' {
            $Path = Join-Path $TestDrive 'kv.markdown'
            Get-CafResourceType -Alias 'kv' | Export-CafResourceType -Path $Path

            Test-Path -Path $Path | Should -BeTrue
        }

        It 'Escapes a pipe character in a cell value so the table stays well-formed' {
            $Path = Join-Path $TestDrive 'escaped.md'
            [pscustomobject]@{
                ResourceType = 'Microsoft.Test/thing'
                Resource     = 'Has | a pipe'
                Slug         = 'tp'
                Scope        = 'global'
                MinLength    = 1
                MaxLength    = 10
                Lowercase    = $false
                Dashes       = $true
            } | Export-CafResourceType -Path $Path

            (Get-Content -Path $Path)[2] | Should -Match 'Has \\\| a pipe'
        }
    }

    Context 'Validation' {

        It 'Errors for an unsupported file extension' {
            $Path = Join-Path $TestDrive 'all.txt'
            { Export-CafResourceType -Path $Path -ErrorAction Stop } | Should -Throw
        }

        It 'Refuses to overwrite an existing file without -Force' {
            $Path = Join-Path $TestDrive 'existing.csv'
            Export-CafResourceType -Path $Path
            { Export-CafResourceType -Path $Path -ErrorAction Stop } | Should -Throw
        }

        It 'Overwrites an existing file with -Force' {
            $Path = Join-Path $TestDrive 'overwrite.csv'
            Export-CafResourceType -Path $Path
            { Get-CafResourceType -Alias 'kv' | Export-CafResourceType -Path $Path -Force -ErrorAction Stop } | Should -Not -Throw
            @(Import-Csv -Path $Path).Count | Should -Be 1
        }

        It 'Does not write the file when -WhatIf is specified' {
            $Path = Join-Path $TestDrive 'whatif.csv'
            Export-CafResourceType -Path $Path -WhatIf

            Test-Path -Path $Path | Should -BeFalse
        }
    }
}
