BeforeAll {
    if (-not $env:BHProjectName) {
        $env:BHProjectName = (Get-ChildItem "$PSScriptRoot\..\..\*.psm1" -Recurse).BaseName
    }

    Get-Module $env:BHProjectName | Remove-Module -Force -ErrorAction Ignore
    Import-Module (Join-Path "$PSScriptRoot\..\.." $env:BHProjectName) -Force
}

Describe 'Test-CafResourceName' {

    Context 'A valid name' {

        It 'Reports IsValid and every rule as true' {
            $Result = Test-CafResourceName -Name 'contoso-prod-vm-001' -ResourceType 'Microsoft.Compute/virtualMachines'
            $Result.IsValid | Should -BeTrue
            $Result.MinLength | Should -BeTrue
            $Result.MaxLength | Should -BeTrue
            $Result.Casing | Should -BeTrue
            $Result.Dashes | Should -BeTrue
            $Result.ValidCharacters | Should -BeTrue
        }

        It 'Includes the resolved ResourceType and Resource on the result' {
            $Result = Test-CafResourceName -Name 'contoso-vm' -Alias 'vm'
            $Result.ResourceType | Should -Be 'Microsoft.Compute/virtualMachines'
            $Result.Resource | Should -Be 'Virtual machine'
        }

        It 'Has a null Reason' {
            (Test-CafResourceName -Name 'contoso-vm' -Alias 'vm').Reason | Should -BeNullOrEmpty
        }
    }

    Context 'Individual rule failures' {

        It 'Fails MinLength for a name shorter than the minimum' {
            $Result = Test-CafResourceName -Name 'ab' -ResourceType 'Microsoft.Storage/storageAccounts'
            $Result.MinLength | Should -BeFalse
            $Result.IsValid | Should -BeFalse
        }

        It 'Fails MaxLength for a name longer than the maximum' {
            $Result = Test-CafResourceName -Name ('a' * 30) -ResourceType 'Microsoft.Storage/storageAccounts'
            $Result.MaxLength | Should -BeFalse
            $Result.IsValid | Should -BeFalse
        }

        It 'Fails Casing (and IsValid) for an uppercase name when lowercase is required' {
            $Result = Test-CafResourceName -Name 'CONTOSO' -ResourceType 'Microsoft.Storage/storageAccounts'
            $Result.Casing | Should -BeFalse
            $Result.ValidCharacters | Should -BeFalse
            $Result.IsValid | Should -BeFalse
        }

        It 'Fails Dashes (and ValidCharacters) for a hyphen where the resource type does not allow one' {
            $Result = Test-CafResourceName -Name 'contoso-st' -ResourceType 'Microsoft.Storage/storageAccounts'
            $Result.Dashes | Should -BeFalse
            $Result.ValidCharacters | Should -BeFalse
            $Result.IsValid | Should -BeFalse
        }

        It 'Fails ValidCharacters for a disallowed character' {
            $Result = Test-CafResourceName -Name 'contoso!' -ResourceType 'Microsoft.Storage/storageAccounts'
            $Result.ValidCharacters | Should -BeFalse
            $Result.IsValid | Should -BeFalse
        }
    }

    Context 'Reason' {

        It 'Explains a too-short name' {
            (Test-CafResourceName -Name 'ab' -ResourceType 'Microsoft.Storage/storageAccounts').Reason |
                Should -Be 'Name is 2 characters, which is shorter than the 3 character minimum.'
        }

        It 'Explains a too-long name, including how far over the limit it is' {
            (Test-CafResourceName -Name ('a' * 30) -ResourceType 'Microsoft.Storage/storageAccounts').Reason |
                Should -Be 'Name is 30 characters, which exceeds the 24 character maximum by 6.'
        }

        It 'Explains a casing failure' {
            (Test-CafResourceName -Name 'CONTOSO' -ResourceType 'Microsoft.Storage/storageAccounts').Reason |
                Should -Match 'must be all lowercase'
        }

        It 'Explains a dash failure' {
            (Test-CafResourceName -Name 'contoso-st' -ResourceType 'Microsoft.Storage/storageAccounts').Reason |
                Should -Match "contains a dash"
        }

        It 'Combines multiple reasons when more than one rule fails' {
            $Reason = (Test-CafResourceName -Name 'CONTOSO!' -ResourceType 'Microsoft.Storage/storageAccounts').Reason
            $Reason | Should -Match 'must be all lowercase'
            $Reason | Should -Match 'not allowed'
        }

        It 'Is null when the name is valid' {
            (Test-CafResourceName -Name 'contoso-vm' -Alias 'vm').Reason | Should -BeNullOrEmpty
        }
    }

    Context 'Known breakdown limitation' {

        It 'Can report ValidCharacters false while IsValid is true, for a character only disallowed in one position' {
            # 'Microsoft.Compute/virtualMachines' blocks '_' unconditionally in its character-cleaning
            # pattern, but its validation pattern only disallows '_' as the very first character - so
            # an underscore elsewhere is flagged by -ValidCharacters but doesn't fail -IsValid. This is
            # a documented limitation of the per-rule breakdown; IsValid remains authoritative.
            $Result = Test-CafResourceName -Name 'Contoso_VM' -ResourceType 'Microsoft.Compute/virtualMachines'
            $Result.ValidCharacters | Should -BeFalse
            $Result.IsValid | Should -BeTrue
        }
    }

    Context '-Quiet' {

        It 'Returns only a boolean for a valid name' {
            $Result = Test-CafResourceName -Name 'contoso-vm' -Alias 'vm' -Quiet
            $Result | Should -BeOfType [bool]
            $Result | Should -BeTrue
        }

        It 'Returns only a boolean for an invalid name' {
            $Result = Test-CafResourceName -Name 'CONTOSO' -ResourceType 'Microsoft.Storage/storageAccounts' -Quiet
            $Result | Should -BeOfType [bool]
            $Result | Should -BeFalse
        }
    }

    Context 'Resource type resolution' {

        It 'Resolves by -Alias and its -Slug alias' {
            (Test-CafResourceName -Name 'contoso-vmss' -Alias 'vmss').IsValid | Should -BeTrue
            (Test-CafResourceName -Name 'contoso-vmss' -Slug 'vmss').IsValid | Should -BeTrue
        }

        It 'Errors for an unknown resource type' {
            { Test-CafResourceName -Name 'contoso' -ResourceType 'Microsoft.DoesNotExist/thing' -ErrorAction Stop } | Should -Throw
        }

        It 'Errors when the resource type is ambiguous and -Resource is not specified' {
            { Test-CafResourceName -Name 'contoso-func' -ResourceType 'Microsoft.Web/sites' -ErrorAction Stop } | Should -Throw
        }

        It 'Resolves an ambiguous resource type when -Resource is specified' {
            (Test-CafResourceName -Name 'contoso-func' -ResourceType 'Microsoft.Web/sites' -Resource 'Function app').IsValid | Should -BeTrue
        }

        It 'Resolves by a unique -Resource friendly name alone' {
            (Test-CafResourceName -Name 'contoso-kv' -Resource 'Key vault').IsValid | Should -BeTrue
        }

        It 'Errors when none of -ResourceType, -Alias or -Resource are specified' {
            { Test-CafResourceName -Name 'contoso' -ErrorAction Stop } | Should -Throw
        }
    }

    Context 'Pipeline input' {

        It 'Accepts the name by value from the pipeline' {
            ('contoso-vm' | Test-CafResourceName -Alias 'vm').IsValid | Should -BeTrue
        }

        It 'Accepts the resource type by property name from Get-CafResourceType' {
            $Result = Get-CafResourceType -Slug 'kv' | Test-CafResourceName -Name 'contoso-kv'
            $Result.IsValid | Should -BeTrue
            $Result.ResourceType | Should -Be 'Microsoft.KeyVault/vaults'
        }

        It 'Round-trips a name generated by Get-CafResourceName back through Test-CafResourceName' {
            $Generated = Get-CafResourceName -ResourceType 'Microsoft.Storage/storageAccounts' -Prefix 'contoso' -RandomSuffixLength 6
            Test-CafResourceName -Name $Generated -ResourceType 'Microsoft.Storage/storageAccounts' -Quiet | Should -BeTrue
        }
    }
}
