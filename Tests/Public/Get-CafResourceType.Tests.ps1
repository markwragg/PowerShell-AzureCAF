BeforeAll {
    if (-not $env:BHProjectName) {
        $env:BHProjectName = (Get-ChildItem "$PSScriptRoot\..\..\*.psm1" -Recurse).BaseName
    }

    Get-Module $env:BHProjectName | Remove-Module -Force -ErrorAction Ignore
    Import-Module (Join-Path "$PSScriptRoot\..\.." $env:BHProjectName) -Force
}

Describe 'Get-CafResourceType' {

    It 'Returns every known resource type when called with no parameters' {
        (Get-CafResourceType).Count | Should -BeGreaterThan 100
    }

    It 'Finds an exact resource type' {
        $Result = Get-CafResourceType -ResourceType 'Microsoft.Compute/virtualMachines'
        $Result.Slug | Should -Be 'vm'
    }

    It 'Supports wildcards on ResourceType' {
        $Result = Get-CafResourceType -ResourceType '*virtualMachine*'
        $Result.Count | Should -BeGreaterOrEqual 2
        $Result.ResourceType | Should -Contain 'Microsoft.Compute/virtualMachines'
        $Result.ResourceType | Should -Contain 'Microsoft.Compute/virtualMachineScaleSets'
    }

    It 'Matches ResourceType as a substring without requiring explicit wildcards' {
        $Result = Get-CafResourceType -ResourceType 'storageAccount'
        $Result.ResourceType | Should -Contain 'Microsoft.Storage/storageAccounts'
    }

    It 'Matches Resource as a substring without requiring explicit wildcards' {
        $Result = Get-CafResourceType -Resource 'vault'
        $Result.Resource | Should -Contain 'Key vault'
    }

    It 'Prefers an exact ResourceType match over a partial one that would otherwise also match' {
        # Case-insensitively, 'Microsoft.Compute/virtualMachines' is also a substring of
        # 'Microsoft.Compute/virtualMachineScaleSets' ('machineS' matches 'machines').
        $Result = Get-CafResourceType -ResourceType 'Microsoft.Compute/virtualMachines'
        $Result.ResourceType | Should -Be 'Microsoft.Compute/virtualMachines'
    }

    It 'Finds resource types by alias' {
        $Result = Get-CafResourceType -Alias 'kv'
        $Result.ResourceType | Should -Be 'Microsoft.KeyVault/vaults'
    }

    It 'Finds resource types by the -Slug alias' {
        $Result = Get-CafResourceType -Slug 'kv'
        $Result.ResourceType | Should -Be 'Microsoft.KeyVault/vaults'
    }

    It 'Finds resource types by friendly resource name' {
        $Result = Get-CafResourceType -Resource 'Key vault'
        $Result.Slug | Should -Be 'kv'
    }

    It 'Returns the naming rule fields needed by Get-CafResourceName' {
        $Result = Get-CafResourceType -Slug 'st'
        $Result.MinLength | Should -Be 3
        $Result.MaxLength | Should -Be 24
        $Result.Lowercase | Should -BeTrue
        $Result.Dashes | Should -BeFalse
    }

    It 'Returns multiple rows when a resource type is used by more than one kind of resource' {
        $Result = Get-CafResourceType -ResourceType 'Microsoft.Web/sites'
        $Result.Count | Should -Be 2
        $Result.Resource | Should -Contain 'Web app'
        $Result.Resource | Should -Contain 'Function app'
    }

    It 'Returns nothing for a resource type that does not exist' {
        Get-CafResourceType -ResourceType 'Microsoft.DoesNotExist/thing' | Should -BeNullOrEmpty
    }

    It 'Finds resource types by Terraform resource type' {
        $Result = Get-CafResourceType -TerraformResourceType 'azurerm_storage_account'
        $Result.ResourceType | Should -Be 'Microsoft.Storage/storageAccounts'
    }

    It 'Finds resource types by Terraform resource type via the -Tf alias' {
        $Result = Get-CafResourceType -Tf 'azurerm_storage_account'
        $Result.ResourceType | Should -Be 'Microsoft.Storage/storageAccounts'
    }

    It 'Matches TerraformResourceType as a substring without requiring explicit wildcards' {
        $Result = Get-CafResourceType -TerraformResourceType 'storage_account'
        $Result.TerraformResourceType | Should -Contain 'azurerm_storage_account'
    }

    It 'Returns nothing for a Terraform resource type that does not exist' {
        Get-CafResourceType -TerraformResourceType 'azurerm_does_not_exist' | Should -BeNullOrEmpty
    }

    It 'Returns $null TerraformResourceType for a resource type Terraform does not model distinctly' {
        $Result = Get-CafResourceType -ResourceType 'Microsoft.Blockchain/blockchainMembers'
        $Result.TerraformResourceType | Should -BeNullOrEmpty
    }

    Context 'Resource types with more than one real Terraform equivalent' {

        It 'Returns an array of every real equivalent for a resource type Terraform splits by OS' {
            $Result = Get-CafResourceType -ResourceType 'Microsoft.Compute/virtualMachines'
            $Result.TerraformResourceType | Should -Be @('azurerm_linux_virtual_machine', 'azurerm_windows_virtual_machine')
        }

        It 'Resolves by any one of the array values' {
            (Get-CafResourceType -TerraformResourceType 'azurerm_windows_virtual_machine').ResourceType |
                Should -Be 'Microsoft.Compute/virtualMachines'
        }
    }

    Context 'Data integrity' {

        It 'Never returns a ResourceType with a stray (kind: ...)/(mode: ...) annotation baked in' {
            # The CAF abbreviation guide sometimes shows the ARM type with a trailing qualifier, e.g.
            # 'Microsoft.CognitiveServices/accounts (kind: ComputerVision)' - that's not a valid ARM
            # type and would make -ResourceType/tab-completion unusable if it ever leaked into the
            # shipped data (see Build/Update-ResourceDefinition.ps1's handling of it).
            (Get-CafResourceType).ResourceType | Should -Not -Match '\((?:kind|mode):'
        }
    }
}
