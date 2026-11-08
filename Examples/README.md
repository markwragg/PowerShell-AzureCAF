# Examples

Sample scripts showing how to use the AzureCAF module to generate consistent, CAF-compliant Azure
resource names and create the resources using those names.

| Script | Description |
| --- | --- |
| [CreateResourceGroup.ps1](CreateResourceGroup.ps1) | Creates a resource group, named with a suffix of the specified organisation, environment and region short code. |
| [CreateMultipleVMs.ps1](CreateMultipleVMs.ps1) | Creates a resource group and a batch of virtual machines, using `-Count` to generate sequentially-numbered VM names in one call. |
| [CreateKeyVault.ps1](CreateKeyVault.ps1) | Creates a resource group, key vault and storage account using a saved naming convention file (`New-CafNamingConvention`), and wires up diagnostic settings for the key vault. |
| [CreateStorageAccount.ps1](CreateStorageAccount.ps1) | Creates a storage account whose random uniqueness suffix is seeded (`-RandomSuffixSeed`) so it resolves to the same name every time the script is rerun, and skips creation if that storage account already exists. |
