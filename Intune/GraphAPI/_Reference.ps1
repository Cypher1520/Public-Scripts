<#


Get-Command -Module Microsoft.Graphe.Intune | Out-GridView

#Displays all content - no paging
#Get-IntuneManagedDevice -Top "2" | Get-MSGraphAllPages

#>

Install-Module -Name Microsoft.Graph.Intune -Force
Get-Command -Module Microsoft.Graphe.Intune | Out-GridView #displays the cmdlets and can see if there's one available
Import-Module Microsoft.Graph.Intune
Get-Module -Name Microsoft.Graph.Intune -ListAvailable
(Get-Command -Module Microsoft.Graph.Intune).count

Connect-MSGraph -ForceInteractive

#Force Sync
    if(!(Connect-MSGraph)){
        Connect-MSGraph
    }

    #Gets all devices running a platform
    $devices = Get-IntuneManagedDevice -Filter "contains(operatingsystem, 'iOS')"

    #Get all devices running windows
    $devices = Get-IntuneManagedDevice -Filter "contains(operatingsystem, 'Windows')"

    foreach ($d in $devices){
        Invoke-IntuneManagedDeviceSyncDevice -managedDeviceId $d.ManagedDeviceId
        Write-Host "Sending Sync Request to Device with DeviceID $($d.managedDeviceID) Name: $($d.deviceName)" -ForegroundColor Yellow
    } 

#Perform a non cmdlet action - get url info from f12 developer view
    $resource = "deviceManagement/windowsFeatureUpdateProfiles"
    $graphapiversion = "beta"
    $uri = "https://graph.microsoft.com/$graphapiversion/$resource"

    $all = Invoke-MSGraphRequest -HttpMethod GET -Url $uri | Get-MSGraphAllPages
    $refined = $all | where { $_.displayName -notlike "assigned*" }

    #delete objects
    foreach ($r in $refined) {
        $uri2 = "https://graph.microsoft.com/beta/deviceManagement/windowsFeatureUpdateProfiles/$($r.id)"
        Invoke-MSGraphRequest -HttpMethod DELETE -Url $uri2
        Write-Host Deleting ($r.displayName) -ForegroundColor Yellow
    }