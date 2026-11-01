BeforeAll {
    if (-not $env:BHProjectName) {
        $env:BHProjectName = (Get-ChildItem "$PSScriptRoot\..\..\*.psm1" -Recurse).BaseName
    }

    Get-Module $env:BHProjectName | Remove-Module -Force -ErrorAction Ignore
    Import-Module (Join-Path "$PSScriptRoot\..\.." $env:BHProjectName) -Force
}

Describe 'Get-CafResourceName' {

    Context 'Basic name generation' {

        It 'Builds a name from prefix, slug and suffix joined with the default separator' {
            Get-CafResourceName -ResourceType 'Microsoft.Compute/virtualMachines' -Prefix 'contoso' -Suffix '01' |
                Should -Be 'contoso-vm-01'
        }

        It 'Supports multiple prefix and suffix values, in order' {
            Get-CafResourceName -ResourceType 'Microsoft.Compute/virtualMachines' -Prefix 'contoso', 'prod' -Suffix '01', 'b' |
                Should -Be 'contoso-prod-vm-01-b'
        }

        It 'Uses no separator for resource types that do not permit dashes' {
            Get-CafResourceName -ResourceType 'Microsoft.Storage/storageAccounts' -Prefix 'contoso' -Suffix '01' |
                Should -Be 'contosost01'
        }

        It 'Accepts the ResourceType by pipeline from Get-CafResourceType' {
            Get-CafResourceType -Slug 'kv' | Get-CafResourceName -Prefix 'contoso' |
                Should -Be 'contoso-kv'
        }
    }

    Context 'Region' {

        It 'Resolves a region to its abbreviation and appends it after any suffix' {
            Get-CafResourceName -ResourceType 'Microsoft.Compute/virtualMachines' -Prefix 'contoso' -Suffix '01' -Region 'eastus' |
                Should -Be 'contoso-vm-01-eus'
        }

        It 'Resolves a region given by display name' {
            Get-CafResourceName -ResourceType 'Microsoft.Compute/virtualMachines' -Prefix 'contoso' -Region 'East US' |
                Should -Be 'contoso-vm-eus'
        }

        It 'Works with no explicit -Suffix' {
            Get-CafResourceName -ResourceType 'Microsoft.Compute/virtualMachines' -Prefix 'contoso' -Region 'eastus' |
                Should -Be 'contoso-vm-eus'
        }

        It 'Errors rather than silently dropping an unrecognized region' {
            { Get-CafResourceName -ResourceType 'Microsoft.Compute/virtualMachines' -Prefix 'contoso' -Region 'doesnotexist' -ErrorAction Stop } |
                Should -Throw
        }
    }

    Context 'Cleaning invalid characters' {

        It 'Strips characters that are not valid for the resource type by default' {
            Get-CafResourceName -ResourceType 'Microsoft.Storage/storageAccounts' -Prefix 'contoso-01!' |
                Should -Be 'contoso01st'
        }

        It 'Leaves invalid characters in place when -NoClean is specified, causing validation to fail' {
            { Get-CafResourceName -ResourceType 'Microsoft.Storage/storageAccounts' -Prefix 'contoso-01!' -NoClean -ErrorAction Stop } |
                Should -Throw
        }
    }

    Context 'Casing' {

        It 'Converts the name to lowercase when the resource type requires it, with a warning' {
            Get-CafResourceName -ResourceType 'Microsoft.AnalysisServices/servers' -Prefix 'CONTOSO' -WarningVariable warning |
                Should -Be 'contosoas'
            $warning | Should -Not -BeNullOrEmpty
        }
    }

    Context 'Length trimming' {

        It 'Trims the name and warns when it exceeds the max length' {
            $LongPrefix = 'a' * 30
            Get-CafResourceName -ResourceType 'Microsoft.Storage/storageAccounts' -Prefix $LongPrefix -WarningVariable warning |
                Should -HaveCount 1 -Because 'a single trimmed string should be returned'
            $warning | Should -Not -BeNullOrEmpty
        }
    }

    Context 'Instance number' {

        It 'Appends the instance number zero-padded to 3 digits by default' {
            Get-CafResourceName -ResourceType 'Microsoft.Compute/virtualMachines' -Prefix 'contoso' -InstanceNumber 1 |
                Should -Be 'contoso-vm-001'
        }

        It 'Leaves a number that already meets the padding width as-is' {
            Get-CafResourceName -ResourceType 'Microsoft.Compute/virtualMachines' -Prefix 'contoso' -InstanceNumber 123 |
                Should -Be 'contoso-vm-123'
        }

        It 'Supports a custom padding width' {
            Get-CafResourceName -ResourceType 'Microsoft.Compute/virtualMachines' -Prefix 'contoso' -InstanceNumber 1 -InstanceNumberPadding 2 |
                Should -Be 'contoso-vm-01'
        }

        It 'Never truncates the instance number, even when the rest of the name would otherwise overflow' {
            $LongPrefix = 'a' * 30
            $Result = Get-CafResourceName -ResourceType 'Microsoft.Storage/storageAccounts' -Prefix $LongPrefix -InstanceNumber 1 -WarningAction SilentlyContinue
            $Result | Should -BeLike '*001'
            $Result.Length | Should -Be 24
        }

        It 'Can be combined with a random suffix' {
            $Result = Get-CafResourceName -ResourceType 'Microsoft.Storage/storageAccounts' -Prefix 'contoso' -InstanceNumber 1 -RandomSuffixLength 4
            $Result | Should -Match '^contosost001[a-z0-9]{4}$'
        }

        It 'Errors rather than silently dropping the instance number when there is no room for it' {
            # Microsoft.Synapse/workspaces/sqlPools has a 15 char max length and a 5 char slug ('syndp') -
            # reserving 10 chars for the instance number plus 10 for a random suffix leaves no room for it.
            { Get-CafResourceName -ResourceType 'Microsoft.Synapse/workspaces/sqlPools' -InstanceNumber 1 -InstanceNumberPadding 10 -RandomSuffixLength 10 -ErrorAction Stop } |
                Should -Throw
        }
    }

    Context 'Count' {

        It 'Generates sequential instance numbers starting from 1 when -InstanceNumber is not specified' {
            $Result = Get-CafResourceName -ResourceType 'Microsoft.Compute/virtualMachines' -Prefix 'contoso' -Count 3
            $Result | Should -HaveCount 3
            $Result | Should -Be @('contoso-vm-001', 'contoso-vm-002', 'contoso-vm-003')
        }

        It 'Starts the sequence from -InstanceNumber when specified' {
            $Result = Get-CafResourceName -ResourceType 'Microsoft.Compute/virtualMachines' -Prefix 'contoso' -InstanceNumber 5 -Count 3
            $Result | Should -Be @('contoso-vm-005', 'contoso-vm-006', 'contoso-vm-007')
        }

        It 'Returns a single name when -Count is not specified' {
            Get-CafResourceName -ResourceType 'Microsoft.Compute/virtualMachines' -Prefix 'contoso' |
                Should -Be 'contoso-vm'
        }

        It 'Gives each generated name its own random suffix' {
            $Result = Get-CafResourceName -ResourceType 'Microsoft.Storage/storageAccounts' -Prefix 'contoso' -RandomSuffixLength 4 -Count 3
            $Result | Should -HaveCount 3
            ($Result | Select-Object -Unique) | Should -HaveCount 3
            $Result | ForEach-Object { $_ | Should -Match '^contosost\d{3}[a-z0-9]{4}$' }
        }

        It 'Produces the same sequence of random suffixes every time when -RandomSuffixSeed is specified' {
            $First = Get-CafResourceName -ResourceType 'Microsoft.Storage/storageAccounts' -Prefix 'contoso' -RandomSuffixLength 4 -Count 3 -RandomSuffixSeed 42
            $Second = Get-CafResourceName -ResourceType 'Microsoft.Storage/storageAccounts' -Prefix 'contoso' -RandomSuffixLength 4 -Count 3 -RandomSuffixSeed 42
            $First | Should -Be $Second
        }

        It 'Reserves room for the longest instance number in the sequence so the base name stays consistent' {
            $LongPrefix = 'a' * 30
            $Result = Get-CafResourceName -ResourceType 'Microsoft.Storage/storageAccounts' -Prefix $LongPrefix -Count 3 -WarningAction SilentlyContinue
            $Result | Should -Be @('aaaaaaaaaaaaaaaaaaaaa001', 'aaaaaaaaaaaaaaaaaaaaa002', 'aaaaaaaaaaaaaaaaaaaaa003')
            $Result | ForEach-Object { $_.Length | Should -Be 24 }
        }
    }

    Context 'AsObject' {

        It 'Returns a string by default' {
            $Result = Get-CafResourceName -ResourceType 'Microsoft.Compute/virtualMachines' -Prefix 'contoso'
            $Result | Should -BeOfType [string]
        }

        It 'Returns an object with Name, ResourceType, Resource and Slug when -AsObject is specified' {
            $Result = Get-CafResourceName -ResourceType 'Microsoft.Compute/virtualMachines' -Prefix 'contoso' -AsObject
            $Result.Name | Should -Be 'contoso-vm'
            $Result.ResourceType | Should -Be 'Microsoft.Compute/virtualMachines'
            $Result.Resource | Should -Be 'Virtual machine'
            $Result.Slug | Should -Be 'vm'
            $Result.InstanceNumber | Should -BeNullOrEmpty
            $Result.RandomSuffix | Should -BeNullOrEmpty
        }

        It 'Includes InstanceNumber when -InstanceNumber is specified' {
            $Result = Get-CafResourceName -ResourceType 'Microsoft.Compute/virtualMachines' -Prefix 'contoso' -InstanceNumber 1 -AsObject
            $Result.Name | Should -Be 'contoso-vm-001'
            $Result.InstanceNumber | Should -Be 1
        }

        It 'Includes a distinct InstanceNumber per generated name with -Count' {
            $Results = Get-CafResourceName -ResourceType 'Microsoft.Compute/virtualMachines' -Prefix 'contoso' -Count 3 -AsObject
            $Results.InstanceNumber | Should -Be @(1, 2, 3)
            $Results.Name | Should -Be @('contoso-vm-001', 'contoso-vm-002', 'contoso-vm-003')
        }

        It 'Includes RandomSuffix when -RandomSuffixLength is specified' {
            $Result = Get-CafResourceName -ResourceType 'Microsoft.Storage/storageAccounts' -Prefix 'contoso' -RandomSuffixLength 4 -AsObject
            $Result.RandomSuffix | Should -Match '^[a-z0-9]{4}$'
            $Result.Name | Should -Be "contosost$($Result.RandomSuffix)"
        }

        It 'Keeps each row traceable when batch-generating across different resource types' {
            $Items = @(
                [pscustomobject]@{ ResourceType = 'Microsoft.Compute/virtualMachines'; Prefix = 'contoso' }
                [pscustomobject]@{ Alias = 'kv'; Prefix = 'contoso' }
            )

            $Results = $Items | Get-CafResourceName -AsObject
            $Results[0].ResourceType | Should -Be 'Microsoft.Compute/virtualMachines'
            $Results[1].ResourceType | Should -Be 'Microsoft.KeyVault/vaults'
        }
    }

    Context 'Random suffix' {

        It 'Appends the requested number of random characters' {
            $Result = Get-CafResourceName -ResourceType 'Microsoft.Storage/storageAccounts' -Prefix 'contoso' -RandomSuffixLength 6
            $Result | Should -Match '^contosost[a-z0-9]{6}$'
        }

        It 'Never truncates the random suffix, even when the rest of the name would otherwise overflow' {
            $LongPrefix = 'a' * 30
            $Result = Get-CafResourceName -ResourceType 'Microsoft.Storage/storageAccounts' -Prefix $LongPrefix -RandomSuffixLength 6 -WarningAction SilentlyContinue
            $Result.Length | Should -Be 24
            $Result.Substring(18) | Should -Match '^[a-z0-9]{6}$'
        }

        It 'Is always lowercase, even for a resource type that otherwise allows uppercase' {
            # Microsoft.Compute/virtualMachines has Lowercase = false, but the random suffix is for
            # uniqueness, not communication, so it's kept lowercase-only regardless.
            $Result = Get-CafResourceName -ResourceType 'Microsoft.Compute/virtualMachines' -Prefix 'contoso' -RandomSuffixLength 8 -RandomSuffixSeed 1
            $Result | Should -Match '^contoso-vm-[a-z0-9]{8}$'
        }

        It 'Errors rather than silently dropping the random suffix when there is no room for it' {
            # Microsoft.Synapse/workspaces/sqlPools has a 15 char max length and a 5 char slug ('syndp') -
            # a 12 character random suffix leaves no room for the slug, let alone a prefix.
            { Get-CafResourceName -ResourceType 'Microsoft.Synapse/workspaces/sqlPools' -RandomSuffixLength 12 -ErrorAction Stop } |
                Should -Throw
        }

        It 'Produces the same random suffix every time when -RandomSuffixSeed is specified' {
            $First = Get-CafResourceName -ResourceType 'Microsoft.Storage/storageAccounts' -Prefix 'contoso' -RandomSuffixLength 8 -RandomSuffixSeed 42
            $Second = Get-CafResourceName -ResourceType 'Microsoft.Storage/storageAccounts' -Prefix 'contoso' -RandomSuffixLength 8 -RandomSuffixSeed 42
            $First | Should -Be $Second
        }

        It 'Produces different random suffixes for different seeds' {
            $First = Get-CafResourceName -ResourceType 'Microsoft.Storage/storageAccounts' -Prefix 'contoso' -RandomSuffixLength 8 -RandomSuffixSeed 1
            $Second = Get-CafResourceName -ResourceType 'Microsoft.Storage/storageAccounts' -Prefix 'contoso' -RandomSuffixLength 8 -RandomSuffixSeed 2
            $First | Should -Not -Be $Second
        }

        It 'Ignores -RandomSuffixSeed when -RandomSuffixLength is not specified' {
            Get-CafResourceName -ResourceType 'Microsoft.Compute/virtualMachines' -Prefix 'contoso' -RandomSuffixSeed 42 |
                Should -Be 'contoso-vm'
        }
    }

    Context 'Resource type resolution' {

        It 'Errors for an unknown resource type' {
            { Get-CafResourceName -ResourceType 'Microsoft.DoesNotExist/thing' -ErrorAction Stop } | Should -Throw
        }

        It 'Errors when the resource type is ambiguous and -Resource is not specified' {
            { Get-CafResourceName -ResourceType 'Microsoft.Web/sites' -ErrorAction Stop } | Should -Throw
        }

        It 'Resolves an ambiguous resource type when -Resource is specified' {
            Get-CafResourceName -ResourceType 'Microsoft.Web/sites' -Resource 'Function app' -Prefix 'contoso' |
                Should -Be 'contoso-func'
        }

        It 'Errors when -Resource does not match any candidate for the resource type' {
            { Get-CafResourceName -ResourceType 'Microsoft.Web/sites' -Resource 'Does not exist' -ErrorAction Stop } | Should -Throw
        }
    }

    Context 'Resolving by alias' {

        It 'Resolves the resource type from -Alias' {
            Get-CafResourceName -Alias 'vmss' -Prefix 'contoso' |
                Should -Be 'contoso-vmss'
        }

        It 'Resolves the resource type from the -Slug alias' {
            Get-CafResourceName -Slug 'vmss' -Prefix 'contoso' |
                Should -Be 'contoso-vmss'
        }

        It 'Errors for an unknown alias' {
            { Get-CafResourceName -Alias 'doesnotexist' -ErrorAction Stop } | Should -Throw
        }

        It 'Errors when the alias is ambiguous and -Resource is not specified' {
            # 'afd' is used by both Microsoft.Cdn/profiles and Microsoft.Network/frontDoors.
            { Get-CafResourceName -Alias 'afd' -ErrorAction Stop } | Should -Throw
        }

        It 'Resolves an ambiguous alias when -Resource is specified' {
            Get-CafResourceName -Alias 'afd' -Resource 'classic' -Prefix 'contoso' |
                Should -Be 'contoso-afd'
        }

        It '-ResourceType takes precedence when both -ResourceType and -Alias are specified and agree' {
            Get-CafResourceName -ResourceType 'Microsoft.Compute/virtualMachines' -Alias 'vm' -Prefix 'contoso' |
                Should -Be 'contoso-vm'
        }
    }

    Context 'Resolving by -Resource alone' {

        It 'Resolves the resource type from a unique -Resource friendly name' {
            Get-CafResourceName -Resource 'Key vault' -Prefix 'contoso' |
                Should -Be 'contoso-kv'
        }

        It 'Matches -Resource as a substring when used alone' {
            Get-CafResourceName -Resource 'Function' -Prefix 'contoso' |
                Should -Be 'contoso-func'
        }

        It 'Errors for an unknown -Resource value' {
            { Get-CafResourceName -Resource 'Does not exist' -ErrorAction Stop } | Should -Throw
        }

        It 'Errors and suggests -ResourceType when a -Resource substring matches more than one resource type' {
            # 'vault' matches both 'Key vault' and 'Recovery Services vault'.
            { Get-CafResourceName -Resource 'vault' -ErrorAction Stop } | Should -Throw
        }

        It 'Errors when none of -ResourceType, -Alias or -Resource are specified' {
            { Get-CafResourceName -Prefix 'contoso' -ErrorAction Stop } | Should -Throw
        }
    }

    Context 'Partial matching' {

        It 'Matches -ResourceType as a substring when there is no exact match' {
            Get-CafResourceName -ResourceType 'KeyVault' -Prefix 'contoso' -Suffix '01' |
                Should -Be 'contoso-kv-01'
        }

        It 'Prefers an exact ResourceType match over a partial one, even when the exact value is also a substring of another resource type' {
            # 'Microsoft.Compute/virtualMachines' is (case-insensitively) a substring of
            # 'Microsoft.Compute/virtualMachineScaleSets' too ('machineS' matches 'machines'), so the
            # exact match must win rather than reporting this as ambiguous.
            Get-CafResourceName -ResourceType 'Microsoft.Compute/virtualMachines' -Prefix 'contoso' |
                Should -Be 'contoso-vm'
        }

        It 'Matches -Resource as a substring' {
            Get-CafResourceName -ResourceType 'Microsoft.Web/sites' -Resource 'Function' -Prefix 'contoso' |
                Should -Be 'contoso-func'
        }
    }

    Context 'Batch generation via pipeline' {

        It 'Generates a name per piped object, binding ResourceType/Alias/Prefix/Suffix by property name' {
            $Items = @(
                [pscustomobject]@{ ResourceType = 'Microsoft.Compute/virtualMachines'; Prefix = 'contoso', 'web'; Suffix = '01' }
                [pscustomobject]@{ Alias = 'kv'; Prefix = 'contoso' }
            )

            $Results = $Items | Get-CafResourceName
            $Results | Should -HaveCount 2
            $Results[0] | Should -Be 'contoso-web-vm-01'
            $Results[1] | Should -Be 'contoso-kv'
        }

        It 'Binds InstanceNumber, RandomSuffixLength and RandomSuffixSeed by property name' {
            $Item = [pscustomobject]@{
                ResourceType       = 'Microsoft.Storage/storageAccounts'
                Prefix             = 'contoso'
                RandomSuffixLength = 4
                RandomSuffixSeed   = 42
            }

            $Result = $Item | Get-CafResourceName
            $DirectResult = Get-CafResourceName -ResourceType 'Microsoft.Storage/storageAccounts' -Prefix 'contoso' -RandomSuffixLength 4 -RandomSuffixSeed 42
            $Result | Should -Be $DirectResult
        }
    }

    Context 'Naming convention profile' {

        BeforeAll {
            $ConventionPath = Join-Path $TestDrive 'convention.json'
            @{
                Prefix                = @('contoso', 'prod')
                InstanceNumberPadding = 2
                RandomSuffixLength    = 4
            } | ConvertTo-Json | Set-Content -Path $ConventionPath
        }

        It 'Applies every default from the convention file when nothing is specified explicitly' {
            # Prefix, InstanceNumberPadding (2, not the default 3) and RandomSuffixLength (4) all come
            # from the convention file here - only -InstanceNumber itself is passed explicitly.
            Get-CafResourceName -ResourceType 'Microsoft.Compute/virtualMachines' -ConventionPath $ConventionPath -InstanceNumber 1 -RandomSuffixSeed 1 |
                Should -Be 'contoso-prod-vm-01-idq1'
        }

        It 'Lets an explicit parameter override the convention file' {
            Get-CafResourceName -ResourceType 'Microsoft.Compute/virtualMachines' -Prefix 'fabrikam' -ConventionPath $ConventionPath -InstanceNumber 1 -RandomSuffixSeed 1 |
                Should -Be 'fabrikam-vm-01-idq1'
        }

        It 'Errors clearly when the convention file does not exist' {
            { Get-CafResourceName -ResourceType 'Microsoft.Compute/virtualMachines' -ConventionPath (Join-Path $TestDrive 'missing.json') -ErrorAction Stop } |
                Should -Throw
        }

        It 'Errors clearly when the convention file is not valid JSON' {
            $BadPath = Join-Path $TestDrive 'bad-convention.json'
            Set-Content -Path $BadPath -Value 'not json'
            { Get-CafResourceName -ResourceType 'Microsoft.Compute/virtualMachines' -ConventionPath $BadPath -ErrorAction Stop } |
                Should -Throw
        }
    }

    Context '-Verbose trace' {

        It 'Emits verbose output describing the length budget without affecting the result' {
            $VerboseOutput = Get-CafResourceName -ResourceType 'Microsoft.Storage/storageAccounts' -Prefix 'contoso' -RandomSuffixLength 4 -RandomSuffixSeed 1 -Verbose 4>&1
            $Result = $VerboseOutput | Where-Object { $_ -isnot [System.Management.Automation.VerboseRecord] }
            $Verbose = $VerboseOutput | Where-Object { $_ -is [System.Management.Automation.VerboseRecord] }

            $Result | Should -Be 'contosostidq1'
            $Verbose.Count | Should -BeGreaterThan 0
            ($Verbose.Message -join ' ') | Should -Match 'Reserving'
        }
    }
}
