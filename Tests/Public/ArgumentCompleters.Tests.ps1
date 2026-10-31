BeforeAll {
    if (-not $env:BHProjectName) {
        $env:BHProjectName = (Get-ChildItem "$PSScriptRoot\..\..\*.psm1" -Recurse).BaseName
    }

    Get-Module $env:BHProjectName | Remove-Module -Force -ErrorAction Ignore
    Import-Module (Join-Path "$PSScriptRoot\..\.." $env:BHProjectName) -Force

    function Complete-Line {
        param([string]$Line)
        (TabExpansion2 -inputScript $Line -cursorColumn $Line.Length).CompletionMatches
    }
}

Describe 'Argument completers' {

    Context 'Get-CafResourceName -ResourceType' {

        It 'Offers every known resource type when nothing has been typed yet' {
            $Matches = Complete-Line "Get-CafResourceName -ResourceType "
            $Matches.Count | Should -BeGreaterThan 100
            $Matches.CompletionText | Should -Not -Contain '.\.git'
        }

        It 'Matches as a substring, consistent with the cmdlet''s own -ResourceType matching' {
            $Matches = Complete-Line "Get-CafResourceName -ResourceType virtualMach"
            $Matches.CompletionText | Should -Contain 'Microsoft.Compute/virtualMachines'
            $Matches.CompletionText | Should -Contain 'Microsoft.Compute/virtualMachineScaleSets'
        }
    }

    Context 'Get-CafResourceName -Alias' {

        It 'Offers every known alias when nothing has been typed yet' {
            $Matches = Complete-Line "Get-CafResourceName -Alias "
            $Matches.Count | Should -BeGreaterThan 100
        }

        It 'Matches as a substring' {
            $Matches = Complete-Line "Get-CafResourceName -Alias vms"
            $Matches.CompletionText | Should -Contain 'vmss'
        }
    }

    Context 'Get-CafResourceName -Resource' {

        It 'Offers every known friendly name when nothing has been typed yet' {
            $Matches = Complete-Line "Get-CafResourceName -Resource "
            $Matches.Count | Should -BeGreaterThan 100
        }

        It 'Matches as a substring' {
            $Matches = Complete-Line "Get-CafResourceName -Resource Func"
            $Matches.ListItemText | Should -Contain 'Function app'
        }

        It 'Quotes completion text that contains a space' {
            $Matches = Complete-Line "Get-CafResourceName -Resource Func"
            ($Matches | Where-Object ListItemText -eq 'Function app').CompletionText | Should -Be "'Function app'"
        }

        It 'Narrows to just the friendly names for an already-typed -ResourceType' {
            $Matches = Complete-Line "Get-CafResourceName -ResourceType Microsoft.Web/sites -Resource "
            $Matches.ListItemText | Sort-Object | Should -Be @('Function app', 'Web app')
        }

        It 'Narrows to just the friendly names for an already-typed -Alias' {
            $Matches = Complete-Line "Get-CafResourceName -Alias afd -Resource "
            $Matches.ListItemText | Sort-Object | Should -Be @('Front Door (classic)', 'Front Door (Standard/Premium) profile')
        }
    }

    Context 'Get-CafResourceType' {

        It 'Completes -ResourceType' {
            $Matches = Complete-Line "Get-CafResourceType -ResourceType KeyVa"
            $Matches.CompletionText | Should -Contain 'Microsoft.KeyVault/vaults'
        }

        It 'Completes -Alias' {
            $Matches = Complete-Line "Get-CafResourceType -Alias vms"
            $Matches.CompletionText | Should -Contain 'vmss'
        }

        It 'Completes -Alias via the -Slug alias' {
            $Matches = Complete-Line "Get-CafResourceType -Slug vms"
            $Matches.CompletionText | Should -Contain 'vmss'
        }

        It 'Completes -Resource, narrowed by an already-typed -Alias' {
            $Matches = Complete-Line "Get-CafResourceType -Alias afd -Resource "
            $Matches.ListItemText | Sort-Object | Should -Be @('Front Door (classic)', 'Front Door (Standard/Premium) profile')
        }
    }

    Context 'Test-CafResourceName' {

        It 'Completes -ResourceType the same way as Get-CafResourceName' {
            $Matches = Complete-Line "Test-CafResourceName -Name foo -ResourceType KeyVa"
            $Matches.CompletionText | Should -Contain 'Microsoft.KeyVault/vaults'
        }

        It 'Completes -Resource, narrowed by an already-typed -ResourceType' {
            $Matches = Complete-Line "Test-CafResourceName -Name foo -ResourceType Microsoft.Web/sites -Resource "
            $Matches.ListItemText | Sort-Object | Should -Be @('Function app', 'Web app')
        }
    }
}
