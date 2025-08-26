<#

Original Script: https://github.com/Ruthhl3ss/public/blob/main/Intune/AssignPoliciesinIntune.ps1

To Add:
Don't overwrite existing assignments:
    Example multi-group JSON
    { "assignments":[ { "target": { "@odata.type":"#microsoft.graph.groupAssignmentTarget", "groupId":"36cb3361-4cd7-48a3-959a-71379f466d1d" } }, { "target": { "@odata.type":"#microsoft.graph.groupAssignmentTarget", "groupId":"b50796b0-b8e6-49f2-84fb-9fff6383103b" } }]}

    #Enumerate current assignments
    $assignmentsuri = "https://graph.microsoft.com/beta/deviceManagement/deviceManagementScripts/$ScriptID/assignments"
    $Respons = (Invoke-RestMethod -Uri $assignmentsuri -Headers $authToken -Method Get).value

    #Build JSON with old assignments
    $requestBody = @{
        deviceManagementScriptAssignments = @()
    }
    #Check if there already are assigned groups to the script
    if ($Respons) {
        foreach ($group in $($Respons)) {
            # Get group assignment
            if ($group.target."@odata.type" -eq "#microsoft.graph.groupAssignmentTarget") {
                # Verify so the new groupID isn't already assigned.
                if (!$group.target.groupId -eq $groupID) {
                    $requestBody.deviceManagementScriptAssignments += @{
                        "target" = $group.target
                    }
                }
                else {
                    Write-Warning "A group with ID=$groupID is already assigned to '$ScriptID'"
                }
            }
        
            # Get exclusion group assignment
            if ($group.target."@odata.type" -eq "#microsoft.graph.exclusionGroupAssignmentTarget") {
                $requestBody.deviceManagementScriptAssignments += @{
                    "target" = $group.target
                }
            } 
        }
    }

    #add new group to JSON
    $requestBody.deviceManagementScriptAssignments += @{
        "target" = @{
            "@odata.type" = "#microsoft.graph.groupAssignmentTarget"
            "groupId"     = "$groupID"
        }
    }

    #Post to Graph
    $restore = $requestBody | ConvertTo-Json -Depth 99
    $assignuri = "https://graph.microsoft.com/beta/deviceManagement/deviceManagementScripts/$ScriptID/assign"
    Invoke-RestMethod -Uri $assignuri -Headers $authToken -Method post -Body $restore -ContentType "application/json; charset=utf-8" 

#>


#Parameter block

[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    [String]$GroupName,
    [Parameter(Mandatory = $true)]
    [String]$PolicyPrefix
)

#####################################################################################
# Functions for retrieving configuration policy etc.. information via Graph API.
#####################################################################################

    $assignmentsuri = "https://graph.microsoft.com/beta/deviceManagement/deviceManagementScripts/$ScriptID/assignments"
    $Respons = (Invoke-RestMethod -Uri $assignmentsuri -Headers $authToken -Method Get).value
    
Function Get-AdministrativeTemplatePolicys() {
 
    $graphApiVersion = "Beta"
    $Resource = "deviceManagement/groupPolicyConfigurations"
    $uri = "https://graph.microsoft.com/$graphApiVersion/$($resource)"
  (Invoke-RestMethod -Uri $uri -Headers $AuthHeaders -Method Get).Value

}

Function Get-DeviceConfigurations() {
 
    $graphApiVersion = "Beta"
    $Resource = "deviceManagement/deviceConfigurations"
    $uri = "https://graph.microsoft.com/$graphApiVersion/$($resource)"
  (Invoke-RestMethod -Uri $uri -Headers $AuthHeaders -Method Get).Value

}

Function Get-ConfigurationPoliciese() {
 
    $graphApiVersion = "Beta"
    $Resource = "deviceManagement/configurationPolicies"
    $uri = "https://graph.microsoft.com/$graphApiVersion/$($resource)"
  (Invoke-RestMethod -Uri $uri -Headers $AuthHeaders -Method Get).Value

}

Function Get-IntunePowershellscripts() {
  
    $graphApiVersion = "Beta"
    $Resource = "deviceManagement/deviceManagementScripts"
    $uri = "https://graph.microsoft.com/$graphApiVersion/$($resource)"
  (Invoke-RestMethod -Uri $uri -Headers $AuthHeaders -Method Get).Value
  
}

Function Get-IntuneProactivescripts() {
  
    $graphApiVersion = "Beta"
    $Resource = "deviceManagement/deviceHealthScripts"
    $uri = "https://graph.microsoft.com/$graphApiVersion/$($resource)"
  (Invoke-RestMethod -Uri $uri -Headers $AuthHeaders -Method Get).Value
  
}

Function Get-CompliancePolicys() {
  
    $graphApiVersion = "Beta"
    $Resource = "deviceManagement/deviceCompliancePolicies"
    $uri = "https://graph.microsoft.com/$graphApiVersion/$($resource)"
  (Invoke-RestMethod -Uri $uri -Headers $AuthHeaders -Method Get).Value
  
}

Function Get-SecurityBaseLinePolicys() {
  
    $graphApiVersion = "Beta"
    $Resource = "deviceManagement/intents"
    $uri = "https://graph.microsoft.com/$graphApiVersion/$($resource)"
    $Policys = (Invoke-RestMethod -Uri $uri -Headers $AuthHeaders -Method Get).Value
    #Selecting Windows 10 Security Baseline from all Policy's 
    $Policys | Where-Object displayName -Like "*Baseline*"

}

Function Get-DeploymentProfiles() {
  
    $graphApiVersion = "Beta"
    $Resource = "deviceManagement/windowsAutopilotDeploymentProfiles"
    $uri = "https://graph.microsoft.com/$graphApiVersion/$($resource)"
  (Invoke-RestMethod -Uri $uri -Headers $AuthHeaders -Method Get).Value
  
}

Function Get-BitlockerProfiles() {
  
    $graphApiVersion = "Beta"
    $Resource = "deviceManagement/intents"
    $uri = "https://graph.microsoft.com/$graphApiVersion/$($resource)"
  (Invoke-RestMethod -Uri $uri -Headers $AuthHeaders -Method Get).Value
  
}

Function Get-DriverUpdates() {
  
    $graphApiVersion = "Beta"
    $Resource = "deviceManagement/windowsDriverUpdateProfiles"
    $uri = "https://graph.microsoft.com/$graphApiVersion/$($resource)"
  (Invoke-RestMethod -Uri $uri -Headers $AuthHeaders -Method Get).Value
  
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

if (!(Test-Path "C:\Program Files\WindowsPowerShell\Modules\AzureADPreview")) {
    if (!(Test-Path "C:\Program Files\WindowsPowerShell\Modules\AzureAD")) {
        Write-Host "Installing AzureAD Module"
        Install-Module AzureAD -Force -Confirm:$false
        Write-Host "Importing AzureAD Module"
        Import-Module AzureAD
    }
}
else {
    Write-Host "Importing AzureADPreview Module"
    Import-Module AzureADPreview
}

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

Connect-MgGraph

#####################################################################################
#Run Part
#####################################################################################

#Convert Group name to OID
$GroupID = (Get-MgGroup | where {$_.DisplayName -eq $GroupName}).id

#Assign Delivery Optimization, Wifi, Update Rings, Endpoint protection, Custom
$DeviceConfigurations = Get-DeviceConfigurations | where { $_.displayName -like $PolicyPrefix }

foreach ($DeviceConfig in $DeviceConfigurations) {
    Write-Host "Assigning Configuration Policy $($DeviceConfig.displayName)"
    $policyid = $DeviceConfig.id
    $policyuri = "https://graph.microsoft.com/beta/deviceManagement/deviceConfigurations('$policyid')/assign"
    $JSON = "{'assignments':[{'id':'','target':{'@odata.type':'#microsoft.graph.groupAssignmentTarget','groupId':'$($GroupID)'}}]}"
    Invoke-RestMethod -Uri $policyuri -Headers $AuthHeaders -Method Post -Body $JSON -ErrorAction Stop -ContentType 'application/json'
}

#Assign Setting Catalog and other Configs
$ConfigurationPolicies = Get-ConfigurationPoliciese | where { $_.name -like $PolicyPrefix }

foreach ($ConfigPolicy in $ConfigurationPolicies) {
    Write-Host "Assigning Settings Catalog Policy $($ConfigPolicy.name)"
    $policyid = $ConfigPolicy.id
    $policyuri = "https://graph.microsoft.com/beta/deviceManagement/configurationPolicies('$policyid')/assign"
    $JSON = "{'assignments':[{'id':'','target':{'@odata.type':'#microsoft.graph.groupAssignmentTarget','groupId':'$($GroupID)'}}]}"
    Invoke-RestMethod -Uri $policyuri -Headers $AuthHeaders -Method Post -Body $JSON -ErrorAction Stop -ContentType 'application/json'
}

#Assign Administrative Templates
$AdministrativePolicys = Get-AdministrativeTemplatePolicys | where { $_.displayName -like $PolicyPrefix }

foreach ($AdministrativePolicy in $AdministrativePolicys) {
    Write-Host "Assigning Administrative Template $($AdministrativePolicy.displayName)"
    $policyid = $AdministrativePolicy.id
    $policyuri = "https://graph.microsoft.com/beta/deviceManagement/groupPolicyConfigurations('$policyid')/assign"
    $JSON = "{'assignments':[{'id':'','target':{'@odata.type':'#microsoft.graph.groupAssignmentTarget','groupId':'$($GroupID)'}}]}"
    Invoke-RestMethod -Uri $policyuri -Headers $AuthHeaders -Method Post -Body $JSON -ErrorAction Stop -ContentType 'application/json'
}

#Assign Powershell Scripts
$IntunePowershellScripts = Get-IntunePowershellscripts | where { $_.displayName -like $PolicyPrefix }

foreach ($IntunePowershellScript in $IntunePowershellScripts) {
    Write-Host "Assigning Intune Powershell Script $($IntunePowershellScript.displayName)"
    $policyid = $IntunePowershellScript.id
    $policyuri = "https://graph.microsoft.com/beta/deviceManagement/deviceManagementScripts('$policyid')/assign"
    $JSON = "{'deviceManagementScriptGroupAssignments':[{'@odata.type':'#microsoft.graph.deviceManagementScriptGroupAssignment','targetGroupId': '$GroupID','id': '$policyid'}]}"
    Invoke-RestMethod -Uri $policyuri -Headers $AuthHeaders -Method Post -Body $JSON -ErrorAction Stop -ContentType 'application/json'
}

#Assign Proactive Scripts
$IntuneProactiveScripts = Get-IntuneProactivescripts | where { $_.displayName -like $PolicyPrefix }

foreach ($IntuneProactiveScript in $IntuneProactiveScripts) {
    Write-Host "Assigning Intune Proactive Script $($IntuneProactiveScript.displayName)"
    $policyid = $IntuneProactiveScript.id
    $policyuri = "https://graph.microsoft.com/beta/deviceManagement/deviceManagementScripts('$policyid')/assign"
    $JSON = "{'deviceManagementScriptGroupAssignments':[{'@odata.type':'#microsoft.graph.deviceManagementScriptGroupAssignment','targetGroupId': '$GroupID','id': '$policyid'}]}"
    Invoke-RestMethod -Uri $policyuri -Headers $AuthHeaders -Method Post -Body $JSON -ErrorAction Stop -ContentType 'application/json'
}

#Assign Compliance Policies
$CompliancePolicys = Get-CompliancePolicys | where { $_.displayName -like $PolicyPrefix }

foreach ($CompliancePolicy in $CompliancePolicys) {
    Write-Host "Assigning Compliance Policy $($CompliancePolicy.displayName)"
    $policyid = $CompliancePolicy.id
    $policyuri = "https://graph.microsoft.com/beta/deviceManagement/deviceCompliancePolicies('$policyid')/assign"
    $JSON = "{'assignments':[{'id':'','target':{'@odata.type':'#microsoft.graph.groupAssignmentTarget','groupId':'$($GroupID)'}}]}"
    Invoke-RestMethod -Uri $policyuri -Headers $AuthHeaders -Method Post -Body $JSON -ErrorAction Stop -ContentType 'application/json'
}

#Assign Security Baselines
$SecurityBaseLinePolicys = Get-SecurityBaseLinePolicys | where { $_.displayName -like $PolicyPrefix }

foreach ($SecurityBaseLinePolicy in $SecurityBaseLinePolicys) {
    Write-Host "Assigning Security Baseline Policy $($SecurityBaseLinePolicy.displayName)"
    $policyid = $SecurityBaseLinePolicy.id
    $policyuri = "https://graph.microsoft.com/beta/deviceManagement/intents('$policyid')/assign"
    $JSON = "{'assignments':[{'id':'','target':{'@odata.type':'#microsoft.graph.groupAssignmentTarget','groupId':'$($GroupID)'}}]}"
    Invoke-RestMethod -Uri $policyuri -Headers $AuthHeaders -Method Post -Body $JSON -ErrorAction Stop -ContentType 'application/json'
}

#Assign Security Baselines
$DeploymentProfiles = Get-DeploymentProfiles | where { $_.displayName -like $PolicyPrefix }

foreach ($DeploymentProfile in $DeploymentProfiles) {
    Write-Host "Assigning Deployment Profile $($DeploymentProfile.displayName)"
    $policyid = $DeploymentProfile.id
    $policyuri = "https://graph.microsoft.com/beta/deviceManagement/intents('$policyid')/assign"
    $JSON = "{'assignments':[{'id':'','target':{'@odata.type':'#microsoft.graph.groupAssignmentTarget','groupId':'$($GroupID)'}}]}"
    Invoke-RestMethod -Uri $policyuri -Headers $AuthHeaders -Method Post -Body $JSON -ErrorAction Stop -ContentType 'application/json'
}

#Assign Bitlocker
$BitlockerProfiles = Get-BitlockerProfiles | where { $_.displayName -like "*Bitlocker*" -and $PolicyPrefix}

foreach ($BitlockerProfile in $BitlockerProfiles) {
    Write-Host "Assigning Bitlocker Profile $($BitlockerProfile.displayName)" 
    $policyid = $BitlockerProfile.id
    $policyuri = "https://graph.microsoft.com/beta/deviceManagement/intents/$policyid/assign"
    $JSON = "{'assignments':[{'id':'','target':{'@odata.type':'#microsoft.graph.groupAssignmentTarget','groupId':'$($GroupID)'}}]}"
    Invoke-RestMethod -Uri $policyuri -Headers $AuthHeaders -Method Post -Body $JSON -ErrorAction Stop -ContentType 'application/json'
}

$DriverUpdates = Get-DriverUpdates | where { $_.displayName -like $PolicyPrefix }

foreach ($DriverUpdate in $DriverUpdates) {
    Write-Host "Assigning Bitlocker Profile $($DriverUpdate.displayName)" 
    $policyid = $DriverUpdate.id
    $policyuri = "https://graph.microsoft.com/beta/deviceManagement/windowsDriverUpdateProfiles/$policyid/assign"
    $JSON = "{'assignments':[{'id':'','target':{'@odata.type':'#microsoft.graph.groupAssignmentTarget','groupId':'$($GroupID)'}}]}"
    Invoke-RestMethod -Uri $policyuri -Headers $AuthHeaders -Method Post -Body $JSON -ErrorAction Stop -ContentType 'application/json'
}