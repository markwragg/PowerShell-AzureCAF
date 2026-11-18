BeforeAll {
    if (-not $env:BHProjectName) {
        $env:BHProjectName = (Get-ChildItem "$PSScriptRoot\..\..\*.psm1" -Recurse).BaseName
    }

    Get-Module $env:BHProjectName | Remove-Module -Force -ErrorAction Ignore
    Import-Module (Join-Path "$PSScriptRoot\..\.." $env:BHProjectName) -Force
}

Describe 'Get-CafWildcardPattern' {

    It 'Wraps a plain value in leading and trailing wildcards' {
        InModuleScope AzureCAF {
            Get-CafWildcardPattern -Value 'virtualMachines' | Should -BeExactly '*virtualMachines*'
        }
    }

    It 'Returns a value containing <Character> unchanged' -ForEach @(
        @{ Character = '*'; Value = '*storageAccount*' }
        @{ Character = '?'; Value = 'disk?' }
        @{ Character = '['; Value = 'vm[0-9]' }
        @{ Character = ']'; Value = 'vm]' }
    ) {
        InModuleScope AzureCAF -Parameters @{ Value = $Value } {
            Get-CafWildcardPattern -Value $Value | Should -BeExactly $Value
        }
    }

    It 'Turns an empty string into a match-everything pattern' {
        InModuleScope AzureCAF {
            Get-CafWildcardPattern -Value '' | Should -BeExactly '**'
        }
    }

    It 'Produces a pattern that matches the value as a substring' {
        InModuleScope AzureCAF {
            $Pattern = Get-CafWildcardPattern -Value 'virtualMachines'
            'Microsoft.Compute/virtualMachines' -like $Pattern | Should -BeTrue
            'Microsoft.Storage/storageAccounts' -like $Pattern | Should -BeFalse
        }
    }
}
