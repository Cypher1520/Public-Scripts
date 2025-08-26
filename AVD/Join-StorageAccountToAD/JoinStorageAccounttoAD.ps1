<#
Note: If you don’t already have the Azure Az Powershell module installed, do so by:
1) Run the following commands to install the full Azure PowerShell module with all the necessary commandlets:
   Run this to uninstall the previous module (if installed) - Uninstall-AzureRm
   Run this to install the latest Azure modules - Install-Module -Name Az
2) Running the following command within an elevated Powershell shell command window:
Install-Module -Name Az -Scope CurrentUser -Repository PSGallery -Force
(To check whether the Az module and other modules have been installed, run the following command - Get-InstalledModule)
3) Install NuGet to allow Powershell to consume packages by running the following command:
Install-PackageProvider -Name NuGet -Force
4) Download and unzip the AzFilesHybrid PowerShell module to the root of the C drive from the link below (so files should be in C:\AzFilesHybrid)
https://github.com/Azure-Samples/azure-files-samples/releases
#>

Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope Currentuser -ErrorAction Stop -ErrorVariable Verbose
Write-host "ExecutionPolicy changed to Unrestricted"
Set-Location C:\Users\t1.crockwell\Downloads
.\CopyToPSPath.ps1
Import-Module -name AzFilesHybrid -ErrorAction Stop -ErrorVariable Verbose
Write-Host "Module AzFilesHybrid imported"
Connect-AzAccount -ErrorAction Stop -ErrorVariable Verbose
Write-Host "Connected successfully to Azure AD"
Select-AzSubscription -SubscriptionName "VDI-PRD"
$resourceGroup = Read-Host "Resource Group Name (vdiprdarmrgp067)"
$storageAccount = Read-Host "Storage Account Name (avdprdarmstauw2067)"
join-AzStorageaccountForAuth -ResourceGroupName $resourceGroup -Name $storageAccount -DomainAccountType "ComputerAccount" -OrganizationalUnitDistinguishedName "OU=AADStorageAccount,OU=AVD,OU=Virtual,OU=Prod,OU=Computers,OU=Objects,DC=network,DC=lan" -ErrorAction Stop -ErrorVariable Verbose
Write-Host "Storage account successfully joined to the SUNCOR domain"
read-host “Press ENTER to exit...”
exit
