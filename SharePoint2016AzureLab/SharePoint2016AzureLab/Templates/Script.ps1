#
# Script.ps1
#
cd "C:\Users\spadmin\Documents\visual studio 2015\Projects\SharePoint2016FarmHA\SharePoint2016FarmHA"
Login-AzureRmAccount
$ResourceGroupName = "SharePointFarmHA"
New-AzureRmResourceGroup -Name $ResourceGroupName -Location "East US"
Test-AzureRmResourceGroupDeployment -ResourceGroupName $ResourceGroupName -TemplateParameterFile .\azuredeploy.parameters.json -TemplateFile .\azuredeploy.json -Mode Complete -Verbose
New-AzureRmResourceGroupDeployment -ResourceGroupName $ResourceGroupName -TemplateParameterFile .\azuredeploy.parameters.json -TemplateFile .\azuredeploy.json -Mode Complete -Name "HATest" -Force -Verbose



$rgName = "SharePointFarmHA"
Get-AzureRmResourceGroup -Name $rgName
Write-Host Deleting Resource Group - $rgName
Remove-AzureRmResourceGroup -Name $rgName -Force -Verbose
Write-Host Deleted Resource Group - $rgName
