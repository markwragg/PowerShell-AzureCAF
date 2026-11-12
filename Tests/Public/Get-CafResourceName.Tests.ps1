BeforeAll {
    if (-not $env:BHProjectName) {
        $env:BHProjectName = (Get-ChildItem "$PSScriptRoot\..\..\*.psm1" -Recurse).BaseName
    }

    Get-Module $env:BHProjectName | Remove-Module -Force -ErrorAction Ignore
    Import-Module (Join-Path "$PSScriptRoot\..\.." $env:BHProjectName) -Force
}

Describe 'Get-CafResourceName' {
    # Get-CafResourceName is a thin wrapper around New-CafResourceName that returns just the Name
    # string - the full generation behaviour (region/casing/trimming/instance numbers/random
    # suffixes/convention files/resource type resolution/etc.) is exercised exhaustively by
    # New-CafResourceName.Tests.ps1, so these tests only cover the wrapping itself.

    Context 'Returning a string' {

        It 'Returns a string rather than an object' {
            $Result = Get-CafResourceName -ResourceType 'Microsoft.Compute/virtualMachines' -Prefix 'contoso'
            $Result | Should -BeOfType [string]
            $Result | Should -Be 'contoso-vm'
        }

        It 'Matches the Name that New-CafResourceName produces for the same parameters' {
            $Params = @{
                ResourceType       = 'Microsoft.Storage/storageAccounts'
                Prefix             = 'contoso'
                RandomSuffixLength = 4
                RandomSuffixSeed   = 42
            }

            Get-CafResourceName @Params | Should -Be (New-CafResourceName @Params).Name
        }

        It 'Returns a bare string per result when -Count produces more than one name' {
            $Results = Get-CafResourceName -ResourceType 'Microsoft.Compute/virtualMachines' -Prefix 'contoso' -Count 3
            $Results | Should -Be @('contoso-vm-001', 'contoso-vm-002', 'contoso-vm-003')
            $Results | ForEach-Object { $_ | Should -BeOfType [string] }
        }
    }

    Context 'Forwarding parameters to New-CafResourceName' {

        It 'Forwards -ConventionPath defaults' {
            $ConventionPath = Join-Path $TestDrive 'convention.json'
            @{ Prefix = @('contoso', 'prod') } | ConvertTo-Json | Set-Content -Path $ConventionPath

            Get-CafResourceName -ResourceType 'Microsoft.Compute/virtualMachines' -ConventionPath $ConventionPath |
                Should -Be 'contoso-prod-vm'
        }

        It 'Accepts pipeline input by property name, same as New-CafResourceName' {
            $Items = @(
                [pscustomobject]@{ ResourceType = 'Microsoft.Compute/virtualMachines'; Prefix = 'contoso'; Suffix = '01' }
                [pscustomobject]@{ Alias = 'kv'; Prefix = 'contoso' }
            )

            $Results = $Items | Get-CafResourceName
            $Results | Should -Be @('contoso-vm-01', 'contoso-kv')
        }

        It 'Propagates a terminating error from New-CafResourceName' {
            { Get-CafResourceName -ResourceType 'Microsoft.Compute/virtualMachines' -Region 'doesnotexist' -ErrorAction Stop } |
                Should -Throw
        }

        It 'Accepts -RandomSuffixLength/-RandomSuffixSeed via their -Rsl/-Rss aliases' {
            Get-CafResourceName -ResourceType 'Microsoft.Storage/storageAccounts' -Prefix 'contoso' -Rsl 8 -Rss 42 |
                Should -Be (New-CafResourceName -ResourceType 'Microsoft.Storage/storageAccounts' -Prefix 'contoso' -RandomSuffixLength 8 -RandomSuffixSeed 42).Name
        }

        It 'Accepts -InstanceNumber/-InstanceNumberPadding via their -In/-Inp aliases' {
            Get-CafResourceName -ResourceType 'Microsoft.Compute/virtualMachines' -Prefix 'contoso' -In 1 -Inp 2 |
                Should -Be (New-CafResourceName -ResourceType 'Microsoft.Compute/virtualMachines' -Prefix 'contoso' -InstanceNumber 1 -InstanceNumberPadding 2).Name
        }

        It 'Accepts -TerraformResourceType, same as New-CafResourceName' {
            Get-CafResourceName -TerraformResourceType 'azurerm_storage_account' -Prefix 'contoso' |
                Should -Be (New-CafResourceName -TerraformResourceType 'azurerm_storage_account' -Prefix 'contoso').Name
        }
    }
}
