#
# Script.ps1
#
cd "C:\Users\spadmin\Source\Repos\SharePoint2016Azure\SharePoint2016AzureLab\SharePoint2016AzureLab\Templates"
Login-AzureRmAccount
$ResourceGroupName = "SharePointFarm"
New-AzureRmResourceGroup -Name $ResourceGroupName -Location "East US"
Test-AzureRmResourceGroupDeployment -ResourceGroupName $ResourceGroupName -TemplateParameterFile .\azuredeploy.parameters.json -TemplateFile .\azuredeploy.json -Mode Complete -Verbose
New-AzureRmResourceGroupDeployment -ResourceGroupName $ResourceGroupName -TemplateParameterFile .\azuredeploy.parameters.json -TemplateFile .\azuredeploy.json -Mode Complete -Name "HATest" -Force -Verbose


$ArtifactStagingDirectory = "C:\Users\spadmin\Source\Repos\SharePoint2016Azure\SharePoint2016AzureLab\SharePoint2016AzureLab\Templates\dsc\"
$DSCSourceFolder = Join-Path $ArtifactStagingDirectory "ConfigureADDSCA.ps1"
 # Create DSC configuration archive
    if (Test-Path $DSCSourceFolder) {
        Add-Type -Assembly System.IO.Compression.FileSystem
        $ArchiveFile = Join-Path $ArtifactStagingDirectory "ConfigureADDSCA.ps1.zip"
        Remove-Item -Path $ArchiveFile -ErrorAction SilentlyContinue
        [System.IO.Compression.ZipFile]::CreateFromDirectory($DSCSourceFolder, $ArchiveFile)
}


$rgName = "SharePointFarm"
Get-AzureRmResourceGroup -Name $rgName
Write-Host Deleting Resource Group - $rgName
Remove-AzureRmResourceGroup -Name $rgName -Force -Verbose
Write-Host Deleted Resource Group - $rgName
Get-AzureRmStorageAccount
Get-AzureRmVMSize -Location "EastUs"


Get-AzureRmResourceGroupDeployment -ResourceGroupName $rgName 
Get-LastDeploymentOperation -ResourceGroupName $rgName | ConvertTo-DeploymentOperationSummary


    Get-LastDeploymentOperation -ResourceGroupName $rgName  `
        | ConvertTo-DeploymentOperationSummary `
        | sort -Property StartTime `
        | Out-GridView

        

    Get-LastDeploymentOperation -ResourceGroupName $rgName  `
                                | ConvertTo-DeploymentOperationSummary 



-DeploymentName $ResourceGroupName

