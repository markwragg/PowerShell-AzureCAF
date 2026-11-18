BeforeAll {
    if (-not $env:BHProjectName) {
        $env:BHProjectName = (Get-ChildItem "$PSScriptRoot\..\..\*.psm1" -Recurse).BaseName
    }

    Get-Module $env:BHProjectName | Remove-Module -Force -ErrorAction Ignore
    Import-Module (Join-Path "$PSScriptRoot\..\.." $env:BHProjectName) -Force
}

Describe 'Select-CafMatch' {

    BeforeAll {
        $Items = @(
            [pscustomobject]@{ Name = 'Microsoft.Compute/virtualMachines' }
            [pscustomobject]@{ Name = 'Microsoft.Compute/virtualMachineScaleSets' }
            [pscustomobject]@{ Name = 'Microsoft.Storage/storageAccounts' }
        )
    }

    It 'Returns only the exact match when the value is also a substring of another item' {
        InModuleScope AzureCAF -Parameters @{ Items = $Items } {
            $Result = Select-CafMatch -InputObject $Items -Property Name -Value 'Microsoft.Compute/virtualMachines'
            @($Result).Count | Should -Be 1
            $Result[0].Name | Should -Be 'Microsoft.Compute/virtualMachines'
        }
    }

    It 'Matches exactly without regard to case' {
        InModuleScope AzureCAF -Parameters @{ Items = $Items } {
            $Result = Select-CafMatch -InputObject $Items -Property Name -Value 'microsoft.compute/virtualmachines'
            @($Result).Count | Should -Be 1
        }
    }

    It 'Falls back to a substring match when nothing matches exactly' {
        InModuleScope AzureCAF -Parameters @{ Items = $Items } {
            $Result = Select-CafMatch -InputObject $Items -Property Name -Value 'virtualMachine'
            @($Result).Count | Should -Be 2
        }
    }

    It 'Honours an explicit wildcard pattern' {
        InModuleScope AzureCAF -Parameters @{ Items = $Items } {
            $Result = Select-CafMatch -InputObject $Items -Property Name -Value 'Microsoft.Storage/*'
            @($Result).Count | Should -Be 1
            $Result[0].Name | Should -Be 'Microsoft.Storage/storageAccounts'
        }
    }

    It 'Returns an empty array when nothing matches' {
        InModuleScope AzureCAF -Parameters @{ Items = $Items } {
            $Result = Select-CafMatch -InputObject $Items -Property Name -Value 'doesnotexist'
            @($Result).Count | Should -Be 0
        }
    }

    It 'Matches against an array-valued property' {
        InModuleScope AzureCAF {
            $Items = @(
                [pscustomobject]@{ Tf = @('azurerm_linux_virtual_machine', 'azurerm_windows_virtual_machine') }
                [pscustomobject]@{ Tf = 'azurerm_storage_account' }
            )
            $Result = Select-CafMatch -InputObject $Items -Property Tf -Value 'azurerm_windows_virtual_machine'
            @($Result).Count | Should -Be 1
            $Result[0].Tf | Should -Contain 'azurerm_linux_virtual_machine'
        }
    }
}
