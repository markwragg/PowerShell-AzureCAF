BeforeAll {
    if (-not $env:BHProjectName) {
        $env:BHProjectName = (Get-ChildItem "$PSScriptRoot\..\..\*.psm1" -Recurse).BaseName
    }

    Get-Module $env:BHProjectName | Remove-Module -Force -ErrorAction Ignore
    Import-Module (Join-Path "$PSScriptRoot\..\.." $env:BHProjectName) -Force
}

Describe 'Resolve-CafResourceDefinition' {

    Context 'With controlled resource definitions' {

        BeforeAll {
            Mock -ModuleName AzureCAF Get-CafResourceDefinition {
                @(
                    [pscustomobject]@{ ResourceType = 'Microsoft.Compute/virtualMachines'; Resource = 'Virtual machine'; Slug = 'vm'; TerraformResourceType = @('azurerm_linux_virtual_machine', 'azurerm_windows_virtual_machine') }
                    [pscustomobject]@{ ResourceType = 'Microsoft.Compute/virtualMachineScaleSets'; Resource = 'Virtual machine scale set'; Slug = 'vmss'; TerraformResourceType = 'azurerm_linux_virtual_machine_scale_set' }
                    [pscustomobject]@{ ResourceType = 'Microsoft.Web/sites'; Resource = 'Web app'; Slug = 'app'; TerraformResourceType = @('azurerm_linux_web_app', 'azurerm_windows_web_app') }
                    [pscustomobject]@{ ResourceType = 'Microsoft.Web/sites'; Resource = 'Function app'; Slug = 'func'; TerraformResourceType = @('azurerm_linux_function_app', 'azurerm_windows_function_app') }
                    [pscustomobject]@{ ResourceType = 'Microsoft.Cdn/profiles'; Resource = 'Front Door (Standard/Premium) profile'; Slug = 'afd'; TerraformResourceType = 'azurerm_cdn_frontdoor_profile' }
                    [pscustomobject]@{ ResourceType = 'Microsoft.Network/frontDoors'; Resource = 'Front Door (classic)'; Slug = 'afd'; TerraformResourceType = 'azurerm_frontdoor' }
                    [pscustomobject]@{ ResourceType = 'Microsoft.KeyVault/vaults'; Resource = 'Key vault'; Slug = 'kv'; TerraformResourceType = 'azurerm_key_vault' }
                    [pscustomobject]@{ ResourceType = 'Microsoft.KeyVault/managedHSMs'; Resource = 'Key Vault Managed HSM'; Slug = 'kvmhsm'; TerraformResourceType = $null }
                )
            }
        }

        Context 'Resolving by a single identifier' {

            It 'Resolves an exact -ResourceType even when it is a substring of another' {
                InModuleScope AzureCAF {
                    (Resolve-CafResourceDefinition -ResourceType 'Microsoft.Compute/virtualMachines').Slug | Should -Be 'vm'
                }
            }

            It 'Resolves a partial -ResourceType' {
                InModuleScope AzureCAF {
                    (Resolve-CafResourceDefinition -ResourceType 'vaults').Slug | Should -Be 'kv'
                }
            }

            It 'Resolves by -Alias' {
                InModuleScope AzureCAF {
                    (Resolve-CafResourceDefinition -Alias 'func').Resource | Should -Be 'Function app'
                }
            }

            It 'Resolves by -TerraformResourceType, including one of several values' {
                InModuleScope AzureCAF {
                    (Resolve-CafResourceDefinition -TerraformResourceType 'azurerm_windows_virtual_machine').Slug | Should -Be 'vm'
                }
            }

            It 'Resolves by -Resource on its own' {
                InModuleScope AzureCAF {
                    (Resolve-CafResourceDefinition -Resource 'Key vault').Slug | Should -Be 'kv'
                }
            }
        }

        Context 'Precedence and narrowing' {

            It 'Uses -ResourceType as primary and narrows with -Alias' {
                InModuleScope AzureCAF {
                    (Resolve-CafResourceDefinition -ResourceType 'Microsoft.Web/sites' -Alias 'func').Resource | Should -Be 'Function app'
                }
            }

            It 'Uses -Alias as primary and narrows with -Resource' {
                InModuleScope AzureCAF {
                    (Resolve-CafResourceDefinition -Alias 'afd' -Resource 'classic').ResourceType | Should -Be 'Microsoft.Network/frontDoors'
                }
            }

            It 'Uses -ResourceType as primary and narrows with -TerraformResourceType' {
                InModuleScope AzureCAF {
                    (Resolve-CafResourceDefinition -ResourceType 'Microsoft.Web/sites' -TerraformResourceType 'azurerm_linux_web_app').Slug | Should -Be 'app'
                }
            }

            It 'Uses -Alias as primary and narrows with -TerraformResourceType' {
                InModuleScope AzureCAF {
                    (Resolve-CafResourceDefinition -Alias 'afd' -TerraformResourceType 'azurerm_frontdoor').ResourceType | Should -Be 'Microsoft.Network/frontDoors'
                }
            }

            It 'Uses -TerraformResourceType as primary and narrows with -Resource' {
                InModuleScope AzureCAF {
                    (Resolve-CafResourceDefinition -TerraformResourceType 'web_app' -Resource 'Web app').Slug | Should -Be 'app'
                }
            }

            It 'Accepts every identifier at once when they agree (as when piped from Get-CafResourceType)' {
                InModuleScope AzureCAF {
                    $Result = Resolve-CafResourceDefinition -ResourceType 'Microsoft.KeyVault/vaults' -Alias 'kv' -Resource 'Key vault' -TerraformResourceType 'azurerm_key_vault'
                    $Result.Slug | Should -Be 'kv'
                }
            }
        }

        Context 'Errors' {

            It 'Writes an error naming the <Name> when nothing matches' -ForEach @(
                @{ Name = 'resource type'; Params = @{ ResourceType = 'Microsoft.Nope/things' }; Expected = "No resource type matches 'Microsoft.Nope/things'" }
                @{ Name = 'alias'; Params = @{ Alias = 'zzz' }; Expected = "No resource type matches alias 'zzz'" }
                @{ Name = 'terraform resource type'; Params = @{ TerraformResourceType = 'azurerm_nope' }; Expected = "No resource type matches terraform resource type 'azurerm_nope'" }
                @{ Name = 'resource'; Params = @{ Resource = 'Nope' }; Expected = "No resource type matches resource 'Nope'" }
            ) {
                InModuleScope AzureCAF -Parameters @{ Params = $Params; Expected = $Expected } {
                    Resolve-CafResourceDefinition @Params -ErrorVariable Err -ErrorAction SilentlyContinue | Should -BeNullOrEmpty
                    $Err[0] | Should -Match ([regex]::Escape($Expected))
                }
            }

            It 'Writes an error listing the options when -<Name> narrows a -ResourceType match to nothing' -ForEach @(
                @{ Name = 'Alias'; Params = @{ ResourceType = 'Microsoft.Web/sites'; Alias = 'kv' }; Expected = "'kv' doesn't match any resource for 'Microsoft.Web/sites'" }
                @{ Name = 'TerraformResourceType'; Params = @{ ResourceType = 'Microsoft.Web/sites'; TerraformResourceType = 'azurerm_key_vault' }; Expected = "'azurerm_key_vault' doesn't match any resource for 'Microsoft.Web/sites'" }
                @{ Name = 'Resource'; Params = @{ ResourceType = 'Microsoft.Web/sites'; Resource = 'Key vault' }; Expected = "'Key vault' doesn't match any resource for 'Microsoft.Web/sites'" }
            ) {
                InModuleScope AzureCAF -Parameters @{ Params = $Params; Expected = $Expected } {
                    Resolve-CafResourceDefinition @Params -ErrorVariable Err -ErrorAction SilentlyContinue | Should -BeNullOrEmpty
                    $Err[0] | Should -Match ([regex]::Escape($Expected))
                    $Err[0] | Should -Match ([regex]::Escape('Microsoft.Web/sites [Web app]'))
                    $Err[0] | Should -Match ([regex]::Escape('Microsoft.Web/sites [Function app]'))
                }
            }

            It 'Suggests -Resource when a -ResourceType is ambiguous' {
                InModuleScope AzureCAF {
                    Resolve-CafResourceDefinition -ResourceType 'Microsoft.Web/sites' -ErrorVariable Err -ErrorAction SilentlyContinue | Should -BeNullOrEmpty
                    $Err[0] | Should -Match ([regex]::Escape("'Microsoft.Web/sites' matches more than one resource type. Narrow it down with -Resource"))
                }
            }

            It 'Suggests -Resource when an -Alias is ambiguous' {
                InModuleScope AzureCAF {
                    Resolve-CafResourceDefinition -Alias 'afd' -ErrorVariable Err -ErrorAction SilentlyContinue | Should -BeNullOrEmpty
                    $Err[0] | Should -Match ([regex]::Escape("alias 'afd' matches more than one resource type. Narrow it down with -Resource"))
                }
            }

            It 'Suggests -ResourceType when a -Resource is ambiguous' {
                InModuleScope AzureCAF {
                    Resolve-CafResourceDefinition -Resource 'Front Door' -ErrorVariable Err -ErrorAction SilentlyContinue | Should -BeNullOrEmpty
                    $Err[0] | Should -Match ([regex]::Escape("resource 'Front Door' matches more than one resource type. Narrow it down with -ResourceType"))
                }
            }

            It 'Writes a non-terminating error' {
                InModuleScope AzureCAF {
                    { Resolve-CafResourceDefinition -Alias 'zzz' -ErrorAction SilentlyContinue } | Should -Not -Throw
                }
            }
        }
    }

    Context 'With the real resource definitions' {

        It 'Resolves <Description>' -ForEach @(
            @{ Description = 'a storage account by Terraform resource type'; Params = @{ TerraformResourceType = 'azurerm_storage_account' }; Expected = 'st' }
            @{ Description = 'a key vault by resource name'; Params = @{ Resource = 'Key vault' }; Expected = 'kv' }
            @{ Description = 'a function app by resource type and alias'; Params = @{ ResourceType = 'Microsoft.Web/sites'; Alias = 'func' }; Expected = 'func' }
        ) {
            InModuleScope AzureCAF -Parameters @{ Params = $Params; Expected = $Expected } {
                (Resolve-CafResourceDefinition @Params).Slug | Should -Be $Expected
            }
        }
    }
}
