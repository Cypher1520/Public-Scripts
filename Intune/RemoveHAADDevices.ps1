<#
-----------
Author: Chris Rockwell
Must connect to AzureAD first
-----------
Install-Module AzureAD
Import-Module AzureAD
Connect-AzureAD
-----------
after script ran can delete AD object, Intune device and remove from Autopilot.
#>

Import-Module AzureADPreview
Connect-AzureAD
$objid = Read-Host "Object ID"
Remove-AzureADDevice -ObjectID $objid