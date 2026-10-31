# Microsoft.AnalysisServices

| Entity | Scope | Length | Valid Characters |
| --- | --- | --- | --- |
| servers | resource group | 3-63 | Lowercase letters and numbers. Start with lowercase letter. |

# Microsoft.ApiManagement

| Entity | Scope | Length | Valid Characters |
| --- | --- | --- | --- |
| service | global | 1-50 | Alphanumerics and hyphens. Start with letter and end with alphanumeric. |
| service / apis | service | 1-80 | Alphanumerics and hyphens. Start with letter and end with alphanumeric. |
| service / apis / issues | api | 1-80 | Alphanumerics and hyphens. Start with letter and end with alphanumeric. |
| service / apis / issues / attachments | issue | 1-80 | Alphanumerics and hyphens. Start with letter and end with alphanumeric. |
| service / apis / issues / comments | issue | 1-80 | Alphanumerics and hyphens. Start with letter and end with alphanumeric. |
| service / apis / operations | api | 1-80 | Alphanumerics and hyphens. Start with letter and end with alphanumeric. |
| service / apis / operations / tags | operation | 1-80 | Alphanumerics and hyphens. Start with letter and end with alphanumeric. |
| service / apis / releases | api | 1-80 | Alphanumerics, underscores, and hyphens. Start and end with alphanumeric or underscore. |
| service / apis / schemas | api | 1-80 | Alphanumerics and hyphens. Start with letter and end with alphanumeric. |
| service / apis / tagDescriptions | api | 1-80 | Alphanumerics and hyphens. Start with letter and end with alphanumeric. |
| service / apis / tags | api | 1-80 | Alphanumerics and hyphens. Start with letter and end with alphanumeric. |
| service / api-version-sets | service | 1-80 | Alphanumerics and hyphens. Start with letter and end with alphanumeric. |
| service / authorizationServers | service | 1-80 | Alphanumerics and hyphens. Start with letter and end with alphanumeric. |
| service / backends | service | 1-80 | Alphanumerics and hyphens. Start with letter and end with alphanumeric. |
| service / certificates | service | 1-80 | Alphanumerics and hyphens. Start with letter and end with alphanumeric. |
| service / diagnostics | service | 1-80 | Alphanumerics and hyphens. Start with letter and end with alphanumeric. |
| service / groups | service | 1-80 | Alphanumerics and hyphens. Start with letter and end with alphanumeric. |
| service / groups / users | group | 1-80 | Alphanumerics and hyphens. Start with letter and end with alphanumeric. |
| service / identityProviders | service | 1-80 | Alphanumerics and hyphens. Start with letter and end with alphanumeric. |
| service / loggers | service | 1-80 | Alphanumerics and hyphens. Start with letter and end with alphanumeric. |
| service / notifications | service | 1-80 | Alphanumerics and hyphens. Start with letter and end with alphanumeric. |
| service / notifications / recipientEmails | notification | 1-80 | Alphanumerics and hyphens. Start with letter and end with alphanumeric. |
| service / openidConnectProviders | service | 1-80 | Alphanumerics and hyphens. Start with letter and end with alphanumeric. |
| service / policies | service | 1-80 | Alphanumerics and hyphens. Start with letter and end with alphanumeric. |
| service / products | service | 1-80 | Alphanumerics and hyphens. Start with letter and end with alphanumeric. |
| service / products / apis | product | 1-80 | Alphanumerics and hyphens. Start with letter and end with alphanumeric. |
| service / products / groups | product | 1-80 | Alphanumerics and hyphens. Start with letter and end with alphanumeric. |
| service / products / tags | product | 1-80 | Alphanumerics and hyphens. Start with letter and end with alphanumeric. |
| service / properties | service | 1-80 | Alphanumerics and hyphens. Start with letter and end with alphanumeric. |
| service / subscriptions | service | 1-80 | Alphanumerics and hyphens. Start with letter and end with alphanumeric. |
| service / tags | service | 1-80 | Alphanumerics and hyphens. Start with letter and end with alphanumeric. |
| service / templates | service | 1-80 | Alphanumerics and hyphens. Start with letter and end with alphanumeric. |
| service / users | service | 1-80 | Alphanumerics and hyphens. Start with letter and end with alphanumeric. |

# Microsoft.App

| Entity | Scope | Length | Valid Characters |
| --- | --- | --- | --- |
| containerApps | resource group | 2-32 | 	Lowercase letters, numbers, and hyphens.. Start with letter and end with alphanumeric. |

# Microsoft.AppConfiguration

| Entity | Scope | Length | Valid Characters |
| --- | --- | --- | --- |
| configurationStores* | global | 5-50 | Alphanumerics and hyphens. Can’t contain a sequence of more than 2 hyphens. Can’t start with or end with an hyphen. |
| configurationStores / replicas | configurationStore | 1-50 The combined length of the configurationStore name and the replica name can’t exceed 60 characters.|Alphanumerics only. |

\* {storeName}-{replicaName} needs to be globally unique.

# Microsoft.AppPlatform

| Entity | Scope | Length | Valid Characters |
| --- | --- | --- | --- |
| spring | global | 4-32 | Lowercase letters, numbers, and hyphens. |

# Microsoft.Authorization

| Entity | Scope | Length | Valid Characters |
| --- | --- | --- | --- |
| locks | scope of assignment | 1-90 | Alphanumerics, periods, underscores, hyphens, and parenthesis. Can't end in period. |
| policyAssignments | scope of assignment | 1-128 display name 1-64 resource name 1-24 resource name at management group scope | Display name can contain any characters. Resource name can't use: `#<>%&:\?/` or control characters.  Can't end with period or space. |
| policyDefinitions | scope of definition | 1-128 display name 1-64 resource name | Display name can contain any characters. Resource name can't use: `#<>%&:\?/` or control characters.  Can't end with period or space. |
| policyExemptions | scope of exemption | 1-128 display name 1-64 resource name | Display name can contain any characters. Resource name can't use: `#<>%&:\?/` or control characters.  Can't end with period or space. |
| policySetDefinitions | scope of definition | 1-128 display name 1-64 resource name | Display name can contain any characters. Resource name can't use: `#<>%&:\?/` or control characters.  Can't end with period or space. |
| roleAssignments | tenant | 36 | Must be a globally unique identifier (GUID). |
| roleDefinitions | tenant | 36 | Must be a globally unique identifier (GUID). |

# Microsoft.Automation

| Entity | Scope | Length | Valid Characters |
| --- | --- | --- | --- |
| automationAccounts | resource group & region (See note below) | 6-50 | Alphanumerics and hyphens. Start with letter and end with alphanumeric. |
| automationAccounts / certificates | automation account | 1-128 | Can't use: `<>*%&:\?.+/` or control characters  Can't end with space. |
| automationAccounts / connections | automation account | 1-128 | Can't use: `<>*%&:\?.+/` or control characters  Can't end with space. |
| automationAccounts / credentials | automation account | 1-128 | Can't use: `<>*%&:\?.+/` or control characters  Can't end with space. |
| automationAccounts / runbooks | automation account | 1-63 | Alphanumerics, underscores, and hyphens. Start with letter. |
| automationAccounts / schedules | automation account | 1-128 | Can't use: `<>*%&:\?.+/` or control characters  Can't end with space. |
| automationAccounts / variables | automation account | 1-128 | Can't use: `<>*%&:\?.+/` or control characters  Can't end with space. |
| automationAccounts / watchers | automation account | 1-63 | Alphanumerics, underscores, and hyphens. Start with letter. |
| automationAccounts / webhooks | automation account | 1-128 | Can't use: `<>*%&:\?.+/` or control characters  Can't end with space. |

# Microsoft.AVS

| Entity | Scope | Length | Valid Characters |
| --- | --- | --- | --- |
| privateClouds | resource group | 1-80 | Alphanumerics, periods, hyhens, and underscores. Start with alphanumeric and end with alphanumeric or underscore. |

# Microsoft.Batch

| Entity | Scope | Length | Valid Characters |
| --- | --- | --- | --- |
| batchAccounts | Region | 3-24 | Lowercase letters and numbers. |
| batchAccounts / applications | batch account | 1-64 | Alphanumerics, underscores, and hyphens. |
| batchAccounts / certificates | batch account | 5-45 | Alphanumerics, underscores, and hyphens. |
| batchAccounts / pools | batch account | 1-64 | Alphanumerics, underscores, and hyphens. |

# Microsoft.Blockchain

| Entity | Scope | Length | Valid Characters |
| --- | --- | --- | --- |
| blockchainMembers | global | 2-20 | Lowercase letters and numbers. Start with lowercase letter. |

# Microsoft.Blueprint

| Entity | Scope | Length | Valid Characters |
| --- | --- | --- | --- |
| blueprint| Management groups, Subscriptions, Resource groups | 90 | Alphanumerics, underscores, and hyphens. |
| blueprintAssignments | Management groups, Subscriptions, Resource groups | 90 | Alphanumerics, underscores, and hyphens. |

# Microsoft.BotService

| Entity | Scope | Length | Valid Characters |
| --- | --- | --- | --- |
| botServices | global | 2-64 | Alphanumerics, underscores, periods, and hyphens. Start with alphanumeric. |
| botServices / channels | bot service | 2-64 | Alphanumerics, underscores, periods, and hyphens. Start with alphanumeric. |
| botServices / Connections | bot service | 2-64 | Alphanumerics, underscores, periods, and hyphens. Start with alphanumeric. |
| enterpriseChannels | resource group | 2-64 | Alphanumerics, underscores, periods, and hyphens. Start with alphanumeric. |

# Microsoft.Cache

| Entity | Scope | Length | Valid Characters |
| --- | --- | --- | --- |
| Redis | global | 1-63 | Alphanumerics and hyphens. Start and end with alphanumeric. Consecutive hyphens not allowed. |
| Redis / firewallRules | Redis | 1-256 | Alphanumerics |

# Microsoft.Cdn

| Entity | Scope | Length | Valid Characters |
| --- | --- | --- | --- |
| profiles | resource group | 1-260 | Alphanumerics and hyphens. Start and end with alphanumeric. |
| profiles / endpoints | global | 1-50 | Alphanumerics and hyphens. Start and end with alphanumeric. |
| profiles / originGroups | global | 1-50 | Alphanumerics and hyphens. Start and end with alphanumeric. |
| profiles / originGroups / origins | global | 1-50 | Alphanumerics and hyphens. Start and end with alphanumeric. |
| profiles / afdEndpoints / routes | global | 1-50 | Alphanumerics and hyphens. Start and end with alphanumeric. |

# Microsoft.CertificateRegistration

| Entity | Scope | Length | Valid Characters |
| --- | --- | --- | --- |
| certificateOrders | resource group | 3-50 | Alphanumerics. |

# Microsoft.CognitiveServices

| Entity | Scope | Length | Valid Characters |
| --- | --- | --- | --- |
| accounts | resource group | 2-64 | Alphanumerics and hyphens. Start and end with alphanumeric. |

# Microsoft.Compute

| Entity | Scope | Length | Valid Characters |
| --- | --- | --- | --- |
| availabilitySets | resource group | 1-80 | Alphanumerics, underscores, periods, and hyphens. Start with alphanumeric. End with alphanumeric or underscore. |
| cloudservices | resource group | 1-15  See note below. | Can't use spaces, control characters, or these characters: `~ ! @ # $ % ^ & * ( ) = + _ [ ] { } \ | ; : . ' " , < > / ?` Can't start with underscore. Can't end with period or hyphen. |
| diskEncryptionSets | resource group | 1-80 | Alphanumerics, underscores, and hyphens. |
| disks | resource group | 1-80 | Alphanumerics, underscores, and hyphens. |
| galleries | resource group | 1-80 | Alphanumerics and periods. Start and end with alphanumeric. |
| galleries / applications | gallery | 1-80 | Alphanumerics, hyphens, and periods. Start and end with alphanumeric. |
| galleries / applications/versions | application | 32-bit integer | Numbers and periods.<br/>(Each segment is converted to an int32. So each segment has a max value of 2,147,483,647.) |
| galleries / images | gallery | 1-80 | Alphanumerics, underscores, hyphens, and periods. Start and end with alphanumeric. |
| galleries / images / versions | image | 32-bit integer | Numbers and periods.<br/>(Each segment is converted to an int32. So each segment has a max value of 2,147,483,647.) |
| images | resource group | 1-80 | Alphanumerics, underscores, periods, and hyphens. Start with alphanumeric. End with alphanumeric or underscore. |
| snapshots | resource group | 1-80 | Alphanumerics, underscores, periods, and hyphens. Start with alphanumeric. End with alphanumeric or underscore. |
| virtualMachines | resource group | 1-15 (Windows) 1-64 (Linux) See note below. | Can't use spaces, control characters, or these characters: `~ ! @ # $ % ^ & * ( ) = + _ [ ] { } \ | ; : . ' " , < > / ?` Windows VMs can't include period or end with hyphen. Linux VMs can't end with period or hyphen. |
| virtualMachineScaleSets | resource group | 1-15 (Windows) 1-64 (Linux) See note below. | Can't use spaces, control characters, or these characters: `~ ! @ # $ % ^ & * ( ) = + _ [ ] { } \ | ; : . ' " , < > / ?` Can't start with underscore. Can't end with period or hyphen. |

# Microsoft.Communication

| Entity | Scope | Length | Valid Characters |
| --- | --- | --- | --- |
| communicationServices | global | 1-63 | Alphanumerics and hyphens. Can't start or end with hyphen. Can't use underscores. |

# Microsoft.ConfidentialLedger

| Entity | Scope | Length | Valid Characters |
| --- | --- | --- | --- |
| ledgers | Resource group | 3-32 | Alphanumerics and hyphens. Can't start or end with hyphen. |

# Microsoft.Consumption

| Entity | Scope | Length | Valid Characters |
| --- | --- | --- | --- |
| budgets | subscription or resource group | 1-63 | Alphanumerics, hyphens, and underscores. |

# Microsoft.ContainerInstance

| Entity | Scope | Length | Valid Characters |
| --- | --- | --- | --- |
| containerGroups | resource group | 1-63 | Lowercase letters, numbers, and hyphens. Can't start or end with hyphen. Consecutive hyphens aren't allowed. |

# Microsoft.ContainerRegistry

| Entity | Scope | Length | Valid Characters |
| --- | --- | --- | --- |
| registries | global | 5-50 | Alphanumerics. |
| registries / buildTasks | registry | 5-50 | Alphanumerics. |
| registries / buildTasks/steps | build task | 5-50 | Alphanumerics. |
| registries / replications | registry | 5-50 | Alphanumerics. |
| registries / scopeMaps | registry | 5-50 | Alphanumerics, hyphens, and underscores. |
| registries / tasks | registry | 5-50 | Alphanumerics, hyphens, and underscores. |
| registries / tokens | registry | 5-50 | Alphanumerics, hyphens, and underscores. |
| registries / webhooks | registry | 5-50 | Alphanumerics. |

# Microsoft.ContainerService

| Entity | Scope | Length | Valid Characters |
| --- | --- | --- | --- |
| managedClusters | resource group | 1-63 | Alphanumerics, underscores, and hyphens. Start and end with alphanumeric. |
| managedClusters / agentPools | managed cluster | 1-12 for Linux 1-6 for Windows | Lowercase letters and numbers. Can't start with a number. |

# Microsoft.CustomerInsights

| Entity | Scope | Length | Valid Characters |
| --- | --- | --- | --- |
| hubs | resource group | 1-64 | Alphanumerics. Start with letter. |
| hubs / authorizationPolicies | hub | 1-50 | Alphanumerics, underscores, and periods. Start and end with alphanumeric. |
| hubs / connectors | hub | 1-128 | Alphanumerics and underscores. Start with letter. |
| hubs / connectors/mappings | connector | 1-128 | Alphanumerics and underscores. Start with letter. |
| hubs / interactions | hub | 1-128 | Alphanumerics and underscores. Start with letter. |
| hubs / kpi | hub | 1-512 | Alphanumerics and underscores. Start with letter. |
| hubs / links | hub | 1-512 | Alphanumerics and underscores. Start with letter. |
| hubs / predictions | hub | 1-512 | Alphanumerics and underscores. Start with letter. |
| hubs / profiles | hub | 1-128 | Alphanumerics and underscores. Start with letter. |
| hubs / relationshipLinks | hub | 1-512 | Alphanumerics and underscores. Start with letter. |
| hubs / relationships | hub | 1-512 | Alphanumerics and underscores. Start with letter. |
| hubs / roleAssignments | hub | 1-128 | Alphanumerics and underscores. Start with letter. |
| hubs / views | hub | 1-512 | Alphanumerics and underscores. Start with letter. |

# Microsoft.CustomProviders

| Entity | Scope | Length | Valid Characters |
| --- | --- | --- | --- |
| associations | resource group | 1-180 | Can't use: `%&\\?/` or control characters Can't end with period or space. |
| resourceProviders | resource group | 3-64 | Can't use: `%&\\?/` or control characters Can't end with period or space. |

# Microsoft.DataBox

| Entity | Scope | Length | Valid Characters |
| --- | --- | --- | --- |
| jobs | resource group | 3-24 | Alphanumerics, hyphens, underscores and periods. |

# Microsoft.Databricks

| Entity | Scope | Length | Valid Characters |
| --- | --- | --- | --- |
| workspaces | resource group | 3-64 | Alphanumerics, underscores, and hyphens |

# Microsoft.DataFactory

| Entity | Scope | Length | Valid Characters |
| --- | --- | --- | --- |
| factories | global | 3-63 | Alphanumerics and hyphens. Start and end with alphanumeric. |
| factories / dataflows | factory | 1-260 | Can't use: `<>*#.%&:\\+?/` or control characters Start with alphanumeric. |
| factories / datasets | factory | 1-260 | Can't use: `<>*#.%&:\\+?/-` or control characters Start with alphanumeric. |
| factories / integrationRuntimes | factory | 3-63 | Alphanumerics and hyphens. Start and end with alphanumeric. |
| factories / linkedservices | factory | 1-260 | Can't use: `<>*#.%&:\\+?/` or control characters Start with alphanumeric. |
| factories / pipelines | factory | 1-260 | Can't use: `<>*#.%&:\\+?/` or control characters Start with alphanumeric. |
| factories / triggers | factory | 1-260 | Can't use: `<>*#.%&:\\+?/` or control characters Start with alphanumeric. |
| factories / triggers / rerunTriggers | trigger | 1-260 | Can't use: `<>*#.%&:\\+?/` or control characters Start with alphanumeric. |

# Microsoft.DataLakeAnalytics

| Entity | Scope | Length | Valid Characters |
| --- | --- | --- | --- |
| accounts | global | 3-24 | Lowercase letters and numbers. |
| accounts / computePolicies | account | 3-60 | Alphanumerics, hyphens, and underscores. |
| accounts / dataLakeStoreAccounts | account | 3-24 | Lowercase letters and numbers. |
| accounts / firewallRules | account | 3-50 | Alphanumerics, hyphens, and underscores. |
| accounts / storageAccounts | account | 3-60 | Alphanumerics, hyphens, and underscores. |

# Microsoft.DataLakeStore

| Entity | Scope | Length | Valid Characters |
| --- | --- | --- | --- |
| accounts | global | 3-24 | Lowercase letters and numbers. |
| accounts / firewallRules | account | 3-50 | Alphanumerics, hyphens, and underscores. |
| accounts / virtualNetworkRules | account | 3-50 | Alphanumerics, hyphens, and underscores. |

# Microsoft.DataMigration

| Entity | Scope | Length | Valid Characters |
| --- | --- | --- | --- |
| services | resource group | 2-62 | Alphanumerics, hyphens, periods, and underscores. Start with alphanumeric. |
| services / projects | service | 2-57 | Alphanumerics, hyphens, periods, and underscores. Start with alphanumeric. |

# Microsoft.DataProtection

| Entity | Scope | Length | Valid Characters |
| --- | --- | --- | --- |
| backupVaults | resource group | 2-50 | Alphanumerics and hyphens. Start with letter. |
| backupvaults / backupInstances | backup vault | 1-75 | Alphanumerics and hyphens. |
| backupVaults / backupPolicies | backup vault | 1-75 | Alphanumerics and hyphens. |

# Microsoft.DBforMariaDB

| Entity | Scope | Length | Valid Characters |
| --- | --- | --- | --- |
| servers | global | 3-63 | Lowercase letters, hyphens and numbers. Can't start or end with hyphen. |
| servers / databases | servers | 1-63 | Alphanumerics and hyphens. |
| servers / firewallRules | servers | 1-128 | Alphanumerics, hyphens, and underscores. |
| servers / virtualNetworkRules | servers | 1-128 | Alphanumerics and hyphens. |

# Microsoft.DBforMySQL

| Entity | Scope | Length | Valid Characters |
| --- | --- | --- | --- |
| servers | global | 3-63 | Lowercase letters, hyphens and numbers. Can't start or end with hyphen. |
| servers / databases | servers | 1-63 | Alphanumerics and hyphens. |
| servers / firewallRules | servers | 1-128 | Alphanumerics, hyphens, and underscores. |
| servers / virtualNetworkRules | servers | 1-128 | Alphanumerics and hyphens. |

# Microsoft.DBforPostgreSQL

| Entity | Scope | Length | Valid Characters |
| --- | --- | --- | --- |
| servers | global | 3-63 | Lowercase letters, hyphens and numbers. Can't start or end with hyphen. |
| servers / databases | servers | 1-63 | Alphanumerics and hyphens. |
| servers / firewallRules | servers | 1-128 | Alphanumerics, hyphens, and underscores. |
| servers / virtualNetworkRules | servers | 1-128 | Alphanumerics and hyphens. |

# Microsoft.DesktopVirtualization

| Entity | Scope | Length | Valid Characters |
| --- | --- | --- | --- |
| applicationGroups | resource group | 3-64 | Alphanumerics, underscores, periods, and hyphens. Start with letter or number. End with letter, number, or underscore. |
| hostPools | resource group | 3-64 | Alphanumerics, underscores, periods, and hyphens. Start with letter or number. End with letter, number, or underscore. |
| workspaces | resource group | 3-64 | Alphanumerics, underscores, periods, and hyphens. Start with letter or number. End with letter, number, or underscore. |

# Microsoft.Devices

| Entity | Scope | Length | Valid Characters |
| --- | --- | --- | --- |
| IotHubs | global | 3-50 | Alphanumerics and hyphens. Can't end with hyphen. |
| IotHubs / certificates | IoT hub | 1-64 | Alphanumerics, hyphens, periods, and underscores. |
| IotHubs / eventHubEndpoints / ConsumerGroups | eventHubEndpoints | 1-50 | Alphanumerics, hyphens, periods, and underscores. |
| provisioningServices | resource group | 3-64 | Alphanumerics and hyphens. End with alphanumeric. |
| provisioningServices / certificates | provisioningServices | 1-64 | Alphanumerics, hyphens, periods, and underscores. |

# Microsoft.DevTestLab

| Entity | Scope | Length | Valid Characters |
| --- | --- | --- | --- |
| labs | resource group | 1-50 | Alphanumerics, underscores, and hyphens. |
| labs / customimages | lab | 1-80 | Alphanumerics, underscores, hyphens, and parentheses. |
| labs / formulas | lab | 1-80 | Alphanumerics, underscores, hyphens, and parentheses. |
| labs / virtualmachines | lab | 1-15 (Windows) 1-64 (Linux) | Alphanumerics and hyphens. Start and end with alphanumeric. Can't be all numbers. |

# Microsoft.DocumentDB

| Entity | Scope | Length | Valid Characters |
| --- | --- | --- | --- |
| databaseAccounts | global | 3-44 | Lowercase letters, numbers, and hyphens. Start with lowercase letter or number. |

# Microsoft.ElasticSan (preview)

| Entity | Scope | Length | Valid Characters |
| --- | --- | --- | --- |
| elasticSans | global | 3-24 | Lowercase letters, numbers, hyphens and underscores. Start with lowercase letter or number. Must begin and end with a letter or a number. Each hyphen and underscore must be preceded and followed by an alphanumeric character. |
| elasticSans / volumeGroups | elastic san | 3-63 | Lowercase letters, numbers and hyphens. Start with lowercase letter or number. Must begin and end with a letter or a number. Each hyphen must be preceded and followed by an alphanumeric character. |

# Microsoft.EventGrid

| Entity | Scope | Length | Valid Characters |
| --- | --- | --- | --- |
| domains | resource group | 3-50 | Alphanumerics and hyphens. |
| domains / topics | domain | 3-50 | Alphanumerics and hyphens. |
| eventSubscriptions | resource group | 3-64 | Alphanumerics and hyphens. |
| topics | region | 3-50 | Alphanumerics and hyphens. |

# Microsoft.EventHub

| Entity | Scope | Length | Valid Characters |
| --- | --- | --- | --- |
| clusters | resource group | 6-50 | Alphanumerics and hyphens. Start with letter. End with letter or number. |
| namespaces | global | 6-50 | Alphanumerics and hyphens. Start with letter. End with letter or number. |
| namespaces / AuthorizationRules | namespace | 1-50 | Alphanumerics, periods, hyphens and underscores. Start and end with letter or number. |
| namespaces / disasterRecoveryConfigs | global | 6-50 | Alphanumerics and hyphens. Start with letter. End with alphanumeric. |
| namespaces / eventhubs | namespace | 1-256 | Alphanumerics, periods, hyphens and underscores. Start and end with letter or number. |
| namespaces / eventhubs / authorizationRules | event hub | 1-50 | Alphanumerics, periods, hyphens and underscores. Start and end with letter or number. |
| namespaces / eventhubs / consumergroups | event hub | 1-50 | Alphanumerics, periods, hyphens and underscores. Start and end with letter or number. |

# Microsoft.HDInsight

| Entity | Scope | Length | Valid Characters |
| --- | --- | --- | --- |
| clusters | global | 3-59 | Alphanumerics and hyphens Start and end with letter or number. |

# Microsoft.ImportExport

| Entity | Scope | Length | Valid Characters |
| --- | --- | --- | --- |
| jobs | resource group | 2-64 | Alphanumerics and hyphens. Start with letter. |

# Microsoft.Insights

| Entity | Scope | Length | Valid Characters |
| --- | --- | --- | --- |
| actionGroups | resource group | 1-260 | Can't use: `:<>+/&%\?|` or control characters  Can't end with space or period. |
| autoScaleSettings | resource group | 1-260 | Can't use: `:<>+/&%\?|` or control characters  Can't end with space or period. |
| components | resource group | 1-260 | Can't use: `%&\?/` or control characters  Can't end with space or period. |
| scheduledQueryRules | resource group | 1-260 | Can't use: `*<>%{}&:\\?/#|` or control characters  Can't end with space or period. |
| metricAlerts | resource group | 1-260 | Can't use: `*#&+:<>?@%{}\/|` or control characters  Can't end with space or period. |
| activityLogAlerts | resource group | 1-260 | Can't use: `<>*%{}&:\\?+/#|` or control characters  Can't end with space or period. |

# Microsoft.IoTCentral

| Entity | Scope | Length | Valid Characters |
| --- | --- | --- | --- |
| IoTApps | global | 2-63 | Lowercase letters, numbers and hyphens. Start with lowercase letter or number. |

# Microsoft.KeyVault

| Entity | Scope | Length | Valid Characters |
| --- | --- | --- | --- |
| vaults | global | 3-24 | Alphanumerics and hyphens. Start with letter. End with letter or digit. Can't contain consecutive hyphens. |
| vaults / secrets | Vault | 1-127 | Alphanumerics and hyphens. |

# Microsoft.Kusto

| Entity | Scope | Length | Valid Characters |
| --- | --- | --- | --- |
| clusters | global | 4-22 | Lowercase letters and numbers. Start with letter. |
| /clusters / databases | cluster | 1-260 | Alphanumerics, hyphens, spaces, and periods. |
| /clusters / databases / dataConnections | database | 1-40 | Alphanumerics, hyphens, spaces, and periods. |
| /clusters / databases / eventhubconnections | database | 1-40 | Alphanumerics, hyphens, spaces, and periods. |

# Microsoft.LabServices

| Entity | Scope | Length | Valid Characters |
| --- | --- | --- | --- |
| labplans | resource group | 1-100 | Alphanumerics, hyphens, periods, and underscores. Start with letter and end with alphanumeric. |
| labs | resource group | 1-100 | Alphanumerics, hyphens, periods, and underscores. Start with letter and end with alphanumeric. |

# Microsoft.LoadTestService

| Entity | Scope | Length | Valid Characters |
| --- | --- | --- | --- |
| loadtests | global | 1-64 | Can't use: `<>*&@:?+/\,;=.|[]"` or space. Can't start with underscore, hyphen, or number. Can't end with underscore or hyphen. |

# Microsoft.Logic

| Entity | Scope | Length | Valid Characters |
| --- | --- | --- | --- |
| integrationAccounts | resource group | 1-80 | Alphanumerics, hyphens, underscores, periods, and parenthesis. |
| integrationAccounts / assemblies | integration account | 1-80 | Alphanumerics, hyphens, underscores, periods, and parenthesis. |
| integrationAccounts / batchConfigurations | integration account | 1-20 | Alphanumerics. |
| integrationAccounts / certificates | integration account | 1-80 | Alphanumerics, hyphens, underscores, periods, and parenthesis. |
| integrationAccounts / maps | integration account | 1-80 | Alphanumerics, hyphens, underscores, periods, and parenthesis. |
| integrationAccounts / partners | integration account | 1-80 | Alphanumerics, hyphens, underscores, periods, and parenthesis. |
| integrationAccounts / rosettanetprocessconfigurations | integration account | 1-80 | Alphanumerics, hyphens, underscores, periods, and parenthesis. |
| integrationAccounts / schemas | integration account | 1-80 | Alphanumerics, hyphens, underscores, periods, and parenthesis. |
| integrationAccounts / sessions | integration account | 1-80 | Alphanumerics, hyphens, underscores, periods, and parenthesis. |
| integrationServiceEnvironments | resource group | 1-80 | Alphanumerics, hyphens, periods, and underscores. |
| integrationServiceEnvironments / managedApis | integration service environment | 1-80 | Alphanumerics, hyphens, periods, and underscores. |
| workflows | resource group | 1-43 | Alphanumerics, hyphens, underscores, periods, and parenthesis. |

# Microsoft.MachineLearning

| Entity | Scope | Length | Valid Characters |
| --- | --- | --- | --- |
| commitmentPlans | resource group | 1-260 | Can't use: `<>*%&:?+/\\` or control characters Can't end with a space. |
| webServices | resource group | 1-260 | Can't use: `<>*%&:?+/\\` or control characters Can't end with a space. |
| workspaces | resource group | 1-260 | Can't use: `<>*%&:?+/\\` or control characters Can't end with a space. |

# Microsoft.MachineLearningServices

| Entity | Scope | Length | Valid Characters |
| --- | --- | --- | --- |
| workspaces | resource group | 3-33 | Alphanumerics, hyphens, and underscores. |
| workspaces / computes | workspace | 3-24 for compute instance 3-32 for AML compute 2-16 for other compute types | Alphanumerics and hyphens. |
| workspaces / datastores | workspace | Maximum 255 characters for datastore name| Datastore name consists only of lowercase letters, digits, and underscores. |

# Microsoft.ManagedIdentity

| Entity | Scope | Length | Valid Characters |
| --- | --- | --- | --- |
| userAssignedIdentities | resource group | 3-128 | Alphanumerics, hyphens, and underscores Start with letter or number. |

# Microsoft.Management

>| Entity | Scope | Length | Valid Characters |
| --- | --- | --- | --- |
| managementgroups | tenant | 1-90 | Alphanumerics, hyphens, underscores, periods, and parentheses.  Start with letter or number. Cannot end with period. |

# Microsoft.Maps

| Entity | Scope | Length | Valid Characters |
| --- | --- | --- | --- |
| accounts | resource group | 1-98 (for resource group name and account name) | Alphanumerics, underscores, periods, and hyphens. Start with alphanumeric. |

# Microsoft.Media

| Entity | Scope | Length | Valid Characters |
| --- | --- | --- | --- |
| mediaservices | Azure region | 3-24 | Lowercase letters and numbers. |
| mediaservices / liveEvents | Media service | 1-32 | Alphanumerics and hyphens. Start with alphanumeric. |
| mediaservices / liveEvents / liveOutputs | Live event | 1-256 | Alphanumerics and hyphens. Start with alphanumeric. |
| mediaservices / streamingEndpoints | Media service | 1-24 | Alphanumerics and hyphens. Start with alphanumeric. |

# Microsoft.MobileNetwork

| Entity | Scope | Length | Valid Characters |
| --- | --- | --- | --- |
| mobileNetworks | Resource Group | 1-64 | Alphanumerics and hyphens. Start with alphanumeric. |
| mobileNetworks / sites | Mobile Network | 1-64 | Alphanumerics and hyphens. Start with alphanumeric. |
| mobileNetworks / slices | Mobile Network | 1-64 | Alphanumerics and hyphens. Start with alphanumeric. |
| mobileNetworks / services | Mobile Network | 1-64 | Alphanumerics and hyphens. Start with alphanumeric.  The following words cannot be used on their own as the name: `default`, `requested`, `service`.|
| mobileNetworks / dataNetworks | Mobile Network | 1-64 | Alphanumeric, hyphens and a period/dot (`.`)  Start and end with alphanumeric.  Note: A period/dot (`.`) must be followed by an alphanumeric character. |
| mobileNetworks / simPolicies | Mobile Network | 1-64 | Alphanumerics and hyphens. Start with alphanumeric. |
| packetCoreControlPlanes | Resource Group | 1-64 | Alphanumeric, underscores and hyphens.  Start with alphanumeric. |
| packetCoreControlPlanes / packetCoreDataPlanes | Packet Core Control Plane | 1-64 | Alphanumeric, underscores and hyphens.  Start with alphanumeric. |
| packetCoreControlPlanes / packetCoreDataPlanes / attachedDataNetworks | Mobile Network | 1-64 | Alphanumeric, hyphens and a period/dot (`.`)  Start and end with alphanumeric.  Note: A period/dot (`.`) must be followed by an alphanumeric character. |
| simGroups | Resource Group | 1-64 | Alphanumeric, underscores and hyphens  Start with alphanumeric |
| simGroups / sims | Sim Group | 1-64 | Alphanumeric, underscores and hyphens  Start with alphanumeric |

# Microsoft.NetApp

| Entity | Scope | Length | Valid Characters |
| --- | --- | --- | --- |
| netAppAccounts | resource group | 1-128 | Alphanumerics, underscores, and hyphens.  Start with alphanumeric. |
| netAppAccounts / backups | NetApp account | 3-225 | Alphanumerics, underscores, periods, and hyphens.  Start with alphanumeric. |
| netAppAccounts / backupPolicies | NetApp account | 1-64 | Alphanumerics, underscores, and hyphens.  Start with alphanumeric. |
| netAppAccounts / capacityPools | NetApp account | 1-64 | Alphanumerics, underscores, and hyphens. Start with alphanumeric. |
| netAppAccounts / snapshots | NetApp account | 1-255 | Alphanumerics, underscores, and hyphens.  Start with alphanumeric. |
| netAppAccounts / snapshotPolicies | NetApp account | 1-64 | Alphanumerics, underscores, and hyphens. Start with alphanumeric. |
| netAppAccounts / volumes | NetApp account | 1-64 | Alphanumerics, underscores, and hyphens.  Start with alphanumeric.  Volume cannot be named `bin` or `default`. |
| netAppAccounts / volumeGroups | NetApp account | 3-64 | Alphanumerics, underscores, and hyphens. Start with alphanumeric. |

# Microsoft.Network

| Entity | Scope | Length | Valid Characters |
| --- | --- | --- | --- |
| applicationGateways | resource group | 1-80 | Alphanumerics, underscores, periods, and hyphens. Start with alphanumeric. End alphanumeric or underscore. |
| applicationSecurityGroups | resource group | 1-80 | Alphanumerics, underscores, periods, and hyphens. Start with alphanumeric. End alphanumeric or underscore. |
| azureFirewalls | resource group | 1-80 | Alphanumerics, underscores, periods, and hyphens. Start with alphanumeric. End with alphanumeric or underscore. |
| bastionHosts | resource group | 1-80 | Alphanumerics, underscores, periods, and hyphens. Start with alphanumeric. End alphanumeric or underscore. |
| connections | resource group | 1-80 | Alphanumerics, underscores, periods, and hyphens. Start with alphanumeric. End alphanumeric or underscore. |
| dnsForwardingRuleset | resource group | 1-80 | Alphanumerics, underscores and hyphens. Start with alphanumeric. End alphanumeric. |
| dnsResolvers | resource group | 1-80 | Alphanumerics, underscores and hyphens. Start with alphanumeric. End alphanumeric. |
| dnsResolvers / inboundEndpoints | resource group | 1-80 | Alphanumerics, underscores and hyphens. Start with alphanumeric. End alphanumeric. |
| dnsResolvers / outboundEndpoints | resource group | 1-80 | Alphanumerics, underscores and hyphens. Start with alphanumeric. End alphanumeric. |
| dnsZones | resource group | 1-63 characters 2 to 34 labels Each label is a set of characters separated by a period. For example, **contoso.com** has 2 labels. | Each label can contain alphanumerics, underscores, and hyphens. Each label is separated by a period. |
| expressRouteCircuits | resource group | 1-80 | Alphanumerics, underscores, periods, and hyphens. Start with alphanumeric. End alphanumeric or underscore. |
| firewallPolicies | resource group | 1-80 | Alphanumerics, underscores, periods, and hyphens. Start with alphanumeric. End alphanumeric or underscore. |
| firewallPolicies / ruleGroups | firewall policy | 1-80 | Alphanumerics, underscores, periods, and hyphens. Start with alphanumeric. End alphanumeric or underscore. |
| frontDoors | global | 5-64 | Alphanumerics and hyphens. Start and end with alphanumeric. |
| frontdoorWebApplicationFirewallPolicies | resource group | 1-128 | Alphanumerics. Start with letter. |
| loadBalancers | resource group | 1-80 | Alphanumerics, underscores, periods, and hyphens. Start with alphanumeric. End alphanumeric or underscore. |
| loadBalancers / inboundNatRules | load balancer | 1-80 | Alphanumerics, underscores, periods, and hyphens. Start with alphanumeric. End alphanumeric or underscore. |
| localNetworkGateways | resource group | 1-80 | Alphanumerics, underscores, periods, and hyphens. Start with alphanumeric. End alphanumeric or underscore. |
| networkInterfaces | resource group | 1-80 | Alphanumerics, underscores, periods, and hyphens. Start with alphanumeric. End alphanumeric or underscore. |
| networkSecurityGroups | resource group | 1-80 | Alphanumerics, underscores, periods, and hyphens. Start with alphanumeric. End alphanumeric or underscore. |
| networkSecurityGroups / securityRules | network security group | 1-80 | Alphanumerics, underscores, periods, and hyphens. Start with alphanumeric. End alphanumeric or underscore. |
| networkWatchers | resource group | 1-80 | Alphanumerics, underscores, periods, and hyphens. Start with alphanumeric. End alphanumeric or underscore. |
| privateDnsZones | resource group | 1-63 characters 2 to 34 labels Each label is a set of characters separated by a period. For example, **contoso.com** has 2 labels. | Each label can contain alphanumerics, underscores, and hyphens. Each label is separated by a period. |
| privateDnsZones / virtualNetworkLinks | private DNS zone | 1-80 | Alphanumerics, underscores, periods, and hyphens. Start with alphanumeric. End alphanumeric or underscore. |
| privateEndpoints | resource group | 2-64 | Alphanumerics, underscores, periods, and hyphens. Start with alphanumeric. End alphanumeric or underscore. |
| privateLinkServices | resource group | 2-64 | Alphanumerics, underscores, periods, and hyphens. Start with alphanumeric. End alphanumeric or underscore. |
| privateLinkServices / privateEndpointConnections | private link service | 2-64 | Alphanumerics, underscores, periods, and hyphens. Start with alphanumeric. End alphanumeric or underscore. |
| publicIPAddresses | resource group | 1-80 | Alphanumerics, underscores, periods, and hyphens. Start with alphanumeric. End alphanumeric or underscore. |
| publicIPPrefixes | resource group | 1-80 | Alphanumerics, underscores, periods, and hyphens. Start with alphanumeric. End alphanumeric or underscore. |
| routeFilters | resource group | 1-80 | Alphanumerics, underscores, periods, and hyphens. Start with alphanumeric. End alphanumeric or underscore. |
| routeFilters / routeFilterRules | route filter | 1-80 | Alphanumerics, underscores, periods, and hyphens. Start with alphanumeric. End alphanumeric or underscore. |
| routeTables | resource group | 1-80 | Alphanumerics, underscores, periods, and hyphens. Start with alphanumeric. End alphanumeric or underscore. |
| routeTables / routes | route table | 1-80 | Alphanumerics, underscores, periods, and hyphens. Start with alphanumeric. End alphanumeric or underscore. |
| serviceEndpointPolicies | resource group | 1-80 | Alphanumerics, underscores, periods, and hyphens. Start with alphanumeric. End alphanumeric or underscore. |
| trafficmanagerprofiles | global | 1-63 | Alphanumerics, hyphens, and periods. Start and end with alphanumeric. |
| virtualNetworkGateways | resource group | 1-80 | Alphanumerics, underscores, periods, and hyphens. Start with alphanumeric. End alphanumeric or underscore. |
| virtualNetworks | resource group | 2-64 | Alphanumerics, underscores, periods, and hyphens. Start with alphanumeric. End alphanumeric or underscore. |
| virtualnetworks / subnets | virtual network | 1-80 | Alphanumerics, underscores, periods, and hyphens. Start with alphanumeric. End alphanumeric or underscore. |
| virtualNetworks / virtualNetworkPeerings | virtual network | 1-80 | Alphanumerics, underscores, periods, and hyphens. Start with alphanumeric. End alphanumeric or underscore. |
| virtualWans | resource group | 1-80 | Alphanumerics, underscores, periods, and hyphens. Start with alphanumeric. End alphanumeric or underscore. |
| vpnGateways | resource group | 1-80 | Alphanumerics, underscores, periods, and hyphens. Start with alphanumeric. End alphanumeric or underscore. |
| vpnGateways / vpnConnections | VPN gateway | 1-80 | Alphanumerics, underscores, periods, and hyphens. Start with alphanumeric. End alphanumeric or underscore. |
| vpnSites | resource group | 1-80 | Alphanumerics, underscores, periods, and hyphens. Start with alphanumeric. End alphanumeric or underscore. |

# Microsoft.NetworkCloud
| Entity | Scope | Length | Valid Characters |
| --- | --- | --- | --- |
| bareMetalMachineKeySets | resource group | 2-30 | Alphanumerics, underscores, and hyphens. Start with alphanumeric. End with alphanumeric. |
| bareMetalMachines | resource group | 2-64 | Alphanumerics. |
| bmcKeySets | resource group | 2-30 | Alphanumerics, underscores, and hyphens. Start with alphanumeric. End with alphanumeric. |
| cloudServicesNetworks | resource group | 2-30 | Alphanumerics, underscores, and hyphens. Start with alphanumeric. End with alphanumeric. |
| clusterManagers | resource group | 2-30 | Alphanumerics, underscores, and hyphens. Start with alphanumeric. End with alphanumeric. |
| clusters | resource group | 2-30 | Alphanumerics, underscores, and hyphens. Start with alphanumeric. End with alphanumeric. |
| clusters / metricsConfigurations | cluster | see value | Must be `default`. |
| edgeClusters | resource group | 2-30 | Alphanumerics, underscores, and hyphens. Start with alphanumeric. End with alphanumeric. |
| edgeClusters / nodes | edge cluster | 2-64 | Alphanumerics. |
| kubernetesClusters | resource group | 2-30 | Alphanumerics, underscores, and hyphens. Start with alphanumeric. End with alphanumeric. |
| kubernetesClusters / agentPools | kubernetes cluster | 2-30 | Alphanumerics, underscores, and hyphens. Start with alphanumeric. End with alphanumeric. |
| kubernetesClusters / features | kubernetes cluster | 2-63 | Alphanumerics, underscores, and hyphens. Start with alphanumeric. End with alphanumeric.  Only predefined values. |
| l2Networks | resource group | 2-30 | Alphanumerics, underscores, and hyphens. Start with alphanumeric. End with alphanumeric. |
| l3Networks | resource group | 2-30 | Alphanumerics, underscores, and hyphens. Start with alphanumeric. End with alphanumeric. |
| racks | resource group | 2-30 | Alphanumerics, underscores, and hyphens. Start with alphanumeric. End with alphanumeric. |
| registrationHubs | resource group | 2-30 | Alphanumerics, underscores, and hyphens. Start with alphanumeric. End with alphanumeric. |
| registrationHubs / machines | registration hub | 2-40 | Alphanumerics, underscores, and hyphens. Start with alphanumeric. End with alphanumeric. |
| storageAppliances | resource group | 2-30 | Alphanumerics, underscores, and hyphens. Start with alphanumeric. End with alphanumeric. |
| trunkedNetworks | resource group | 2-30 | Alphanumerics, underscores, and hyphens. Start with alphanumeric. End with alphanumeric. |
| volumes | resource group | 2-64 | Alphanumerics, underscores, and hyphens. Start with alphanumeric. End with alphanumeric. |
| virtualMachines | resource group | 2-64 | Alphanumerics. |
| virtualMachines / consoles | virtual machine | see value | Must be `default`. |

# Microsoft.NotificationHubs

| Entity | Scope | Length | Valid Characters |
| --- | --- | --- | --- |
| namespaces | global | 6-50 | Alphanumerics and hyphens Start with letter. End with alphanumeric. |
| namespaces / AuthorizationRules | namespace | 1-256 | Alphanumerics, periods, hyphens, and underscores. Start alphanumeric. |
| namespaces / notificationHubs | namespace | 1-260 | Alphanumerics, periods, hyphens, and underscores. Start alphanumeric. |
| namespaces / notificationHubs / AuthorizationRules | notification hub | 1-256 | Alphanumerics, periods, hyphens, and underscores. Start alphanumeric. |

# Microsoft.OperationalInsights

| Entity | Scope | Length | Valid Characters |
| --- | --- | --- | --- |
| clusters | resource group | 4-63 | Alphanumerics and hyphens. Start and end with alphanumeric. |
| workspaces | resource group | 4-63 | Alphanumerics and hyphens. Start and end with alphanumeric. |

# Microsoft.OperationsManagement

| Entity | Scope | Length | Valid Characters |
| --- | --- | --- | --- |
| solutions | workspace | N/A | For solutions authored by Microsoft, the name must be in the pattern: `SolutionType(WorkspaceName)` For solutions authored by third parties, the name must be in the pattern: `SolutionType[WorkspaceName]` For example, a valid name is: `AntiMalware(contoso-IT)` The solution type is case-sensitive. |

# Microsoft.Portal

| Entity | Scope | Length | Valid Characters |
| --- | --- | --- | --- |
| dashboards | resource group | 3-160 | Alphanumerics and hyphens. To use restricted characters, add a tag named **hidden-title** with the dashboard name you want to use. The portal displays that name when showing the dashboard. |

# Microsoft.PowerBI

| Entity | Scope | Length | Valid Characters |
| --- | --- | --- | --- |
| workspaceCollections | region | 3-63 | Alphanumerics and hyphens. Can't start with hyphen. Can't use consecutive hyphens. |

# Microsoft.PowerBIDedicated

| Entity | Scope | Length | Valid Characters |
| --- | --- | --- | --- |
| capacities | region | 3-63 | Lowercase letters or numbers Start with lowercase letter. |

# Microsoft.Quantum

| Entity | Scope | Length | Valid Characters |
| --- | --- | --- | --- |
| workspaces | region | 2-54 | Alphanumerics and hyphens. Can't start or end with hyphen. |

# Microsoft.RecoveryServices

| Entity | Scope | Length | Valid Characters |
| --- | --- | --- | --- |
| vaults | resource group | 2-50 | Alphanumerics and hyphens. Start with letter. |
| vaults / backupPolicies | vault | 3-150 | Alphanumerics and hyphens. Start with letter. Can't end with hyphen. |

# Microsoft.Relay

| Entity | Scope | Length | Valid Characters |
| --- | --- | --- | --- |
| namespaces | global | 6-50 | Alphanumerics and hyphens. Start with a letter. End with a letter or number. |
| namespaces / AuthorizationRules | namespace | 1-50 | Alphanumerics, periods, hyphens and underscores. Start and end with alphanumeric. |
| namespaces / HybridConnections | namespace | 1-260 | Alphanumerics, periods, hyphens, underscores, and slashes. Start and end with alphanumeric. |
| namespaces / HybridConnections/authorizationRules | hybrid connection | 1-50 | Alphanumerics, periods, hyphens and underscores. Start and end with alphanumeric. |
| namespaces / WcfRelays | namespace | 1-260 | Alphanumerics, periods, hyphens, underscores, and slashes. Start and end with alphanumeric. |
| namespaces / WcfRelays / authorizationRules | Wcf relay | 1-50 | Alphanumerics, periods, hyphens and underscores. Start and end with alphanumeric. |

# Microsoft.Resources

| Entity | Scope | Length | Valid Characters |
| --- | --- | --- | --- |
| deployments | resource group | 1-64 | Alphanumerics, underscores, parentheses, hyphens, and periods. |
| resourcegroups | subscription | 1-90 | Underscores, hyphens, periods, parentheses, and letters or digits as defined by the [Char.IsLetterOrDigit](/dotnet/api/system.char.isletterordigit) function. Valid characters are members of the following categories in [UnicodeCategory](/dotnet/api/system.globalization.unicodecategory): **UppercaseLetter**, **LowercaseLetter**, **TitlecaseLetter**, **ModifierLetter**, **OtherLetter**, **DecimalDigitNumber**. Can't end with period. |
| tagNames | resource | 1-512 | Can't use: `<>%&\?/` or control characters |
| tagNames / tagValues | tag name | 1-256 | All characters. |
| templateSpecs | resource group | 1-90 | Alphanumerics, underscores, parentheses, hyphens, and periods. |

# Microsoft.Security

| Entity | Scope | Length | Valid Characters |
| --- | --- | --- | --- |
| advancedThreatProtectionSettings | resource group | see value | Must be `current` |
| alertsSuppressionRules | subscription | 1-260 | Alphanumerics, underscores, and hyphens. |
| assessmentMetadata | assessment type | 1-260 | Alphanumerics, underscores, and hyphens. |
| assessments | assessment type | 1-260 | Alphanumerics, underscores, and hyphens. |
| automations | resource group | 1-260 | Alphanumerics, underscores, and hyphens. |
| autoProvisioningSettings | subscription | 1-260 | Alphanumerics, underscores, and hyphens. |
| connectors | subscription | 1-260 | Alphanumerics, underscores, and hyphens. |
| deviceSecurityGroups | resource group | 1-260 | Alphanumerics, underscores, and hyphens. |
| informationProtectionPolicies | resource group | see values | Use one of: `custom` `effective` |
| iotSecuritySolutions | resource group | 1-260 | Alphanumerics, underscores, and hyphens. |
| locations / applicationWhitelistings | subscription | 1-260 | Alphanumerics, underscores, and hyphens. |
| locations / jitNetworkAccessPolicies | resource group | 1-260 | Alphanumerics, underscores, and hyphens. |
| ingestionSettings | subscription | 1-260 | Alphanumerics, underscores, and hyphens. |
| pricings | subscription | 1-260 | Alphanumerics, underscores, and hyphens. |
| securityContacts | subscription | 1-260 | Alphanumerics, underscores, and hyphens. |
| settings | subscription | see values | Use one of: `MCAS` `Sentinel` `WDATP` `WDATP_EXCLUDE_LINUX_PUBLIC_PREVIEW` |
| serverVulnerabilityAssessments | resource type | see value | Must be `Default` |
| sqlVulnerabilityAssessments / baselineRules | Vulnerability assessment | 1-260 | Alphanumerics, underscores, and hyphens. |

# Microsoft.ServiceBus

| Entity | Scope | Length | Valid Characters |
| --- | --- | --- | --- |
| namespaces | global | 6-50 | Alphanumerics and hyphens. Start with a letter. End with a letter or number. For more information, see [Create namespace](/rest/api/servicebus/create-namespace). |
| namespaces / AuthorizationRules | namespace | 1-50 | Alphanumerics, periods, hyphens, and underscores. Start and end with alphnumeric. |
| namespaces / disasterRecoveryConfigs | global | 6-50 | Alphanumerics and hyphens. Start with letter. End with alphanumeric. |
| namespaces / migrationConfigurations | namespace | | Should always be **$default**. |
| namespaces / queues | namespace | 1-260 | Alphanumerics, periods, hyphens, underscores, and slashes. Start and end with alphanumeric. |
| namespaces / queues / authorizationRules | queue | 1-50 | Alphanumerics, periods, hyphens, and underscores. Start and end with alphnumeric. |
| namespaces / topics | namespace | 1-260 | Alphanumerics, periods, hyphens, underscores, and slashes. Start and end with alphanumeric. |
| namespaces / topics / authorizationRules | topic | 1-50 | Alphanumerics, periods, hyphens, and underscores. Start and end with alphnumeric. |
| namespaces / topics / subscriptions | topic | 1-50 | Alphanumerics, periods, hyphens, and underscores. Start and end with alphnumeric. |
| namespaces / topics / subscriptions / rules | subscription | 1-50 | Alphanumerics, periods, hyphens, and underscores. Start and end with alphnumeric. |

# Microsoft.ServiceFabric

| Entity | Scope | Length | Valid Characters |
| --- | --- | --- | --- |
| clusters | region | 4-23 | Lowercase letters, numbers, and hyphens. Start with lowercase letter. End with lowercase letter or number. |

# Microsoft.SignalRService

| Entity | Scope | Length | Valid Characters |
| --- | --- | --- | --- |
| signalR | global | 3-63 | Alphanumerics and hyphens. Start with letter. End with letter or number. |

# Microsoft.Sql

| Entity | Scope | Length | Valid Characters |
| --- | --- | --- | --- |
| managedInstances | global | 1-63 | Lowercase letters, numbers, and hyphens.  Can't start or end with hyphen. |
| servers | global | 1-63 | Lowercase letters, numbers, and hyphens. Can't start or end with hyphen. |
| servers / administrators | server | | Must be `ActiveDirectory`. |
| servers / databases | server | 1-128 | Can't use: `<>*%&:\/?` or control characters Can't end with period or space. |
| servers / databases / syncGroups | database | 1-150 | Alphanumerics, hyphens, and underscores. |
| servers / elasticPools | server | 1-128 | Can't use: `<>*%&:\/?` or control characters Can't end with period or space. |
| servers / failoverGroups | global | 1-63 | Lowercase letters, numbers, and hyphens. Can't start or end with hyphen. |
| servers / firewallRules | server | 1-128 | Can't use: `<>*%&:;\/?` or control characters Can't end with period. |
| servers / keys | server | | Must be in format: `VaultName_KeyName_KeyVersion`. |

# Microsoft.Storage

| Entity | Scope | Length | Valid Characters |
| --- | --- | --- | --- |
| storageAccounts | global | 3-24 | Lowercase letters and numbers. |
| storageAccounts / blobServices | storage account | | Must be `default`. |
| storageAccounts / blobServices / containers | storage account | 3-63 | Lowercase letters, numbers, and hyphens. Start with lowercase letter or number. Can't use consecutive hyphens. |
| storageAccounts / fileServices | storage account | | Must be `default`. |
| storageAccounts / fileServices / shares | storage account | 3-63 | Lowercase letters, numbers, and hyphens. Can't start or end with hyphen. Can't use consecutive hyphens. |
| storageAccounts / managementPolicies | storage account | | Must be `default`. |
| blob | container | 1-1024 | Any URL characters, case sensitive |
| queue | storage account | 3-63 | Lowercase letters, numbers, and hyphens. Can't start or end with hyphen. Can't use consecutive hyphens. |
| table | storage account | 3-63 | Alphanumerics. Start with letter. |

# Microsoft.StorageSync

| Entity | Scope | Length | Valid Characters |
| --- | --- | --- | --- |
| storageSyncServices | resource group | 1-260 | Alphanumerics, spaces, periods, hyphens, and underscores. Can't end with period or space. |
| storageSyncServices / syncGroups | storage sync service | 1-260 | Alphanumerics, spaces, periods, hyphens, and underscores. Can't end with period or space. |

# Microsoft.StorSimple

| Entity | Scope | Length | Valid Characters |
| --- | --- | --- | --- |
| managers | resource group | 2-50 | Alphanumerics and hyphens. Start with letter. End with alphanumeric. |

# Microsoft.StreamAnalytics

| Entity | Scope | Length | Valid Characters |
| --- | --- | --- | --- |
| streamingjobs | resource group | 3-63 | Alphanumerics, hyphens, and underscores. |
| streamingjobs / functions | streaming job | 3-63 | Alphanumerics, hyphens, and underscores. |
| streamingjobs / inputs | streaming job | 3-63 | Alphanumerics, hyphens, and underscores. |
| streamingjobs / outputs | streaming job | 3-63 | Alphanumerics, hyphens, and underscores. |
| streamingjobs / transformations | streaming job | 3-63 | Alphanumerics, hyphens, and underscores. |

# Microsoft.Synapse

| Entity | Scope | Length | Valid Characters |
| --- | --- | --- | --- |
| privateLinkHubs | resource group | 1-45 | Lowercase letters and numbers. |
| workspaces | global | 1-50 | Lowercase letters, hyphens, and numbers. Start and end with letter or number. Can't contain `-ondemand` |
| workspaces / bigDataPools | workspace | 1-15 | Letters and numbers. Start with letter. End with letter or number. Can't contain [reserved word](../troubleshooting/error-reserved-resource-name.md). |
| workspaces / sqlPools | workspace | 1-60 | Can't contain `<>*%&:\/?@-` or control characters.  Can't end with `.` or space.  Can't contain [reserved word](../troubleshooting/error-reserved-resource-name.md). |

# Microsoft.TimeSeriesInsights

| Entity | Scope | Length | Valid Characters |
| --- | --- | --- | --- |
| environments | resource group | 1-90 | Can't use: `'<>%&:\?/#` or control characters |
| environments / accessPolicies | environment | 1-90 | Can't use: `'<>%&:\?/#` or control characters |
| environments / eventSources | environment | 1-90 | Can't use: `'<>%&:\?/#` or control characters |
| environments / referenceDataSets | environment | 3-63 | Alphanumerics |

# Microsoft.Web

| Entity | Scope | Length | Valid Characters |
| --- | --- | --- | --- |
| certificates | resource group | 1-260 | Can't use: `/`  Can't end with space or period. |
| serverfarms | resource group | 1-60 | Alphanumeric, hyphens and Unicode characters that can be mapped to Punycode |
| sites | global or per domain. See note below. | 2-60 | Alphanumeric, hyphens and Unicode characters that can be mapped to Punycode Can't start or end with hyphen. |
| sites / slots | site | 2-59 | Alphanumeric, hyphens and Unicode characters that can be mapped to Punycode |
| sites / privateEndpointConnections | site | 2-64 | Alphanumerics, underscores, periods, and hyphens. Start with alphanumeric. End alphanumeric or underscore. |

