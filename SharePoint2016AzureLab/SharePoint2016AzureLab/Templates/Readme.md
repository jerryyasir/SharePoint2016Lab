# Create a new Sharepoint Farm with 1 AD 1 SQL 2 SharePoint WFEs and 3 SharePoint Min Role VMs (Search, Distributed Cache and Application Server)

This template creates three new Azure VMs, each with a public IP address and load balancer and a VNet, it configures one VM to be an AD DC for a new Forest and Domain, one with SQL Server domain joined and a third VM with a Sharepoint farm and  site, all VMs have public facing RDP

Click the button below to deploy

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fjerryyasir%2FSharePoint2016Lab%2Fmaster%2FSharePoint2016AzureLab%2FSharePoint2016AzureLab%2FTemplates%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>

Notes: Sharepoint farm name must not contain spaces.

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2Fsharepoint-three-vm%2Fazuredeploy.json" target="_blank">
