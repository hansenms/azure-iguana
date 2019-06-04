# Creating/Updating PowerShell DSC Module

The DSC Module used to configure Iguana is `ConfigureIguana.ps1`. The module has dependencies and to publish the module with dependencies use the following command:

```PowerShell
Publish-AzureVMDscConfiguration .\ConfigureIguana.ps1 -ConfigurationArchivePath .\ConfigureIguana.ps1.zip -Force
```