# Automated deployment of InterfaceWare Iguana on Azure VM

**THIS REPOSITORY IS IN DEVELOPMENT - CONFIGURATION NOT COMPLETE**

[iNTERFACEWARE Iguana](https://www.interfaceware.com/iguana.html) is a healthcare integration engine. This repository illustrates how to deploy a virtual machine (VM) to [Microsoft Azure](https://azure.microsoft.com) and install Iguana on this VM.

The Iguana instance will be configured to make a connection to a specific instance of the [Azure API for FHIR](https://azure.microsoft.com/en-us/services/azure-api-for-fhir/). To set up a sandbox environment with Azure API for FHIR, web client, etc., you can deploy the [Microsoft/fhir-server-samples](https://github.com/Microsoft/fhir-server-samples) scenario and collect the following information:

1. Azure Active Directory tenant
1. Azure Active Directory client id
1. Azure Active Directory client secret

This information will need to passed to the deployment template.

To deploy the template:

<a href="https://transmogrify.azurewebsites.net/azuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>