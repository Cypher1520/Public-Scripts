<#
To Add:
Integrate parameter for app type.

#>

#Parameter block
[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    [String]$GroupName,
    [String]$AppPrefix,
    [String]$AppType
)

#####################################################################################
# Functions for retrieving Apps list.. information via Graph API.
#####################################################################################
Function Get-MobileApps() {
 
    $graphApiVersion = "Beta"
    $Resource = "deviceAppManagement/mobileApps"
    $uri = "https://graph.microsoft.com/$graphApiVersion/$($resource)"
    (Invoke-RestMethod -Uri $uri -Headers $AuthHeaders -Method Get).Value | Where-Object { ($_.'displayName').contains("$Name") -and (!($_.'@odata.type').Contains("managed")) -and (($_.'@odata.type').Contains('win'))
    }

}

#####################################################################################
## Check for Modules
#####################################################################################

#Checking for correct modules and installing them if needed
$InstalledModules = Get-InstalledModule
$Module_Name = "MSAL.PS"
If ($InstalledModules.name -notcontains $Module_Name) {
    Write-Host "Installing module $Module_Name"
    Install-Module $Module_Name -Force
}
Else {
    Write-Host "$Module_Name Module already installed"
}		

#Importing Module
Write-Host "Importing Module $Module_Name"
Import-Module $Module_Name
Import-Module AzureAD

#####################################################################################
## Login Part
#####################################################################################

Write-Host "Getting token for Authentication"

# Token voor Configuration Profiles, Update Policies
$authResult = Get-MsalToken -ClientId d1ddf0e4-d672-4dae-b554-9d5bdfd93547 -RedirectUri "urn:ietf:wg:oauth:2.0:oob" -Interactive
$AuthHeaders = @{
    'Content-Type'  = 'application/json'
    'Authorization' = "Bearer " + $authResult.AccessToken
    'ExpiresOn'     = $authResult.ExpiresOn
         
}
Connect-AzureAD

#####################################################################################
#Run Part
#####################################################################################

#Convert Group name to OID
$AzureADGroup = (Get-AzureADGroup -SearchString $GroupName).objectid

#Assign Delivery Optimization, Wifi, Update Rings, Endpoint protection, Custom
if ($null -ne $AppPrefix)
{
    $MobileApps = Get-MobileApps | where { $_.displayName -like $AppPrefix }
}
else {
    $MobileApps = Get-MobileApps
}

foreach ($MobileApp in $MobileApps) {
    Write-Host "Assigning Configuration Policy $($MobileApp.displayName)"
    $policyid = $MobileApp.id
    $policyuri = "https://graph.microsoft.com/beta/deviceManagement/deviceConfigurations('$policyid')/assign"
    $JSON = "{'assignments':[{'id':'','target':{'@odata.type':'#microsoft.graph.groupAssignmentTarget','groupId':'$($AzureADGroup)'}}]}"
    Invoke-RestMethod -Uri $policyuri -Headers $AuthHeaders -Method Post -Body $JSON -ErrorAction Stop -ContentType 'application/json'
}