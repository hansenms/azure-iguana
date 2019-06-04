# Automated deployment of InterfaceWare Iguana on Azure VM

**THIS REPOSITORY IS IN DEVELOPMENT - CONFIGURATION NOT COMPLETE**

[iNTERFACEWARE Iguana](https://www.interfaceware.com/iguana.html) is a healthcare integration engine. This repository illustrates how to deploy a virtual machine (VM) to [Microsoft Azure](https://azure.microsoft.com) and install Iguana on this VM.

The Iguana instance will be configured to make a connection to a specific instance of the [Azure API for FHIR](https://azure.microsoft.com/en-us/services/azure-api-for-fhir/). To set up a sandbox environment with Azure API for FHIR, web client, etc., you can deploy the [Microsoft/fhir-server-samples](https://github.com/Microsoft/fhir-server-samples) scenario and collect the following information:

1. Azure Active Directory tenant id
1. Azure Active Directory client id
1. Azure Active Directory client secret
1. FHIR service URL

This information will need to passed to the deployment template.

To deploy the template:

Create a parameter file `azuredeploy.parameters.json`:

```json
{
    "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "vmName": {
            "value": "MY-VM-NAME"
        },
        "adminUsername": {
            "value": "msiguanauser"
        },
        "adminPassword": {
            "value": "<MY SUPER SECRET PASSWORD>"
        },
        "aadAuthority": {
            "value": "https://login.microsoftonline.com/<TENANT-ID>"
        },
        "aadClientId": {
            "value": "<CLIENT-ID>"
        },
        "aadClientSecret": {
            "value": "<CLIENT-SECRET>"
        },
        "fhirServerUrl": {
            "value": "https://<AZURE API FOR FHIR NAME>.azurehealthcareapis.com"
        }
    }
}
```

```PowerShell
# Create resource group
$rg = New-AzureRmResourceGroup -Name "resource-group-name" -Location "westus2"

# Deploy VM
New-AzureRmResourceGroupDeployment -TemplateUri https://raw.githubusercontent.com/hansenms/azure-iguana/master/azuredeploy.json -TemplateParameterFile .\azuredeploy.parameters.json -ResourceGroupName $rg.ResourceGroupName
```

Or use the portal:

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fhansenms%2Fazure-iguana%2Fmaster%2Fazuredeploy.json" target="_blank">
    <img src="https://azuredeploy.net/deploybutton.png"/>
</a>

After deployment, use remote desktop to connect to the deployed VM and navigate to: `http://localhost:6543`